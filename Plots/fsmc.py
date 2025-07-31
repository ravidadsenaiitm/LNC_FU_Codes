import pandas as pd
import numpy as np
import plotly.graph_objects as go

# -------------------------------
# 1. Read the Excel file into a DataFrame
# -------------------------------
file_path = "/Users/ravidadsena/Downloads/LNC_FU/fastsurfer_processing/correlation_analysis/plots/Plots_Paper/fsmc_score_plot.xlsx"
sheet_name = "Sheet2"  # Update if your sheet name differs
df = pd.read_excel(file_path, sheet_name=sheet_name)

# -------------------------------
# 2. Define fatigue classification function
# -------------------------------
def classify_fatigue_level(score):
    if score >= 63:
        return 'Severe Fatigue'
    elif score >= 53:
        return 'Moderate Fatigue'
    elif score >= 43:
        return 'Mild Fatigue'
    else:
        return 'No Fatigue'

# Apply classification for each time point
df['Fatigue_Level_b'] = df['fsmc_b'].apply(classify_fatigue_level)
df['Fatigue_Level_c'] = df['fsmc_c'].apply(classify_fatigue_level)
df['Fatigue_Level_f'] = df['fsmc_f'].apply(classify_fatigue_level)

# Drop any rows with missing values
df.dropna(inplace=True)

# -------------------------------
# 3. Define the custom ordered fatigue levels
# -------------------------------
fatigue_levels = ['Severe Fatigue', 'Moderate Fatigue', 'Mild Fatigue', 'No Fatigue']

# -------------------------------
# 4. Compute transition counts for each stage
# -------------------------------
# Baseline to first follow-up (c)
transitions_bc = df.groupby(['Fatigue_Level_b', 'Fatigue_Level_c']).size().reset_index(name='Count')
# First follow-up (c) to second follow-up (f)
transitions_cf = df.groupby(['Fatigue_Level_c', 'Fatigue_Level_f']).size().reset_index(name='Count')

# -------------------------------
# 5. Prepare node labels for the Sankey diagram
# -------------------------------
# Calculate counts for each fatigue level at each time point
counts_b = {level: (df['Fatigue_Level_b'] == level).sum() for level in fatigue_levels}
counts_c = {level: (df['Fatigue_Level_c'] == level).sum() for level in fatigue_levels}
counts_f = {level: (df['Fatigue_Level_f'] == level).sum() for level in fatigue_levels}

# Create node labels with the custom ordering
labels_b = [f'<b><span style="font-size: 18px">{level} ({counts_b.get(level, 0)} subjects)</span></b>' for level in fatigue_levels]
labels_c = [f'<b><span style="font-size: 18px">{level} ({counts_c.get(level, 0)} subjects)</span></b>' for level in fatigue_levels]
labels_f = [f'<b><span style="font-size: 18px">{level} ({counts_f.get(level, 0)} subjects)</span></b>' for level in fatigue_levels]

# Combine nodes: first group (baseline), second group (follow-up), third group (second follow-up)
all_labels = labels_b + labels_c + labels_f

# -------------------------------
# 6. Build the Sankey diagram links
# -------------------------------
# For baseline -> follow-up:
source_bc = [fatigue_levels.index(row['Fatigue_Level_b']) for _, row in transitions_bc.iterrows()]
target_bc = [len(fatigue_levels) + fatigue_levels.index(row['Fatigue_Level_c']) for _, row in transitions_bc.iterrows()]
value_bc  = transitions_bc['Count'].tolist()

# For follow-up -> second follow-up:
source_cf = [len(fatigue_levels) + fatigue_levels.index(row['Fatigue_Level_c']) for _, row in transitions_cf.iterrows()]
target_cf = [2 * len(fatigue_levels) + fatigue_levels.index(row['Fatigue_Level_f']) for _, row in transitions_cf.iterrows()]
value_cf  = transitions_cf['Count'].tolist()

# Combine the two sets of links
source_all = source_bc + source_cf
target_all = target_bc + target_cf
value_all  = value_bc + value_cf

# -------------------------------
# 7. Create the Sankey diagram using Plotly
# -------------------------------
fig = go.Figure(data=[go.Sankey(
    node=dict(
        pad=15,
        thickness=20,
        line=dict(color="black", width=0.9),
        label=all_labels,
        # Define colors for each fatigue level; repeated for each time point
        color=["magenta", "orange", "yellow", "green"] * 3
    ),
    link=dict(
        source=source_all,
        target=target_all,
        value=value_all
    )
)])

# Update layout with title and annotations for each time point
fig.update_layout(
    title_text="<b>Evolution of Total Fatigue (FSMC)</b>",
    title_font=dict(size=24),
    annotations=[
        dict(
            x=0.0,
            y=-0.08,
            xref="paper",
            yref="paper",
            text="<b>BL</b>",
            showarrow=False,
            font=dict(color='black', size=20)
        ),
        dict(
            x=0.5,
            y=-0.08,
            xref="paper",
            yref="paper",
            text="<b>FU1</b>",
            showarrow=False,
            font=dict(color='black', size=20)
        ),
        dict(
            x=1.0,
            y=-0.08,
            xref="paper",
            yref="paper",
            text="<b>FU2</b>",
            showarrow=False,
            font=dict(color='black', size=20)
        ),
        dict(
            x=-0.09,
            y=0.5,
            xref="paper",
            yref="paper",
            text="<b>F<br>A<br>T<br>I<br>G<br>U<br>E<br><br>L<br>E<br>V<br>E<br>L<br><br>(<br>F<br>S<br>M<br>C<br>)</b>",
            showarrow=False,
            font=dict(color='black', size=18),
            align="center"
        )

    ]
)


# Save the Sankey diagram as a PNG file with high resolution (600 dpi equivalent)
png_file_path = "/Users/ravidadsena/Downloads/LNC_FU/fastsurfer_processing/correlation_analysis/plots/Plots_Paper/fsmc_sankey_plot.png"
fig.write_image(png_file_path, width=1600, height=900, scale=12)
fig.show()
