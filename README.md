# LNC_FU Brain Analysis Code Repository

This repository contains all scripts used for analyzing longitudinal structural and functional brain changes in post-COVID patients over three years.

---

## 🔁 Pipeline Overview

### Structural MRI Processing
- Preprocessing: [**FastSurfer**](https://github.com/Deep-MI/FastSurfer)
- Automation: Custom Bash script (`run_fastsurfer.sh`)
- Output: Cortical and subcortical volumetric features

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


