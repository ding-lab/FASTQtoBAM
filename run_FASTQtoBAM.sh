#!/bin/bash

#######################################################################################################
################################################# Y Li ################################################
######################## Date: 08/15/2018 (Initiation); 06/19/2019 (Revision) #########################
################ FASTQ to BAM  pipeline on Katmai (regular WES, WGS, 10X WES/WGS etc) #################
#######################################################################################################

# This script can be used to generate BAMs based on the corresponding FASTQ files.  There are multiple steps including trimming, alignment, sorting, merging, removing duplicates and indexing the BAMs. Users can specific the input and output path (script can be saved in anywhere to run).
# E.g. Here it is used to generate the MMY 10X WGS BAMs (hg38) in Katmai
# Run the job as nohup bash FASTQtoBAM_main.sh 1>sampleID.err 2>sampleID.log &

#######################################################################################################

while getopts ":n:i:o:a:b:c:d:" opt; do
  case $opt in
    n) # value argument
      sample_ID=$OPTARG
      >&2 echo "Sample ID: $sample_ID "
      ;;
    i) # value argument
      input=$OPTARG
      >&2 echo "Input directory: $input "
      ;;
    o) # value argument
      output=$OPTARG
      >&2 echo "Output directory: $output "
      ;;
    a) # value argument
      Lane1_1=$OPTARG
      >&2 echo "Lane 1 input file 1: $Lane1_1 "
      ;;
    b) # value argument
      Lane1_2=$OPTARG
      >&2 echo "Lane 1 input file 2: $Lane1_2 "
      ;;
    c) # value argument
      Lane2_1=$OPTARG
      >&2 echo "Lane 2 input file 1: $Lane2_1 "
      ;;
    d) # value argument
      Lane2_2=$OPTARG
      >&2 echo "Lane 2 input file 2: $Lane2_2 "
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

# Argumments set by the users in config.sh
source config.sh

# Create a temp folder which will be used in Step 5 (Picard)
if [ ! -d "${output}/temp" ]; then
    mkdir ${output}/temp # Need to create the output folder before running FastQC (such as ./outputs/C3L-00104/)
fi

# Pre-alignment steps
## Lane 1
if [ ${lane} = 1 ]; then
  echo "Note: There is only one lane for this sample."
  ## Step 1: trimming: barcode and adapter removal
  Lane1_1_name=$(echo $Lane1_1 | cut -d"." -f1)
  ${flexbar} -u 100 -n 8 -r ${input}/${Lane1_1} -t ${output}/temp/${Lane1_1_name} -x 23 -z GZ
  ln -s ${input}/${Lane1_2} ${output}/temp/${Lane1_2}

  ## Step 2: mapping: hg38
  ### Add Read group information: Read group information is typically added during this step, but can also be added or modified after mapping using Picard AddOrReplaceReadGroups.
  for R1 in ${Lane1_1}; do
          SM=$(echo $R1 | cut -d"_" -f1)                                          ##sample ID
          LB=$(echo $R1 | cut -d"_" -f1,2)                                        ##library ID
          PL="Illumina"                                                           ##platform (e.g. illumina, solid)
          RGID=$(zcat ${output}/temp/${R1} | head -n1 | sed 's/:/_/g' |cut -d "_" -f1,2,3,4)       ##read group identifier
          PU=$RGID.$LB                                                            ##Platform Unit
          echo -e "@RG\tID:$RGID\tSM:$SM\tPL:$PL\tLB:$LB\tPU:$PU"

          R2=$(echo $R1 | sed 's/_R1_/_R2_/')
          echo $R1 $R2

          ### Mapping
          ${bwa} mem -t 8 -M -R "@RG\tID:$RGID\tSM:$SM\tPL:$PL\tLB:$LB\tPU:$PU" ${reference} ${output}/temp/${R1} ${output}/temp/${R2} | ${samtools} view -Sb - > ${output}/temp/${LB}.bam
  done

else
        if [ ${lane} = 2 ]; then
                echo "Note: There are two lanes for this sample. Merging step (step 4) will be processed."
        else
                echo "Error: Wrong number of lanes (at least one lane). Please double check."
  fi
fi

## Lane 2 (if no lane 2, print out the note)
if [ ${lane} = 2 ]; then
  echo "Note: There are two lanes for this sample. Merging step (step 4) will be processed."
  ## Step 1: trimming: barcode and adapter removal
  Lane1_1_name=$(echo $Lane1_1 | cut -d"." -f1)
  ${flexbar} -u 100 -n 8 -r ${input}/${Lane1_1} -t ${output}/temp/${Lane1_1_name} -x 23 -z GZ
  ln -s ${input}/${Lane1_2} ${output}/temp/${Lane1_2}

  Lane2_1_name=$(echo $Lane2_1 | cut -d"." -f1)
  ${flexbar} -u 100 -n 8 -r ${input}/${Lane2_1_name} -t ${output}/temp/${Lane2_1_name} -x 23 -z GZ
  ln -s ${input}/${Lane2_2} ${output}/temp/${Lane2_2}.fastq.gz

  ## Step 2: mapping: hg38
  ### Add Read group information
  for R1 in ${Lane1_1}; do
          SM=$(echo $R1 | cut -d"_" -f1)                                          ##sample ID
          LB1=$(echo $R1 | cut -d"_" -f1,2)                                        ##library ID
          PL="Illumina"                                                           ##platform (e.g. illumina, solid)
          RGID=$(zcat $R1 | head -n1 | sed 's/:/_/g' |cut -d "_" -f1,2,3,4)       ##read group identifier
          PU=$RGID.$LB                                                            ##Platform Unit
          echo -e "@RG\tID:$RGID\tSM:$SM\tPL:$PL\tLB:$LB1\tPU:$PU"

          R2=$(echo $R1 | sed 's/_R1_/_R2_/')
          echo $R1 $R2

          ### Mapping
          ${bwa} mem -t 8 -M -R "@RG\tID:$RGID\tSM:$SM\tPL:$PL\tLB1:$LB\tPU:$PU" ${reference} ${output}/temp/$R1 ${output}/temp/$R2 | ${samtools} view -Sb - > ${output}/temp/${LB1}.bam
          #${bwa} mem -t 8 -M ${reference} ${output}/temp/${Lane2_1}.fastq.gz ${output}/temp/${Lane2_2}.fastq.gz | ${samtools} view -Sb - > ${output}/${Lane2_BAM}.bam
  done

  for R1 in ${Lane2_1}; do
          SM=$(echo $R1 | cut -d"_" -f1)                                          ##sample ID
          LB2=$(echo $R1 | cut -d"_" -f1,2)                                        ##library ID
          PL="Illumina"                                                           ##platform (e.g. illumina, solid)
          RGID=$(zcat $R1 | head -n1 | sed 's/:/_/g' |cut -d "_" -f1,2,3,4)       ##read group identifier
          PU=$RGID.$LB                                                            ##Platform Unit
          echo -e "@RG\tID:$RGID\tSM:$SM\tPL:$PL\tLB:$LB2\tPU:$PU"

          R2=$(echo $R1 | sed 's/_R1_/_R2_/')
          echo $R1 $R2

          ### Mapping
          ${bwa} mem -t 8 -M -R "@RG\tID:$RGID\tSM:$SM\tPL:$PL\tLB2:$LB\tPU:$PU" ${reference} ${output}/temp/$R1 ${output}/temp/$R2 | ${samtools} view -Sb - > ${output}/temp/${LB2}.bam
          #${bwa} mem -t 8 -M ${reference} ${output}/temp/${Lane2_1}.fastq.gz ${output}/temp/${Lane2_2}.fastq.gz | ${samtools} view -Sb - > ${output}/${Lane2_BAM}.bam
  done

else
        if [ ${lane} = 1 ]; then
                echo "Note: There is one lane for this sample. Merging step (step 4) will be skipped."
        else
                echo "Error: Wrong number of lanes (either one or two lanes). Please double check."
  fi
fi

# Post-alignment steps
if [ ${lane} = 1 ]; then
  ## Step 3: Sorting
  for i in ${LB}
  do
      ${samtools} sort -m 40G ${output}/temp/$i.bam -o ${output}/temp/${sample_ID}.sorted.bam
  done

  ## Step 4: Merging (if no lane 2, no need to do merging)
  ## Skipped

  ## Optional: Add read group here
  #java -jar ${picard} AddOrReplaceReadGroups I=${output}/${sample_ID}.sorted.bam O=${output}/${sample_ID}.sorted.addRG.bam RGID=${sample_ID} RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=${sample_ID}

  ## Step 5: Marking duplicates (--REMOVE_DUPLICATES. If true do not write duplicates to the output file instead of writing them with appropriate flags set)
  java -jar -Djava.io.tmpdir=${output}/temp ${picard} MarkDuplicates I=${output}/temp/${sample_ID}.sorted.bam O=${output}/${sample_ID}.sorted.marked_duplicates.bam M=${output}/marked_dup_metrics.${sample_ID}.txt REMOVE_DUPLICATES=false VALIDATION_STRINGENCY=STRICT

  ## Step 6: Indexing
  ${samtools} index ${output}/${sample_ID}.sorted.marked_duplicates.bam

elif [ ${lane} = 2 ]; then
  ## Step 3: Sorting
  for i in ${LB1} ${LB2} 
  do
      ${samtools} sort -m 40G ${output}/temp/$i.bam -o ${output}/temp/$i.sorted.bam
  done

  ## Step 4: Merging
  ${samtools} merge ${output}/temp/${sample_ID}.sorted.bam ${output}/temp/${LB1}.sorted.bam ${output}/temp/${LB2}.sorted.bam

  ## Step 5: Marking duplicates (--REMOVE_DUPLICATES. If true do not write duplicates to the output file instead of writing them with appropriate flags set)
  java -jar -Djava.io.tmpdir=${output}/temp ${picard} MarkDuplicates I=${output}/temp/${sample_ID}.sorted.bam O=${output}/${sample_ID}.sorted.marked_duplicates.bam M=${output}/marked_dup_metrics.${sample_ID}.txt REMOVE_DUPLICATES=false VALIDATION_STRINGENCY=STRICT

  ## Step 6: Indexing
  ${samtools} index ${output}/${sample_ID}.sorted.marked_duplicates.bam
else
  echo "Note: Post-alignment steps were not processed due to wrong number of lanes."
fi

## Step 7: Intermediate files removal (sorted BAM, etc)
rm -r ${output}/temp
