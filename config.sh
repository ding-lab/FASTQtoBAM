#/bin/bash

## Arguments defined by users
### Number of Lane #either 1 or 2
lane=1 # 1 by default
### Reference
reference="/diskmnt/Datasets/Kidney/PKD/Longranger/refdata-GRCh38-2.1.0/fasta/genome.fa" # The reference used for alignment, could be either hg19 or hg38

### Tools (if work in Katmai, no need to make changes)
flexbar="/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/flexbar"
bwa="/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/bwa"
samtools="/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/samtools"
picard="/diskmnt/Projects/Users/yize.li/Tools/picard.jar"
