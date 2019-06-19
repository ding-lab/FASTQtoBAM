#!/bin/bash

java -jar -Djava.io.tmpdir=/diskmnt/Datasets/Kidney/PKD/Longranger/temp /diskmnt/Projects/Users/yize.li/Tools/picard.jar MarkDuplicates I=/diskmnt/Datasets/Kidney/PKD/Longranger/output.bam O=/diskmnt/Datasets/Kidney/PKD/Longranger/output.sorted.marked_duplicates.bam M=/diskmnt/Datasets/Kidney/PKD/Longranger/marked_dup_metrics.txt REMOVE_DUPLICATES=true VALIDATION_STRINGENCY=STRICT
