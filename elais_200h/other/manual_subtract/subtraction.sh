#!/bin/bash
#SBATCH -N 1 -c 31 --job-name=subtract -t 24:00:00

echo "Job landed on $(hostname)"



SIMG=/project/wfedfn/Software/singularity/flocs_v5.1.0_znver2_znver2_test.sif
SING_BIND=$( python3 $HOME/parse_settings.py --BIND )

MS=$1


OUTPUT=$(realpath ../)
# RUNDIR=$TMPDIR/subtract_${SLURM_JOB_ID}
H5=$(realpath ../../delay_cal/DDF_merged.h5)

# mkdir $RUNDIR
cp $SIMG $PWD
# cp -r * $RUNDIR
cp $H5 $PWD

# cd $RUNDIR

echo "Applycal"
singularity exec -B ${SING_BIND} ${SIMG} python \
/project/wfedfn/Software/lofar_helpers/ms_helpers/applycal.py \
--colout DATA_DI_CORRECTED \
--h5 ${H5##*/} \
${MS}

mkdir SOLSDIR/${MS}
mv SOLSDIR/*${SB}*/* SOLSDIR/${MS}

singularity exec -B $SING_BIND ${SIMG##*/} python /home/wfedfn-jpetley/scripts/lofar_vlbi_helpers/elais_200h/ddf/fix_symlink.py

echo "SUBTRACT"
singularity exec -B $PWD,/project/wfedfn/Share/petley/output/EDFN,/tmp,/project/wfedfn/Data ${SIMG##*/} sub-sources-outside-region.py \
--boxfile boxfile.reg \
--column DATA_DI_CORRECTED \
--freqavg 1 \
--timeavg 1 \
--ncpu 24 \
--prefixname sub6asec \
--noconcat \
--keeplongbaselines \
--nophaseshift \
--chunkhours 0.5 \
--onlyuseweightspectrum \
--mslist mslist.txt \
--nofixsym

mv sub6asec* $OUTPUT

echo "SUBTRACT END"
