#!/bin/bash

# Output Directory (where FreeSurfer has already processed data)
output_dir="/home/rdadsena/LNC_FU/Longitudinal/covid/baseline/Nifti/derivatives/fastsurfer"

# New List of Participants (Subject IDs)
participants=(
    "sub-B1971" "sub-B2019" "sub-B2029" "sub-B2032" "sub-B2046" "sub-B2053"
    "sub-B2056" "sub-B2068" "sub-B2069" "sub-B2073" "sub-B2075" "sub-B2076"
    "sub-B2082" "sub-B2083" "sub-B2091" "sub-B2095" "sub-B2104" "sub-B2113"
    "sub-B2114" "sub-B2132" "sub-B2134" "sub-B2143" "sub-B2144" "sub-B2160"
    "sub-B2172" "sub-B2185" "sub-B2187" "sub-B2192" "sub-B2193" "sub-B2206"
    "sub-B2208" "sub-B2210" "sub-B2224" "sub-B2255" "sub-B2276" "sub-B2286"
    "sub-B2301" "sub-B2307" "sub-B2308" "sub-B2309" "sub-B2322" "sub-B2324"
    "sub-B2351" "sub-B2356" "sub-B2362" "sub-B2367" "sub-B2389" "sub-B2395"
)

# Path to FreeSurfer License
freesurfer_license="/home/rdadsena/license.txt"

# Path to FreeSurfer installation
freesurfer_home="/home/rdadsena/software/freesurfer"

# Path to the installed MATLAB Runtime (MCR) for MATLAB 2019b
mcr_path="/home/rdadsena/software/freesurfer/MCRv97"

# Export the FreeSurfer license
export FS_LICENSE=$freesurfer_license

# Set up FreeSurfer environment
export FREESURFER_HOME=$freesurfer_home
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# Add the MCR to the library path
export LD_LIBRARY_PATH=$mcr_path/runtime/glnxa64:$mcr_path/bin/glnxa64:$mcr_path/sys/os/glnxa64:$LD_LIBRARY_PATH

# Loop through each participant
for participant in "${participants[@]}"; do
    echo "Running brainstem structures processing for participant: $participant"
    
    # Check if the FreeSurfer output directory for the participant exists
    if [ -d "$output_dir/$participant" ]; then
        echo "FreeSurfer output found for $participant"
        
        # Run brainstem structures processing with segmentBS.sh
        $FREESURFER_HOME/bin/segmentBS.sh "$participant" "$output_dir"

        echo "Brainstem structures processing complete for $participant"
    else
        echo "FreeSurfer output NOT found for $participant"
    fi
done
