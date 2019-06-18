#!/bin/bash

#######################################################################################################
################################################# Y Li ################################################
######################## Date: 08/15/2018 (Initiation); 06/18/2019 (Revision) #########################
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

# Pre-alignment steps
## Lane 1
if [$Lane1_1 = ""]; then
	echo "Error: FASTQ files missing (at least one lane). Please double check."
else
	## Step 1: trimming: barcode and adapter removal
	${flexbar} -u 100 -n 8 -r ${input}/${Lane1_1} -t ${output}/temp/${Lane1_1} -x 23 -z GZ &
	ln -s ${input}/${Lane1_2} ${output}/temp/${Lane1_2}.fastq.gz &

	## Step 2: mapping: hg38
	### Add Read group information: Read group information is typically added during this step, but can also be added or modified after mapping using Picard AddOrReplaceReadGroups.
	for R1 in ${Lane1_1};do
    		SM=$(echo $R1 | cut -d"_" -f1)                                          ##sample ID
    		LB=$(echo $R1 | cut -d"_" -f1,2)                                        ##library ID
    		PL="Illumina"                                                           ##platform (e.g. illumina, solid)
    		RGID=$(zcat $R1 | head -n1 | sed 's/:/_/g' |cut -d "_" -f1,2,3,4)       ##read group identifier 
    		PU=$RGID.$LB                                                            ##Platform Unit
    		echo -e "@RG\tID:$RGID\tSM:$SM\tPL:$PL\tLB:$LB\tPU:$PU"

    		R2=$(echo $R1 | sed 's/_R1_/_R2_/')
    		echo $R1 $R2
		### Mapping
    		${bwa} mem -t 8 -M -R "@RG\tID:$RGID\tSM:$SM\tPL:$PL\tLB:$LB\tPU:$PU" ${reference} ${output}/temp/$R1 ${output}/temp/$R2 | ${samtools} view -Sb - > ${output}/${Lane1_BAM}.bam
  	done
fi

## Lane 2 (if no lane 2, print out the note)
if [$Lane2_1 = ""]; then
        echo "Note: There is only one lane for this sample."
else
	echo "Note: There are two lanes for this sample. Merging step (step 4) will be processed."
	## Step 1: trimming: barcode and adapter removal
	${flexbar} -u 100 -n 8 -r ${input}/${Lane2_1} -t ${output}/temp/${Lane2_1} -x 23 -z GZ
	ln -s ${input}/${Lane2_2} ${output}/temp/${Lane2_2}.fastq.gz

	#${bwa} mem -t 8 -M ${reference} ${output}/temp/${Lane2_1}.fastq.gz ${output}/temp/${Lane2_2}.fastq.gz | ${samtools} view -Sb - > ${output}/${Lane2_BAM}.bam
        ## Step 2: mapping: hg38
        ### Add Read group information
        for R1 in ${Lane1_1};do
                SM=$(echo $R1 | cut -d"_" -f1)                                          ##sample ID
                LB=$(echo $R1 | cut -d"_" -f1,2)                                        ##library ID
                PL="Illumina"                                                           ##platform (e.g. illumina, solid)
                RGID=$(zcat $R1 | head -n1 | sed 's/:/_/g' |cut -d "_" -f1,2,3,4)       ##read group identifier
                PU=$RGID.$LB                                                            ##Platform Unit
                echo -e "@RG\tID:$RGID\tSM:$SM\tPL:$PL\tLB:$LB\tPU:$PU"

                R2=$(echo $R1 | sed 's/_R1_/_R2_/')
                echo $R1 $R2
                ### Mapping
                ${bwa} mem -t 8 -M -R "@RG\tID:$RGID\tSM:$SM\tPL:$PL\tLB:$LB\tPU:$PU" ${reference} ${output}/temp/$R1 ${output}/temp/$R2 | ${samtools} view -Sb - > ${output}/${Lane1_BAM}.bam
        done
fi

# Post-alignment steps
if [$Lane2_1 = ""]; then
	## Step 3: Sorting
	for i in ${Lane1_BAM}
	do
    	${samtools} sort -m 40G ${output}/$i.bam -o ${output}/${sample_ID}.sorted.bam
	done

	## Step 4: Merging (if no lane 2, no need to do merging)
	## Skipped

	## Optional: Add read group here
	#java -jar ${picard} AddOrReplaceReadGroups I=${output}/${sample_ID}.sorted.bam O=${output}/${sample_ID}.sorted.addRG.bam RGID=${sample_ID} RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=${sample_ID}

	## Step 5: Removing duplicates
	java -jar -Djava.io.tmpdir=${output}/temp ${picard} MarkDuplicates I=${output}/${sample_ID}.sorted.bam O=${output}/${sample_ID}.sorted.marked_duplicates.bam M=${output}/marked_dup_metrics.txt REMOVE_DUPLICATES=true VALIDATION_STRINGENCY=STRICT

	## Step 6: Indexing
	${samtools} index ${output}/${sample_ID}.sorted.marked_duplicates.bam
else
	## Step 3: Sorting
	for i in ${Lane1_BAM} ${Lane2_BAM} # if no Lane 2, comment out ${Lane2_BAM}
	do
    	${samtools} sort -m 40G ${output}/$i.bam -o ${output}/$i.sorted.bam
	done

	## Step 4: Merging
	${samtools} merge ${output}/${sample_ID}.sorted.bam ${output}/${Lane1_BAM}.sorted.bam ${output}/${Lane2_BAM}.sorted.bam

	## Step 5: Removing duplicates
	java -jar -Djava.io.tmpdir=${output}/temp ${picard} MarkDuplicates I=${output}/${sample_ID}.sorted.bam O=${output}/${sample_ID}.sorted.marked_duplicates.bam M=${output}/marked_dup_metrics.txt REMOVE_DUPLICATES=true VALIDATION_STRINGENCY=STRICT

	## Step 6: Indexing
	${samtools} index ${output}/${sample_ID}.sorted.marked_duplicates.bam
fi

## Step 7: Intermediate files removal
rm *.sorted.bam
rm -r ${output}/temp
