#!/bin/bash

export SIMG=/project/lofarvwf/Software/singularity/testpatch_lofar_sksp_v3.4_cascadelake_cascadelake_avx512_mkl_cuda_ddf.sif

singularity exec -B $PWD,/project,/home/lofarvwf-jdejong/scripts $SIMG DPPP \
msin=sub6asec_L*.ms \
msin.datacolumn=DATA \
msout=TargetName_120_168MHz_averaged.ms \
msout.storagemanager=dysco \
msout.writefullresflag=False \
steps=[ps, av] \
ps.type=phaseshift \
ps.phasecenter=[01h23m45.6,12d34m56.0] \
av.type=averager \
av.freqstep=8 \
av.timestep=4