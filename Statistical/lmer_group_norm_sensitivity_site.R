# Load required libraries
library(Matrix)
library(lme4)
library(dplyr)
library(emmeans)
library(writexl)
library(broom.mixed)
library(lmerTest)
library(multcomp)
library(readxl)

# Read the data from an .xlsx file
data <- read_excel("/Users/ravidadsena/Downloads/LNC_FU/fastsurfer_processing/statistical_analysis/TIV_Corrected_Analysis/aseg.stats_combined_hc_p_numeric_residual_corrected.xlsx")

# Clean column names to remove special characters
column_names <- make.names(names(data))
names(data) <- column_names

# Define the list of volume measurements to assess
volume_measurements <- column_names[6:length(column_names)] # Exclude Subject, Group, Time, Age, Sex columns

# Define lmerControl options
lmer_control <- lmerControl(
  check.nobs.vs.nlev = "ignore",
  check.nobs.vs.rankZ = "ignore",
  check.nobs.vs.nRE = "ignore",
  optimizer = "bobyqa",
  optCtrl = list(maxfun = 1e6)
)

# Create an empty list to store analysis results
analysis_results <- list()

# Loop through each volume measurement
for (volume_measurement in volume_measurements) {
  # Create an empty list to store results for each time point
  time_analysis_results <- list()
  
  # Loop through each time point (0, 1, 2)
  for (time_point in c(0, 1, 2)) {
    # Filter data for the current time point
    data_timepoint <- data[data$Time == time_point, ]
    
    # Check levels of 'Group' and skip if insufficient
    group_levels <- nlevels(factor(data_timepoint$Group))
    if (group_levels <= 1) {
      cat("Skipping analysis for", volume_measurement, "at time point", time_point, "due to insufficient group levels.\n")
      next
    }
    
    tryCatch({
      # Fit the linear mixed-effects model
      formula <- as.formula(paste(volume_measurement, " ~ Group + (1 | Subject)", sep = ""))
      model <- lmer(formula, data = data_timepoint, control = lmer_control)
      
      # Use emmeans to calculate estimated marginal means
      emm <- emmeans(model, ~ Group)
      
      # Calculate pairwise comparisons between groups
      pairwise_comp <- pairs(emm)
      
      # Extract the results
      pairwise_comp_df <- as.data.frame(pairwise_comp)
      
      # Adjust p-values using Benjamini-Hochberg procedure
      pairwise_comp_df$p.adjusted <- p.adjust(pairwise_comp_df$p.value, method = "fdr")
      
      # Calculate Cohen's d
      cohen_d <- pairwise_comp_df$estimate / pairwise_comp_df$SE
      
      # Add Cohen's d to the dataframe
      pairwise_comp_df$Cohen_d <- cohen_d
      
      # Add Volume Measurement and Time Point columns
      pairwise_comp_df$Volume_Measurement <- volume_measurement
      pairwise_comp_df$Time_Point <- time_point
      
      # Add Change column
      pairwise_comp_df$Change <- ifelse(pairwise_comp_df$contrast == "fa - hc", 
                                        ifelse(pairwise_comp_df$estimate > 0, "Increasing", 
                                               ifelse(pairwise_comp_df$estimate < 0, "Decreasing", "No Change")), NA)
      
      # Store analysis results for the current time point
      time_analysis_results[[as.character(time_point)]] <- pairwise_comp_df
    }, error = function(e) {
      # Print error message
      cat("Error occurred for", volume_measurement, "at time point", time_point, ":", conditionMessage(e), "\n")
    })
  }
  
  # Combine analysis results for all time points for the current volume measurement
  combined_results_volume_analysis <- do.call(rbind, time_analysis_results)
  analysis_results[[volume_measurement]] <- combined_results_volume_analysis
}

# Combine all analysis results into a single data frame
combined_results_analysis <- do.call(rbind, analysis_results)

# Check if results are valid
if (!is.null(combined_results_analysis)) {
  # Reorder the columns for better readability
  combined_results_analysis <- combined_results_analysis[, c(
    "Volume_Measurement", "Time_Point", "contrast", "estimate", "SE", 
    "df", "p.value", "p.adjusted", "Cohen_d", "Change"
  )]
  
  # Save results to an Excel file
  save_path <- "/Users/ravidadsena/Downloads/LNC_FU/fastsurfer_processing/statistical_analysis/TIV_Corrected_Analysis/aseg.stats_combined_hc_p_all_time_points_analysis.xlsx"
  write_xlsx(combined_results_analysis, save_path)
  cat("Results saved to", save_path, "\n")
} else {
  cat("No valid results to save.\n")
}
