# Load required libraries
library(Matrix)
library(lme4)
library(dplyr)
library(broom.mixed)
library(lmerTest)
library(writexl)
library(readxl)

# Define a function to load and preprocess the data
load_and_preprocess_data <- function(file_path) {
  # Read the Excel file
  data <- read_xlsx(file_path)
  
  # Get column names and identify volume measurements
  column_names <- names(data)
  column_names <- trimws(column_names)
  start_index <- which(column_names == "Left-Lateral-Ventricle")
  volume_measurements <- column_names[start_index:length(column_names)] # Extract volume columns
  
  # Ensure all volume measurement columns are numeric
  for (volume_measurement in volume_measurements) {
    data[[volume_measurement]] <- as.numeric(as.character(data[[volume_measurement]]))
  }
  
  # Convert Time column to numeric years
  parse_time <- function(x) {
    ifelse(grepl(",", x), {
      parts <- as.numeric(unlist(strsplit(x, ",")))
      years <- parts[1] + parts[2] / 10  # Assuming 9 months is 0.9 years, adjust as needed
    }, {
      as.numeric(x)
    })
  }
  
  data$Time <- sapply(data$Time, parse_time)
  
  return(list(data = data, volume_measurements = volume_measurements))
}

# Define a function to fit the model and extract results
fit_model_and_extract_results <- function(data, volume_measurements, group, save_path) {
  lmer_control <- lmerControl(
    check.nobs.vs.nlev = "ignore",
    check.nobs.vs.rankZ = "ignore",
    check.nobs.vs.nRE = "ignore"
  )
  
  results_list <- list()
  predictions_list <- list()
  
  for (volume_measurement in volume_measurements) {
    if (!volume_measurement %in% names(data)) {
      warning(paste("Column not found in data:", volume_measurement))
      next
    }
    
    if (all(is.na(data[[volume_measurement]]))) {
      warning(paste("All values are missing for:", volume_measurement))
      next
    }
    
    formula <- as.formula(paste0("`", volume_measurement, "` ~ Time + (1 + Time | Subject)"))
    
    tryCatch({
      model <- lmer(formula, data = data[data$Group == group, ], control = lmer_control)
      model_coef <- tidy(model, conf.int = TRUE, conf.level = 0.95)
      
      # Calculate Cohen's d and change direction
      cohen_d <- model_coef$estimate[model_coef$term == "Time"] / model_coef$std.error[model_coef$term == "Time"]
      change_direction <- ifelse(model_coef$estimate[model_coef$term == "Time"] > 0, "Increasing",
                                 ifelse(model_coef$estimate[model_coef$term == "Time"] < 0, "Decreasing", "No Change"))
      
      model_coef$cohen_d <- cohen_d
      model_coef$change_direction <- change_direction
      model_coef$Volume_Measurement <- volume_measurement
      
      results_list[[volume_measurement]] <- model_coef
    }, error = function(e) {
      warning(paste("Error fitting model for:", volume_measurement, "-", e$message))
    })
  }
  
  combined_results <- do.call(rbind, results_list)
  combined_results <- combined_results[, c("Volume_Measurement", "term", "estimate", "std.error", "statistic", "p.value", "cohen_d", "change_direction")]
  combined_results$p.adjusted <- p.adjust(combined_results$p.value, method = "fdr")
  
  # Save results to Excel file
  write_xlsx(combined_results, save_path)
  
  return(combined_results)
}

# Define file paths
file_path <- "/Users/ravidadsena/Downloads/LNC_FU/fastsurfer_processing/statistical_analysis/TIV_Corrected_Analysis/aseg.stats_combined_hc_p_numeric_residual_corrected_onlyb.xlsx"
save_path_hc <- "/Users/ravidadsena/Downloads/LNC_FU/fastsurfer_processing/statistical_analysis/TIV_Corrected_Analysis/aseg.stats_combined_hc_time_site.xlsx"
save_path_covid <- "/Users/ravidadsena/Downloads/LNC_FU/fastsurfer_processing/statistical_analysis/TIV_Corrected_Analysis/aseg.stats_combined_covid_time_site.xlsx"

# Load and preprocess data
data_info <- load_and_preprocess_data(file_path)
data <- data_info$data
volume_measurements <- data_info$volume_measurements

# Fit models and extract results for covid and hc groups
results_hc <- fit_model_and_extract_results(data, volume_measurements, "hc", save_path_hc)
results_covid <- fit_model_and_extract_results(data, volume_measurements, "covid", save_path_covid)
