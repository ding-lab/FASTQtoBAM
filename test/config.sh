## Arguments defined by users

### Sample name used for creating the final BAM file
sample_ID="TWAW-K1600481-cyst_5PCRga_S1_L003"
#Lane1_1="" # Name of 1st paired FASTQ file
#Lane1_2="" # Name of 2nd paired FASTQ file
Lane2_1="" # If no lane 2, leave it as ""
#Lane2_2="" # If no lane 2, leave it as ""

### Paths
input="/diskmnt/Projects/Users/yize.li/PKD/11.rm_barcode/BWA" # Path of getting the FASTQ files
output="/diskmnt/Projects/Users/yize.li/PKD/11.rm_barcode/BWA" # Path of saving the BAM files

### Reference
reference="/diskmnt/Datasets/Kidney/PKD/Longranger/refdata-GRCh38-2.1.0/fasta/genome.fa" # The reference used for alignment

### Tools (if work in Katmai, no need to make changes)
flexbar="/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/flexbar"
bwa="/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/bwa"
samtools="/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/samtools"
picard="/diskmnt/Projects/Users/yize.li/Tools/picard.jar"
