#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_bam_file> <output_directory>"
    exit 1
fi

# Assign input arguments to variables
input_bam=$1
output_dir=$2

# Check if input BAM file exists
if [ ! -f "$input_bam" ]; then
    echo "Error: BAM file '$input_bam' does not exist."
    exit 1
fi

# Check if output directory exists, create it if not
if [ ! -d "$output_dir" ]; then
    echo "Warning: Output directory '$output_dir' does not exist. Creating it now."
    mkdir -p "$output_dir"
fi

# Initialize Conda
source /vol/opt/CCDC/ccdc-software/csd-python-api/miniconda/etc/profile.d/conda.sh

# Create conda environment if it doesn't exist
conda env create -f environment.yml -n bam2bed 2>/dev/null

# Activate Conda environment
conda activate bam2bed

# Convert BAM to BED using bedtools bamtobed
echo "Converting BAM to BED..."
bed_file="${output_dir}/$(basename "${input_bam}" .bam).bed"
bedtools bamtobed -i "$input_bam" > "$bed_file"

# Check if conversion was successful
if [ $? -ne 0 ]; then
    echo "Error: BAM to BED conversion failed."
    exit 1
fi

# Filter BED file for chromosome 1 using regex (assuming chromosome 1 is labeled as '1' in the file)
echo "Filtering BED file for chromosome 1..."
filtered_bed="${output_dir}/$(basename "${input_bam}" .bam)_chr1.bed"
grep -P "^Chr1\t" "$bed_file" > "$filtered_bed"

# Check if filtering was successful
if [ $? -ne 0 ]; then
    echo "Error: Filtering failed."
    exit 1
fi

# Count the number of lines in the filtered BED file and save to bam2bed_number_of_rows.txt
echo "Counting the number of lines in the filtered BED file..."
wc -l "$filtered_bed" > "${output_dir}/bam2bed_number_of_rows.txt"

# Check if counting was successful
if [ $? -ne 0 ]; then
    echo "Error: Counting the number of lines failed."
    exit 1
fi

# End the script with printing your name
echo "Script executed successfully. My name is Guyon."
