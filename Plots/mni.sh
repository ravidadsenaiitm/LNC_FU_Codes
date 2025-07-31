#!/bin/bash

# Input paths
SUBJECT_DIR="/Users/ravidadsena/Downloads/LNC_FU/fastsurfer_processing/statistical_analysis/Plots"
T1_MGZ="$SUBJECT_DIR/T1.mgz"
EXTRACTED_REGIONS="$SUBJECT_DIR/extracted_regions_inverted_pvalues.nii.gz"
MNI_TEMPLATE="/usr/local/fsl/data/standard/MNI152_T1_1mm.nii.gz"
MNI_TEMPLATE_BRAIN="/usr/local/fsl/data/standard/MNI152_T1_1mm_brain.nii.gz"
OUTPUT_PATH="$SUBJECT_DIR/extracted_regions_inverted_pvalues_mni.nii.gz"

# Ensure FSL environment is set
export FSLDIR=/usr/local/fsl
. ${FSLDIR}/etc/fslconf/fsl.sh
export PATH=${FSLDIR}/bin:$PATH

# Step 1: Convert T1.mgz to NIfTI format if not already done
T1_NIFTI="$SUBJECT_DIR/T1.nii.gz"
if [ ! -f "$T1_NIFTI" ]; then
    echo "Converting T1.mgz to NIfTI format..."
    mri_convert "$T1_MGZ" "$T1_NIFTI"
fi

# Step 2: Brain extract T1 image (if needed)
T1_BRAIN="$SUBJECT_DIR/T1_brain.nii.gz"
if [ ! -f "$T1_BRAIN" ]; then
    echo "Brain extracting T1 image..."
    bet "$T1_NIFTI" "$T1_BRAIN" -R
fi

# Step 3: Affine registration using FLIRT
echo "Performing affine registration (FLIRT)..."
AFFINE_MATRIX="$SUBJECT_DIR/T1_to_MNI.mat"
T1_FLIRT_OUT="$SUBJECT_DIR/T1_to_MNI_flirt.nii.gz"

flirt -in "$T1_BRAIN" \
      -ref "$MNI_TEMPLATE_BRAIN" \
      -omat "$AFFINE_MATRIX" \
      -out "$T1_FLIRT_OUT"

# Step 4: Nonlinear registration using FNIRT
echo "Performing nonlinear registration (FNIRT)..."
T1_TO_MNI_WARP="$SUBJECT_DIR/T1_to_MNI_warp.nii.gz"
T1_FNIRT_OUT="$SUBJECT_DIR/T1_to_MNI_fnirt.nii.gz"

fnirt --in="$T1_BRAIN" \
      --ref="$MNI_TEMPLATE_BRAIN" \
      --aff="$AFFINE_MATRIX" \
      --cout="$T1_TO_MNI_WARP" \
      --iout="$T1_FNIRT_OUT"

# Step 5: Apply the warp to the extracted regions
if [ -f "$T1_TO_MNI_WARP" ]; then
    echo "Applying warp to extracted regions..."
    applywarp --in="$EXTRACTED_REGIONS" \
              --ref="$MNI_TEMPLATE" \
              --warp="$T1_TO_MNI_WARP" \
              --out="$OUTPUT_PATH" \
              --interp=nn  # Nearest neighbor interpolation for labels

    echo "Transformation complete. Output saved to: $OUTPUT_PATH"
else
    echo "ERROR: FNIRT did not generate the warp file. Check previous steps."
fi
