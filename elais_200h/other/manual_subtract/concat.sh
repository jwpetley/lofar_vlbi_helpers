#!/bin/bash
#SBATCH -c 10 -t 24:00:00

SIMG=$( python3 $HOME/parse_settings.py --SIMG )
SING_BIND=$( python3 $HOME/parse_settings.py --BIND )

re="L[0-9][0-9][0-9][0-9][0-9][0-9]"
if [[ $PWD =~ $re ]]; then OBSERVATION=${BASH_REMATCH}; fi

singularity exec -B $SING_BIND $SIMG python /project/wfedfn/Software/lofar_helpers/ms_helpers/concat_with_dummies.py \
--msin *sub6asec*.ms \
--time_res 8 \
--freq_res '97656.25Hz' \
--phase_center '[17h47m13.90,65d32m35.88]' \
--msout ${OBSERVATION}_DI.concat.ms
