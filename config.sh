## Arguments defined by users

### Sample name used for creating the final BAM file
sample_ID="" # e.g. TWAW-K1600481-cyst_5PCRga
Lane1_1="" # Name of 1st paired FASTQ file e.g. TWAW-K1600481-cyst_5PCRga_S1_L003_1.fastq.gz
Lane1_2="" # Name of 2nd paired FASTQ file e.g. TWAW-K1600481-cyst_5PCRga_S1_L003_2.fastq.gz
Lane2_1="" # If no lane 2, leave it as ""; if yes, add the name e.g. K1600481-cyst_5_L004_1.fastq.gz
Lane2_2="" # If no lane 2, leave it as ""; if yes, add the name e.g. K1600481-cyst_5_L004_2.fastq.gz

### Paths
input="" # Path of getting the FASTQ files
output="" # Path of saving the BAM files

### Reference
reference="" # The reference used for alignment, could be either hg19 or hg38

### Tools (if work in Katmai, no need to make changes)
flexbar="/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/flexbar"
bwa="/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/bwa"
samtools="/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/samtools"
picard="/diskmnt/Projects/Users/yize.li/Tools/picard.jar"
