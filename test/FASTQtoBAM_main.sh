#!/bin/bash

#######################################################################################################
################################################# Y Li ################################################
######################## Date: 08/15/2018 (Initiation); 06/17/2019 (Revision) #########################
################ FASTQ to BAM  pipeline on Katmai (regular WES, WGS, 10X WES/WGS etc) #################
#######################################################################################################

# This script can be used to generate BAMs based on the corresponding FASTQ files.  There are multiple steps including trimming, alignment, sorting, merging, removing duplicates and indexing the BAMs. Users can specific the input and output path (script can be saved in anywhere to run).
# E.g. Here it is used to generate the MMY 10X WGS BAMs (hg38) in Katmai
# Run the job as nohup bash FASTQtoBAM_main.sh 1>sampleID.err 2>sampleID.log &

#######################################################################################################
# Argumments set by the users in config.sh
source config.sh

# Create a temp folder which will be used in Step 5 (Picard)
mkdir ${output}/temp

if [$Lane2_1 = ""]; then
	## Step 5: Removing duplicates
	java -jar -Djava.io.tmpdir=${output}/temp ${picard} MarkDuplicates AddOrReplaceReadGroups I=${output}/${sample_ID}.sorted.bam O=${output}/output/${sample_ID}.sorted.marked_duplicates.bam M=${output}/marked_dup_metrics.txt REMOVE_DUPLICATES=true VALIDATION_STRINGENCY=STRICT

	## Step 6: Indexing
	${samtools} index ${output}/output/${sample_ID}.sorted.marked_duplicates.bam
else
	## Step 3: Sorting
	for i in ${Lane1_BAM} ${Lane2_BAM} # if no Lane 2, comment out ${Lane2_BAM}
	do
    	${samtools} sort -m 40G ${output}/$i.bam -o ${output}/$i.sorted.bam
	done

	## Step 4: Merging
	${samtools} merge ${output}/${sample_ID}.sorted.bam ${output}/${Lane1_BAM}.sorted.bam ${output}/${Lane2_BAM}.sorted.bam

	## Step 5: Removing duplicates
	java -jar -Djava.io.tmpdir=${output}/temp ${picard} MarkDuplicates AddOrReplaceReadGroups I=${output}/${sample_ID}.sorted.bam O=${output}/${sample_ID}.sorted.marked_duplicates.bam M=${output}/marked_dup_metrics.txt REMOVE_DUPLICATES=true VALIDATION_STRINGENCY=STRICT

	## Step 6: Indexing
	${samtools} index ${output}/${sample_ID}.sorted.marked_duplicates.bam
fi

## Step 7: Intermediate files removal
#rm *.sorted.bam
#rm -r ${output}/temp
