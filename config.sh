## Arguments defined by users

### Sample name used for creating the final BAM file
sample_ID=""
Lane1_1="" # Name of 1st paired FASTQ file
Lane1_2="" # Name of 2nd paired FASTQ file
Lane2_1="" # If no lane 2, leave it as ""
Lane2_2="" # If no lane 2, leave it as ""

### Paths
input="" # Path of getting the FASTQ files
output="" # Path of saving the BAM files

### Reference
reference="" # The reference used for alignment

### Tools (if work in Katmai, no need to make changes)
flexbar="/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/flexbar"
bwa="/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/bwa"
samtools="/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/samtools"
