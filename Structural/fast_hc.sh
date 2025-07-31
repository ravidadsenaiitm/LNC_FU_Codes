# Define the output directory
output_dir="/Users/ravidadsena/Downloads/LNC_FU/hc/baseline/fastsurfer_stats"

# Create the output directory if it doesn't exist
mkdir -p "${output_dir}/stats_combined"

# Create a combined CSV file with header
header_written=false

# Updated list of specified subjects
subjects=("sub-B0282" "sub-B0395" "sub-B0404" "sub-B0406" "sub-B0420" "sub-B0457" "sub-B0486" "sub-B0624" "sub-B0664" 
          "sub-B0837" "sub-B0968" "sub-B1021" "sub-B1093" "sub-B1175" "sub-B1176" "sub-B1192" "sub-B1366" "sub-B1438" 
          "sub-B1521" "sub-S2243" "sub-S2245" "sub-S2765" "sub-S5166")


# List of stats files
stats_files=("aseg.stats" "aseg+DKT.stats" "cerebellum.CerebNet.stats" "brainvol.stats" "brainstem.v13.stats" 
             "lh.aparc.DKTatlas.mapped.stats" "rh.aparc.DKTatlas.mapped.stats" "wmparc.DKTatlas.mapped.stats"  
             "brainvol.stats")

# Loop through each stats file and each subject
for stats_file in "${stats_files[@]}"
do
    for subject in "${subjects[@]}"
    do
        # Run asegstats2table
        temp_file="${output_dir}/${subject}_${stats_file}_temp.csv"
        asegstats2table --subjects ${subject} --common-segs --meas volume \
                        --stats="/Users/ravidadsena/Downloads/LNC_FU/hc/baseline/fastsurfer/${subject}/stats/${stats_file}" \
                        --tablefile="${temp_file}"

        # Append to the combined CSV file
        if [ "$header_written" = false ]; then
            cat "${temp_file}" > "${output_dir}/stats_combined/${stats_file}_combined.csv"
            header_written=true
        else
            # Remove the header from the temp file and append the rest
            tail -n +2 "${temp_file}" >> "${output_dir}/stats_combined/${stats_file}_combined.csv"
        fi

        # Remove the temporary file
        rm "${temp_file}"
    done

    # Reset header flag for the next stats file
    header_written=false
done
