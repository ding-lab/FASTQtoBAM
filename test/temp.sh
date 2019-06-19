#!/bin/bash

java -jar /diskmnt/Projects/Users/yize.li/Tools/picard.jar AddOrReplaceReadGroups \
      I=/diskmnt/Projects/Users/yize.li/PKD/11.rm_barcode/BWA/TWAW-K1600481-cyst_5PCRga_S1_L003.sorted.bam \
      O=/diskmnt/Datasets/Kidney/PKD/Longranger/output.bam \
      RGID=4 \
      RGLB=lib1 \
      RGPL=illumina \
      RGPU=unit1 \
      RGSM=20

