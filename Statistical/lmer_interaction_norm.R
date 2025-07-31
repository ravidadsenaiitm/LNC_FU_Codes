# Load required libraries
library(Matrix)
library(lme4)
library(dplyr)
library(emmeans)
library(writexl)
library(readxl)

# Define the file paths
input_file <- "/Users/ravidadsena/Downloads/LNC_FU/fastsurfer_processing/statistical_analysis/TIV_Corrected_Analysis/Time_Effect_Longitudinal/combined_scanner/aseg.stats_combined_hc_p_numeric_residual_corrected_time.xlsx"
output_file <- "/Users/ravidadsena/Downloads/LNC_FU/fastsurfer_processing/statistical_analysis/TIV_Corrected_Analysis/Time_Effect_Longitudinal/combined_scanner/aseg.stats_combined_hc_p_interaction_analysis_results.xlsx"

# Read the Excel input file
data <- read_xlsx(input_file)

# Get the column names and sanitize them for use in R formulas
column_names <- make.names(names(data), unique = TRUE)
names(data) <- column_names

# Identify the volume measurement columns
if ("Left.Lateral.Ventricle" %in% column_names) {
  start_index <- which(column_names == "Left.Lateral.Ventricle")
  volume_measurements <- column_names[start_index:length(column_names)]
} else {
  stop("The column 'Left-Lateral-Ventricle' was not found in the data.")
}

# Ensure only numeric columns are included
volume_measurements <- volume_measurements[sapply(data[, volume_measurements], is.numeric)]

# Convert Group to factor if it isn't already
data$Group <- as.factor(data$Group)

# Ensure Time is treated as a factor
data$Time <- as.factor(data$Time)

# Ensure all volume measurement columns are numeric
for (volume_measurement in volume_measurements) {
  data[[volume_measurement]] <- as.numeric(as.character(data[[volume_measurement]]))
}

# Define lmerControl options
lmer_control <- lmerControl(
  check.nobs.vs.nlev = "ignore",
  check.nobs.vs.rankZ = "ignore",
  check.nobs.vs.nRE = "ignore",
  optimizer = "bobyqa"
)

# Create a list to store results
results_list <- list()

# Loop through each volume measurement
for (volume_measurement in volume_measurements) {
  tryCatch({
    # Define the formula for the linear mixed-effects model
    formula <- as.formula(paste0("`", volume_measurement, "` ~ Group * Time + (1 + Time | Subject)"))
    
    # Fit the model
    model <- lmer(formula, data = data, control = lmer_control)
    
    # Extract estimated marginal means and pairwise comparisons
    emm <- emmeans(model, specs = pairwise ~ Group | Time)
    pairwise_comp <- pairs(emm)
    
    # Extract the interaction effect
    interaction_effect <- as.data.frame(emmeans(model, specs = ~ Group * Time))
    
    # Combine pairwise comparisons and interaction effects
    pairwise_comp_df <- as.data.frame(pairwise_comp)
    interaction_effect$Volume_Measurement <- volume_measurement
    pairwise_comp_df$Volume_Measurement <- volume_measurement
    
    # Add results to the list
    results_list[[volume_measurement]] <- list(
      pairwise = pairwise_comp_df,
      interaction = interaction_effect
    )
  }, error = function(e) {
    cat("Error occurred for", volume_measurement, ":", conditionMessage(e), "\n")
  })
}

# Combine all results
pairwise_results <- do.call(rbind, lapply(results_list, `[[`, "pairwise"))
interaction_results <- do.call(rbind, lapply(results_list, `[[`, "interaction"))

# Write results to an Excel file
write_xlsx(
  list(
    Pairwise_Comparisons = pairwise_results,
    Interaction_Effects = interaction_results
  ),
  output_file
)

cat("Results saved to:", output_file, "\n")
