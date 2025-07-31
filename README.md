# LNC_FU Brain Analysis Code Repository

This repository contains all scripts used for analyzing longitudinal structural and functional brain changes in post-COVID patients over three years.

---

## 🔁 Pipeline Overview

### Quality Control (MRIQC)

Prior to preprocessing, both structural (T1w) and functional (BOLD) MRI data were evaluated using [MRIQC](https://mriqc.readthedocs.io/). MRIQC was run on all subjects to compute image quality metrics (IQMs) including signal-to-noise ratio (SNR), contrast-to-noise ratio (CNR), temporal SNR (tSNR), motion artifacts, and spatial coverage.

A custom Bash script was implemented to automate batch execution of MRIQC for both anatomical and functional modalities. The resulting HTML reports and group-level summary metrics were used to flag potentially low-quality scans.

In addition to automated metrics, all individual MRIQC-generated reports were visually inspected to identify and exclude scans with motion artifacts, ghosting, and other anomalies. Subjects failing visual QC or with extreme outlier metrics were excluded from downstream processing (FastSurfer, fMRIPrep).

### Structural MRI Processing

- **Preprocessing**: FastSurfer was used for automated cortical surface reconstruction and subcortical segmentation from T1-weighted MRI scans. The pipeline includes skull stripping, bias field correction, intensity normalization, and deep-learning-based segmentation using FastSurferCNN.
- **Postprocessing**: Region-wise volumetric measures were extracted from FastSurfer output files (`aseg.stats`, `aparc.stats`) using the Desikan-Killiany-Tourville (DKT) atlas. These features included cortical and subcortical volumes used in downstream statistical and correlation analyses.
- **Automation**: A custom Bash script (`run_fastsurfer.sh`) was developed to batch process all subjects consistently.
- **Output**: Cortical and subcortical volumetric features structured for statistical modeling and visualization.


### Functional MRI Processing
- Preprocessing: [**fMRIPrep**](https://fmriprep.org/)
- Automation: Custom Bash script (`run_fmriprep.sh`)
- Further processing: [**CONN Toolbox**](https://web.conn-toolbox.org/) in MATLAB

### Statistical Analysis
- Modeling: Linear mixed-effects (LME) models in **R**
- Correlation: Spearman correlation (with FDR correction)
- Covariates: Age and sex

### Visualization
- Tools: **Python (matplotlib, seaborn)** and **R (ggplot2, pheatmap)**

---

## 📁 Folder Structure

- `Structural/`: FastSurfer preprocessing and structural volume analysis
- `Functional/`: fMRIPrep + CONN toolbox analysis
- `Statistical/`: R scripts for LME models and FDR correction
- `QC/`: Quality control scripts
- `Plots/`: All figure generation scripts

---

## 🧰 Requirements

- Python 3.8+
- R ≥ 4.3.1
- MATLAB + CONN Toolbox
- Python: nibabel, pandas, matplotlib, seaborn, nilearn
- R: lme4, ggplot2, psych, reshape2

---

## ▶️ How to Use

1. Start with QC
2. Run preprocessing scripts in Structural/ and Functional/
3. Analyze with R scripts in Statistical/
4. Generate plots from Plots/

---

## 📝 License

For academic and non-commercial use only. Contact the author for collaboration or reuse.


