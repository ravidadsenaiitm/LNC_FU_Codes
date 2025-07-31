#!/bin/zsh

# Input and Output Directories
input_dir="/home/rdadsena/lcns_analysis/aachen/covid/fu/Nifti"
output_dir="/home/rdadsena/lcns_analysis/aachen/covid/fu/Nifti/derivatives/mriqc"

# Participants List
participants=("sub-B2452" "sub-B2473" "sub-B2474" "sub-B2477" "sub-B2478" "sub-B2486" "sub-B2487" "sub-B2495" "sub-B2500" "sub-B2501" "sub-B2508" "sub-B2517" "sub-B2520" "sub-B2529" "sub-B2547" "sub-B2554" "sub-B2558" "sub-B2561" "sub-B2564" "sub-B2568" "sub-B2573" "sub-B2575" "sub-B2576" "sub-B2579" "sub-B2580" "sub-B2583" "sub-B2585" "sub-B2587" "sub-B2588" "sub-B2599" "sub-B2600" "sub-B2609" "sub-B2620" "sub-B2626" "sub-B2638" "sub-B2641" "sub-B2654" "sub-B2656" "sub-B2664" "sub-B2667" "sub-B2669" "sub-B2672" "sub-B2675" "sub-B2678" "sub-B2690" "sub-B2697" "sub-B2730" "sub-B2751" "sub-B2759")

session_id="REETZ"

# List of Modalities
modalities=("T1w" "bold")

# Loop through each participant and run MRIQC for each modality
for participant_label in "${participants[@]}"; do
    for modality in "${modalities[@]}"; do
        docker run -it --rm \
            -v "$input_dir":/data:ro \
            -v "$output_dir":/out \
            nipreps/mriqc:latest \
            /data /out participant \
            --participant_label "$participant_label" \
            --session-id "$session_id" \
            -m "$modality" \
            --no-sub  # Disable submission of IQMs
    done
done
