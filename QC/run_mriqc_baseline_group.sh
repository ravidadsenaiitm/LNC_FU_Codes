#!/bin/zsh

# Input and Output Directories
input_dir="/home/rdadsena/lcns_analysis/aachen/covid/baseline/Nifti"
output_dir="/home/rdadsena/lcns_analysis/aachen/covid/baseline/Nifti/derivatives/mriqc"

# List of Modalities
modalities=("T1w" "bold")

# Run MRIQC at the group level for specified modalities
docker run -it --rm \
    -v "$input_dir":/data:ro \
    -v "$output_dir":/out \
    nipreps/mriqc:latest \
    /data /out group \
    --modalities "${modalities[@]}"
