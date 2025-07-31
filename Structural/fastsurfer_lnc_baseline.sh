#!/bin/zsh

# Input and Output Directories
input_dir="/home/rdadsena/LNC_FU/Longitudinal/covid/baseline/Nifti"
output_dir="/home/rdadsena/LNC_FU/Longitudinal/covid/baseline/Nifti/derivatives/fastsurfer"

# New List of Participants (Subject IDs)
participants=("sub-B1971" "sub-B2019" "sub-B2029" "sub-B2032" "sub-B2046" "sub-B2053" "sub-B2056" "sub-B2068" "sub-B2069" "sub-B2073" "sub-B2075" "sub-B2076" "sub-B2082" "sub-B2083" "sub-B2091" "sub-B2095" "sub-B2104" "sub-B2113" "sub-B2114" "sub-B2132" "sub-B2134" "sub-B2143" "sub-B2144" "sub-B2160" "sub-B2172" "sub-B2185" "sub-B2187" "sub-B2192" "sub-B2193" "sub-B2206" "sub-B2208" "sub-B2210" "sub-B2224" "sub-B2255" "sub-B2276" "sub-B2286" "sub-B2301" "sub-B2307" "sub-B2308" "sub-B2309" "sub-B2322" "sub-B2324" "sub-B2351" "sub-B2356" "sub-B2362" "sub-B2367" "sub-B2389" "sub-B2395")

# Path to FreeSurfer License
freesurfer_license="/home/rdadsena/license.txt"

# Loop through each participant
for participant in "${participants[@]}"; do
    echo "Processing participant: $participant"
    
    # Locate T1-weighted MRI file
    t1_file="$input_dir/$participant/ses-REETZ/anat/${participant}_ses-REETZ_T1w.nii.gz"
    
    # Check if T1 file exists
    if [ -f "$t1_file" ]; then
        echo "T1-weighted MRI found for $participant"
        
        # Create output directory for participant if it doesn't exist
        participant_output_dir="$output_dir/$participant"
        mkdir -p "$participant_output_dir"
        
        # Run FastSurfer on CPU
        docker run -v "$input_dir:/data" \
                   -v "$participant_output_dir:/output" \
                   -v "$freesurfer_license:/fs_license/license.txt" \
                   --user $(id -u):$(id -g) \
                   --rm \
                   deepmi/fastsurfer:latest \
                   --fs_license /fs_license/license.txt \
                   --t1 "/data/$participant/ses-REETZ/anat/${participant}_ses-REETZ_T1w.nii.gz" \
                   --sid "$participant" \
                   --sd "/output" \
                   --device cpu \
                   --parallel --3T
    else
        echo "T1-weighted MRI not found for $participant"
    fi
done