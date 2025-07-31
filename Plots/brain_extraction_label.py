import nibabel as nib
import numpy as np

# Paths
aseg_path = "/Users/ravidadsena/Downloads/Dementia_MOVE/Longitudinal/fastsurfer_processing/statistical_analysis/TIV_Corrected_Analysis/Time_Effect_Longitudinal_Corrected/plots/aseg.mgz"
aparc_aseg_path = "/Users/ravidadsena/Downloads/Dementia_MOVE/Longitudinal/fastsurfer_processing/statistical_analysis/TIV_Corrected_Analysis/Time_Effect_Longitudinal_Corrected/plots/aparc+aseg.mgz"
output_path = "/Users/ravidadsena/Downloads/Dementia_MOVE/Longitudinal/fastsurfer_processing/statistical_analysis/TIV_Corrected_Analysis/Time_Effect_Longitudinal_Corrected/plots/extracted_regions_inverted_pvalues.nii.gz"

# Updated labels and p-values (using dot as decimal separator)
labels_pvalues = {
    "Left-Lateral-Ventricle": 0.000486878,
    "Left-Cerebellum-White-Matter": 0.027380073,
    "Left-Cerebellum-Cortex": 0.003145167,
    "Left-Thalamus": 0.012437956,
    "Left-Caudate": 0.027380073,
    "Left-Putamen": 0.000161989,
    "Left-Pallidum": 0.045599927,
    "3rd-Ventricle": 0.013290163,
    "CSF": 0.012437956,
    "Left-Accumbens-area": 0.00269542,
    "Left-VentralDC": 0.047717702,
    "Right-Lateral-Ventricle": 0.000533217,
    "Right-Cerebellum-Cortex": 0.000533217,
    "Right-Thalamus": 0.023253611,
    "Right-Caudate": 0.008518933,
    "Right-Putamen": 1.81394e-05,
    "Right-VentralDC": 0.045116062,
    "WM-hypointensities": 0.016113141,
    "CC_Posterior": 0.047717702,
}

# Updated mapping of label names to integer IDs based on aseg/aparc+aseg conventions
label_ids = {
    "Left-Lateral-Ventricle": 4,
    "Left-Cerebellum-White-Matter": 7,
    "Left-Cerebellum-Cortex": 8,
    "Left-Thalamus": 10,
    "Left-Caudate": 11,
    "Left-Putamen": 12,
    "Left-Pallidum": 13,
    "3rd-Ventricle": 14,
    "CSF": 24,
    "Left-Accumbens-area": 26,
    "Left-VentralDC": 28,
    "Right-Lateral-Ventricle": 5,
    "Right-Cerebellum-Cortex": 47,
    "Right-Thalamus": 49,
    "Right-Caudate": 50,
    "Right-Putamen": 51,
    "Right-VentralDC": 60,
    "WM-hypointensities": 77,
    "CC_Posterior": 251,
}

# Load aseg data
aseg_img = nib.load(aseg_path)
aseg_data = aseg_img.get_fdata()

# Create a mask that encodes inverted p-values
inverted_p_value_mask = np.zeros_like(aseg_data, dtype=np.float32)
for label_name, p_value in labels_pvalues.items():
    label_id = label_ids[label_name]
    inverted_p_value = 1 - p_value  # Invert the p-value
    # Set the inverted p-value for voxels that belong to the current label
    inverted_p_value_mask[aseg_data == label_id] = inverted_p_value

# Save the inverted p-value mask as a new NIfTI file
nib.save(
    nib.Nifti1Image(inverted_p_value_mask, aseg_img.affine, aseg_img.header),
    output_path
)
print(f"Extracted regions with inverted p-values saved to {output_path}")