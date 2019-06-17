# FASTQtoBAM

## Overview

* This pipeline can generate regular WES, WGS, 10x WES/WGS BAMs from the corresponding FASTQ files (1 lane or 2 lanes). It was originally developed for generating the MMY 10X WGS BAMs (hg38) in Katmai. 

* There are multiple steps including trimming, alignment, sorting, merging, removing duplicates and indexing the BAMs. Users can specific the input and output path.

* Source code is freely available at https://github.com/ding-lab/FASTQtoBAM.git, distributed under the GNU GPLv3 license, implemented in R, Python, Perl, and Bash, and supported on Unix/Linux/OS X operating systems.

* Run the job as nohup bash FASTQtoBAM_main.sh 1>sample_ID.err 2>sample_ID.log &

## Installation

### Prerequisition
* flexbar
* bwa
* samtools
* reference genome
* Note: if work in Katmai, tools have been installed and defined in the main script.
```git clone https://github.com/ding-lab/FASTQtoBAM.git
```
```cd FASTQtoBAM
```

## Steps

* Trimming (flexbar): barcode and adapter removal.

* Read mapping (bwa & samtools): align the reads to the reference genome (user can define the reference (hg19/hg38) in the config.sh).

* Sorting (samtools): sort the intermediate BAM files.

* Merging (samtools): merge the intermediate BAM files if there are two lanes from the sample (will be skipped if there is only one lane).

* Removing duplicates (samtools): remove duplicates and generate the final BAM files.

* Indexing (samtools): create index.

* Intermediate files removal.

## Contact
* Yize Li, yize.li@wustl.edu

## License
* This software is licensed under the GNU General Public License v3.0.
