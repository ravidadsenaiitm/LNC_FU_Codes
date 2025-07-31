#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 13 20:30:39 2025

@author: ravidadsena
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os  # For file path operations

# File path (update this if necessary)
file_path = "/Users/ravidadsena/Downloads/EFACTS_Crosssectional/Results/T1_analysis/Plots/aseg.stats_combined_hc_p_residual_corrected.xlsx"

# Load the Excel sheet
data = pd.read_excel(file_path)

# Extract the directory of the input file
output_dir = os.path.dirname(file_path)

# Extract columns starting from Cerebellum to the end
cerebellum_columns = data.loc[:, 'Left-Cerebellum-White-Matter':].columns

# Average left and right regions where applicable
averaged_columns = {}
processed_regions = []

for column in cerebellum_columns:
    if column.startswith('Left-') and column.replace('Left-', 'Right-') in cerebellum_columns:
        right_column = column.replace('Left-', 'Right-')
        avg_column_name = column.replace('Left-', '').replace('-White-Matter', ' White Matter').replace('-Cortex', ' Cortex')
        data[avg_column_name] = data[[column, right_column]].mean(axis=1)
        averaged_columns[avg_column_name] = [column, right_column]
        processed_regions.append(column)
        processed_regions.append(right_column)

# Include regions that don't have left and right counterparts
unprocessed_regions = [col for col in cerebellum_columns if col not in processed_regions]
regions = list(averaged_columns.keys()) + unprocessed_regions

# Apply absolute value transformation
for region in regions:
    data[region] = data[region].abs()

# Select error type: 'SD' for standard deviation or 'SE' for standard error
error_type = "SE"  # Choose 'SD' or 'SE'

# Calculate mean, standard deviation, and percentage difference
groups = ['hc', 'fa']  # Ensure the order of groups is consistent
plt.figure(figsize=(10, 6))  # Reduced figure size
bar_width = 0.25  # Narrower bars
x = np.arange(len(regions))

# Colors for groups
group_colors = {'hc': 'blue', 'fa': 'red'}

for i, group in enumerate(groups):
    means = []
    errors = []

    for region in regions:
        group_data = data[data['Group'] == group]
        means.append(group_data[region].mean())

        if error_type == "SD":
            errors.append(group_data[region].std())
        elif error_type == "SE":
            errors.append(group_data[region].std() / np.sqrt(len(group_data)))

    # Plot bars for each group with specific colors
    plt.bar(x + i * bar_width, means, yerr=errors, capsize=5, alpha=0.7, 
            label=group, width=bar_width, color=group_colors[group])

# Calculate and annotate percentage differences
for idx, region in enumerate(regions):
    hc_mean = data[data['Group'] == 'hc'][region].mean()
    fa_mean = data[data['Group'] == 'fa'][region].mean()

    # Percentage difference calculation
    if hc_mean != 0:
        percentage_diff = ((fa_mean - hc_mean) / hc_mean) * 100
    else:
        percentage_diff = 0  # Handle edge case if hc_mean is zero

    # Center the percentage between hc and fa
    hc_x_pos = x[idx]  # Position for HC bar
    fa_x_pos = x[idx] + bar_width  # Position for FA bar
    center_x = (hc_x_pos + fa_x_pos) / 2  # Midpoint between HC and FA bars

    # Position the text slightly above the taller bar to avoid overlap
    max_y = max(hc_mean, fa_mean) + max(errors) * 0.6
    offset = 0.2  # Adjust this value to control how far right the text moves
    plt.text(center_x+ offset, max_y, f"{percentage_diff:.1f}%", 
             ha='center', va='bottom', fontsize=9, fontweight='bold', color='black', rotation=45)
    


# Customize the plot
plt.xticks(x + bar_width / 2, regions, rotation=45, ha='right', fontsize=10, fontweight='bold')  # Smaller font size
plt.ylabel('Mean Absolute Volume (mm³)', fontsize=12, fontweight='bold')  # Reduced font size
plt.xlabel('Brain Regions', fontsize=12, fontweight='bold')  # Reduced font size
plt.title(f'Mean Absolute Volume and Percentage Difference Between HC and FA ({error_type})', fontsize=12, fontweight='bold')  # Reduced font size
plt.yticks(fontweight='bold', fontsize=10)  # Smaller tick labels
plt.legend(title='Group', fontsize=10, loc='upper left', bbox_to_anchor=(0.01, 0.99))

plt.tight_layout()

# Save the figure as PNG with 300 DPI
output_file = os.path.join(output_dir, "Mean_Absolute_Volume_Plot_Compact.png")
plt.savefig(output_file, format='png', dpi=300)

# Show the plot
plt.show()

print(f"Figure saved at: {output_file}")