# Load required libraries
library(readxl)
library(reshape2)
library(dplyr)
library(ggplot2)
library(grid)  # for unit()

# Define file path and sheet name
file_path <- "/Users/ravidadsena/Downloads/LNC_FU/fastsurfer_processing/correlation_analysis/plots/final_correlation_results_structuraltt.xlsx"
sheet_name <- "covid_fu2"  # Replace with the actual sheet name

# Read the Excel file. Assume the first column contains brain region labels.
data <- read_excel(file_path, sheet = sheet_name)

# Convert the first column to row names and then convert to a data.frame
data_df <- as.data.frame(data)
rownames(data_df) <- data_df[[1]]
data_df <- data_df[,-1]

# Convert all remaining columns to numeric, removing '**' if present
data_df[] <- lapply(data_df, function(x) {
  as.numeric(gsub("\\*\\*", "", as.character(x)))
})

# Define the brain region rows you want to include
brain_regions <- c(
  "Left-Lateral-Ventricle", "Left-Cerebellum-Cortex", "Left-Thalamus", "Left-Caudate",
  "Left-Putamen", "Left-Pallidum", "Brain-Stem", "Left-Hippocampus",
  "Right-Lateral-Ventricle", "Right-Cerebellum-Cortex", "Right-Thalamus", "Right-Caudate",
  "Right-Putamen", "Right-Pallidum", "Right-Hippocampus"
)

# Define the clinical/neuropsychological measures you want as columns
clinical_measures <- c(
  "MOCA (Montreal Cognitive Assessment)", 
  "FSMC_Total (Fatigue Scale for Motor and Cognitive Functions - Motor Subscale)",
  "ESS_Total (Epworth Sleepiness Scale - Total Score)", 
  "MGCFT_Delay (Modified Grober & Buschke Verbal Learning Test - Delayed Recall)", 
  "CFS_08_Bellscore (Chalder Fatigue Scale - Bell Score)",
  "Interleukin 6 (IL-6 - Pro-Inflammatory Cytokine)", 
  "NFL_05 (Neurofilament Light Chain - Biomarker for Neurodegeneration)",
  "GFAP_05 (Glial Fibrillary Acidic Protein - Astrocytic Injury Marker)", 
  "TAP_Alertness_Phasic_05 (Test for Attentional Performance - Phasic Alertness)",
  "TAP_Alertness_Tonic (Test for Attentional Performance - Tonic Alertness)", 
  "TAP_Dual_Auditory_05 (Test for Attentional Performance - Dual Task Auditory)",
  "TAP_Dual_Visual_05 (Test for Attentional Performance - Dual Task Visual)", 
  "HADS_Total_05 (Hospital Anxiety and Depression Scale - Total Score)",
  "PSQI_05 (Pittsburgh Sleep Quality Index - Total Score)"
)

# Subset the data: reindex rows and columns so that missing ones appear as NA
selected_data <- data_df[brain_regions, clinical_measures, drop = FALSE]

# Melt the matrix into long format
df <- melt(as.matrix(selected_data))
colnames(df) <- c("BrainRegion", "ClinicalMeasure", "Correlation")

# Ensure that Correlation is numeric
df$Correlation <- as.numeric(df$Correlation)

# Create factors to maintain the order
df$BrainRegion <- factor(df$BrainRegion, levels = brain_regions)
df$ClinicalMeasure <- factor(df$ClinicalMeasure, levels = clinical_measures)

# Remove text in parentheses from ClinicalMeasure factor levels for cleaner x-axis labels
# Clean ClinicalMeasure labels for plotting
levels(df$ClinicalMeasure) <- gsub("_05|_08", "", levels(df$ClinicalMeasure))  # Remove _05 and _08
levels(df$ClinicalMeasure) <- gsub("\\s*\\(.*\\)", "", levels(df$ClinicalMeasure))  # Remove text in parentheses

# Use the whole correlation map (unfiltered)
df_full <- df

# Create annotation labels with significance markers:
df_full <- df_full %>% 
  mutate(Label = case_when(
    abs(Correlation) > 0.25 ~ sprintf("%.2f**", Correlation),
    abs(Correlation) > 0.25 ~ sprintf("%.2f*", Correlation),
    TRUE ~ sprintf("%.2f", Correlation)
  ))

# Plot the whole correlation heatmap using ggplot2
p <- ggplot(df_full, aes(x = ClinicalMeasure, y = BrainRegion, fill = Correlation)) +
  geom_tile(color = "black", size = 0.6) +
  geom_text(aes(label = Label, 
                fontface = ifelse(abs(Correlation) > 0.25, "bold", "plain")), 
            size = 4) +
  scale_fill_gradientn(colors = c("blue", "white", "red"), limits = c(-1, 1)) +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) +
  coord_fixed() +
  theme_classic() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12, face = "bold"),
    axis.text.y = element_text(size = 12, face = "bold"),
    axis.title.x = element_text(size = 12, face = "bold"),
    axis.title.y = element_text(size = 12, face = "bold"),
    legend.title = element_text(face = "bold", size = 12),
    legend.text = element_text(face = "bold", size = 12),
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    plot.margin = unit(c(0.02, 0.02, 0.02, 0.02), "cm")
  ) +
  labs(title = "Correlation of Structural Brain Regions with Clinical, Neuropsychological and Fluid Measures", 
       x = "Clinical, Neuropsychological and Fluid Measures", 
       y = "Structural Brain Regions", 
       fill = "Spearman's ρ")

# Save the plot as a PNG file in the same directory as the input Excel file
output_file <- sub(".xlsx", "_heatmap_full_R.png", file_path)
ggsave(filename = output_file, plot = p, dpi = 600, width = 12, height = 10)
print(p)
