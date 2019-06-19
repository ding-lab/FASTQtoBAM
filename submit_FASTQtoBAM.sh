#!/bin/bash

while read sample_ID input output Lane1_1 Lane1_2 Lane2_1 Lane2_2; do
    bash run_FASTQtoBAM.sh -n ${sample_ID} -i ${input} -o ${output} -a ${Lane1_1} -b ${Lane1_2} -c ${Lane2_1} -d ${Lane2_2}
done <datamap
