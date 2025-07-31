d#!/bin/zsh

# Input and Output Directories
input_dir="/home/rdadsena/LNC_FU/Longitudinal/covid/baseline/Nifti"
output_dir="/home/rdadsena/LNC_FU/Longitudinal/covid/baseline/Nifti/derivatives/fmriprep"

# New List of Participants (Subject IDs)
participants=("sub-B2095" "sub-B2104" "sub-B2113" "sub-B2114" "sub-B2132" "sub-B2134" "sub-B2143" "sub-B2144")

freesurfer_license="/home/rdadsena/license.txt"
fmriprep_version="latest"

# Loop through each participant and run all processes
for participant_label in "${participants[@]}"; do
    docker run -ti --rm \
        -v "$input_dir":/data:ro \
        -v "$output_dir":/out \
        -v "$freesurfer_license":/opt/freesurfer/license.txt \
        nipreps/fmriprep:"$fmriprep_version" \
        /data /out/fmriprep-"$participant_label" \
        participant \
        --participant-label "$participant_label" \
        -w /work \
        --fs-license-file /opt/freesurfer/license.txt \
        --use-syn-sdc \
        --fs-no-reconall  # Include the --fs-no-reconall flag
done
