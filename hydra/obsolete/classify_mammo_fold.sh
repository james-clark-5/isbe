#!/bin/bash
#
matlab -nodisplay -nojvm -r "classify_mammo_fold" > logs/class_images_$JOB_ID.log$SGE_TASK_ID