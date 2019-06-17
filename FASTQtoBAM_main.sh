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

# Lane 1
if [$Lane1_1 = ""]; then
	echo "Error: FASTQ files missing. Please double check."
else
	## Step 1: trimming: barcode and adapter removal
	/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/flexbar -u 100 -n 8 -r ${input}/${Lane1_1} -t ${output}/temp/${Lane1_1} -x 23 -z GZ &
	ln -s ${input}/${Lane1_2} ${output}/temp/${Lane1_2}.fastq.gz &

	## Step 2: mapping: hg38
	/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/bwa mem -t 8 -M ${reference} ${output}/temp/${Lane1_1}.fastq.gz ${output}/temp/${Lane1_2}.fastq.gz | /diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/samtools view -Sb - > ${output}/${Lane1_BAM}.bam
fi

# Lane 2 (if no lane 2, print out the note)
if [$Lane2_1 = ""]; then
        echo "Note: There is only one lane for this sample."
else
	## Step 1: trimming: barcode and adapter removal
	/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/flexbar -u 100 -n 8 -r ${input}/${Lane2_1} -t ${output}/temp/${Lane2_1} -x 23 -z GZ
	ln -s ${input}/${Lane2_2} ${output}/temp/${Lane2_2}.fastq.gz

	## Step 2: mapping: hg38
	/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/bwa mem -t 8 -M ${reference} ${output}/temp/${Lane2_1}.fastq.gz ${output}/temp/${Lane2_2}.fastq.gz | /diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/samtools view -Sb - > ${output}/${Lane2_BAM}.bam
fi


if [$Lane2_1 = ""]; then
	## Step 3: Sorting
	for i in ${Lane1_BAM}
	do
    	/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/samtools sort -m 40G ${output}/$i.bam -o ${output}/${sample_ID}.sorted.bam
	done

	## Step 4: Merging (if no lane 2, no need to do merging)

	## Step 5: Removing duplicates
	java -jar -Djava.io.tmpdir=${output}/temp /diskmnt/Projects/Users/yize.li/Tools/picard.jar MarkDuplicates I=${output}/${sample_ID}.sorted.bam O=${output}/${sample_ID}.sorted.marked_duplicates.bam M=${output}/marked_dup_metrics.txt REMOVE_DUPLICATES=true VALIDATION_STRINGENCY=STRICT

	## Step 6: Indexing
	/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/samtools index ${output}/${sample_ID}.sorted.marked_duplicates.bam
else
	## Step 3: Sorting
	for i in ${Lane1_BAM} ${Lane2_BAM} # if no Lane 2, comment out ${Lane2_BAM}
	do
    	/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/samtools sort -m 40G ${output}/$i.bam -o ${output}/$i.sorted.bam
	done

	## Step 4: Merging
	/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/samtools merge ${output}/${sample_ID}.sorted.bam ${output}/${Lane1_BAM}.sorted.bam ${output}/${Lane2_BAM}.sorted.bam

	## Step 5: Removing duplicates
	java -jar -Djava.io.tmpdir=${output}/temp /diskmnt/Projects/Users/yize.li/Tools/picard.jar MarkDuplicates I=${output}/${sample_ID}.sorted.bam O=${output}/${sample_ID}.sorted.marked_duplicates.bam M=${output}/marked_dup_metrics.txt REMOVE_DUPLICATES=true VALIDATION_STRINGENCY=STRICT

	## Step 6: Indexing
	/diskmnt/Projects/Users/yize.li/Tools/conda_yize/bin/samtools index ${output}/${sample_ID}.sorted.marked_duplicates.bam
fi

## Step 7: Intermediate files removal
rm *.sorted.bam
rm -r ${output}/temp
