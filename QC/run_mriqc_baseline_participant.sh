#!/bin/zsh

# Input and Output Directories
input_dir="/home/rdadsena/lcns_analysis/aachen/covid/baseline/Nifti"
output_dir="/home/rdadsena/lcns_analysis/aachen/covid/baseline/Nifti/derivatives/mriqc"

# New List of Participants (Subject IDs)
participants=(
    "sub-B1971" "sub-B2019" "sub-B2029" "sub-B2032" "sub-B2046" "sub-B2053" "sub-B2056" "sub-B2068" "sub-B2069" "sub-B2073" "sub-B2075" "sub-B2076" "sub-B2082" "sub-B2083" "sub-B2091" "sub-B2095" "sub-B2104" "sub-B2113" "sub-B2114" "sub-B2132" "sub-B2134" "sub-B2143" "sub-B2144" "sub-B2160" "sub-B2172" "sub-B2185" "sub-B2187" "sub-B2192" "sub-B2193" "sub-B2206" "sub-B2208" "sub-B2210" "sub-B2224" "sub-B2255" "sub-B2276" "sub-B2286" "sub-B2301" "sub-B2307" "sub-B2308" "sub-B2309" "sub-B2322" "sub-B2324" "sub-B2351" "sub-B2356" "sub-B2362" "sub-B2367" "sub-B2389" "sub-B2395"
)

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

echo "MRIQC processing for all participants completed."