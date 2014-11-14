#!/bin/bash

#
# == Set SGE options:
#

#$ -S /bin/bash
#$ -cwd
  #
  # -- ensure BASH is used, no matter what the queue config;
  # -- run the job in the current-working-directory;
  # -- submit the job to the "serial.q" queue;
  #

#
# == The job itself :
#

echo " "
echo "Job ran on and started at: "
/bin/hostname
/bin/date
echo " "

export PATH=$PATH:/software/apps/binapps/matlab/R2010a/bin/
  #
  # ...ensure matlab is on our PATH...
  #

matlab -nodisplay -nojvm -r "k_maps_script($SGE_TASK_ID)" > logs/k_maps_script$JOB_ID.log$SGE_TASK_ID
  #
  # ...run matlab

echo " "
echo "Job finished at: "
/bin/date