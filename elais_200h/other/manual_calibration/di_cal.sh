#!/bin/bash
#SBATCH -N 1 -c 30 --job-name=dical -t 15:00:00

##########################

#UPDATE THESE
SKYMODEL=/project/wfedfn/Share/petley/output/EDFN/delay_cal_models/scaled_J174713+653236_final_model
MASK=/project/wfedfn/Share/petley/output/EDFN/delay_cal_models/J174713+653236_fits.mask.fits
FACETSELFCAL=/project/wfedfn/Software/lofar_facet_selfcal
LOFARHELPERS=/project/wfedfn/Software/lofar_helpers

##########################

NAME=$1

RUNDIR=$TMPDIR/dical_${SLURM_JOB_ID}
OUTDIR=$PWD
mkdir -p $RUNDIR

SIMG=$( python3 $HOME/parse_settings.py --SIMG )
echo "SINGULARITY IS $SIMG"

# COPY TO RUNDIR
cp $SIMG $RUNDIR
cp $SKYMODEL* $RUNDIR
cp $MASK $RUNDIR
cp -r *.ms $RUNDIR
cp -r $FACETSELFCAL $RUNDIR
mkdir $RUNDIR/lofar_helpers
cp -r $LOFARHELPERS/h5_merger.py $RUNDIR/lofar_helpers

cd $RUNDIR

# RUN SCRIPT
singularity exec -B $PWD ${SIMG##*/} python lofar_facet_selfcal/facetselfcal.py \
--imsize=1600 \
-i DI_${NAME} \
--pixelscale=0.075 \
--uvmin=40000 \
--robust=-1.5 \
--uvminim=1500 \
--channelsout=12 \
--fitspectralpol=9 \
--wscleanskymodel=${SKYMODEL##*/} \
--fitsmask=${MASK##*/} \
--soltype-list="['scalarphasediff','scalarphase','scalarphase','scalarcomplexgain','scalarcomplexgain','scalarcomplexgain','fulljones']" \
--soltypecycles-list="[0,0,0,1,1,1,3]" \
--solint-list="['4min','32s','32s','15min','4min','2hr','10min']" \
--nchan-list="[1,1,1,1,1,1]" \
--smoothnessconstraint-list="[15.0,1.5,10.0,10.0,30.0,2.0,3.0]" \
--normamps=False \
--smoothnessreffrequency-list="[120.,120.,120.,0.,0.,0.,0.]" \
--smoothnessspectralexponent-list="[-2,-1,-1,0,0,0,0]" \
--antennaconstraint-list="['core',None,None,None,None,'alldutch']" \
--forwidefield \
--multiscale \
--avgfreqstep='488kHz' \
--avgtimestep='32s' \
--docircular \
--skipbackup \
--uvminscalarphasediff=0 \
--makeimage-ILTlowres-HBA \
--makeimage-fullpol \
--resetsols-list="[None,'alldutch','core',None,None,None]" \
--stop=7 \
--fix-model-frequencies \
*.ms

#Optional
#--aoflagger

# OUTPUT
rm -rf lofar_facet_selfcal
rm -rf lofar_helpers
rm -rf *.ms
rm *-000?-*
cp -r * $OUTDIR
