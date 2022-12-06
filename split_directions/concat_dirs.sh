#!/bin/bash
#SBATCH -N 1 -c 1 --job-name=concat

SCRIPTS=/home/lofarvwf-jdejong/scripts/prefactor_helpers

export SIMG=/project/lofarvwf/Software/singularity/lofar_sksp_v3.4_x86-64_generic_noavx512_ddf.sif

mkdir -p sub_parsets
mv *.parset sub_parsets

singularity exec -B $PWD,/project,/home/lofarvwf-jdejong/scripts ${SIMG} python ${SCRIPTS}/split_directions/make_concat_parsets.py

for P in *.parset; do
  sbatch ${SCRIPTS}/split_directions/run_concat_parset.sh ${P}

mkdir -p concat_parsets
mv *.parset concat_parsets
