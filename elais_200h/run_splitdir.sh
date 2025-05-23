#!/bin/bash
#SBATCH --output=splitdir_%j.out
#SBATCH --error=splitdir_%j.err
#SBATCH -t 72:00:00

CSV=$1

######################
#### UPDATE THESE ####
######################

export TOIL_SLURM_ARGS="--export=ALL -t 12:00:00"

SING_BIND="/project,/project/wfedfn/Software,/project/wfedfn/Share,/project/wfedfn/Public"
CAT=${CSV}
if [[ $PWD =~ L[0-9]{6} ]]; then LNUM=${BASH_REMATCH[0]}; fi
SOLSET=/project/wfedfn/Data/${LNUM}/delay_cal/dical/merged_selfcalcyle006_linearfulljones_${LNUM}_DI.concat.ms.avg.h5
CONFIG=/project/wfedfn/Share/petley/output/EDFN/delaysolve_config.txt
DD_SELECTION="true" #or true?

VENV=/project/wfedfn/Software/venv

SUBTRACTDATA=$(realpath "../../subtract")

######################
######################

# SETUP ENVIRONMENT

# set up software
source ${VENV}/bin/activate
#pip install --user toil[cwl]

mkdir -p software
cd software
git clone https://git.astron.nl/RD/VLBI-cwl.git VLBI_cwl
git clone https://github.com/tikk3r/flocs.git
git clone https://github.com/jurjen93/lofar_helpers.git
git clone https://github.com/rvweeren/lofar_facet_selfcal.git
git clone https://git.astron.nl/RD/LINC.git

mkdir scripts
cp LINC/scripts/* scripts
cp VLBI_cwl/scripts/* scripts
SCRIPTS_PATH=$PWD/scripts
chmod 755 ${SCRIPTS_PATH}/*
SING_BIND=${SING_BIND}",${SCRIPTS_PATH}:/opt/lofar/DynSpecMS"
PYPATH=${PWD}/VLBI_cwl/scripts:${PWD}/LINC/scripts:\$PYTHONPATH
PTH=${PWD}/VLBI_cwl/scripts:${PWD}/LINC/scripts:\$PATH
cd ../

# set up singularity
SIMG=flocs_v5.6.0_sandybridge_sandybridge.sif
mkdir -p singularity
wget https://public.spider.surfsara.nl/project/lofarvwf/fsweijen/containers/${SIMG} -O singularity/$SIMG
mkdir -p singularity/pull
cp singularity/$SIMG singularity/pull/$SIMG

export LINC_DATA_ROOT=$PWD/software/LINC
export VLBI_DATA_ROOT=$PWD/software/VLBI_cwl

export APPTAINER_CACHEDIR=$PWD/singularity
export CWL_SINGULARITY_CACHE=$APPTAINER_CACHEDIR
export APPTAINERENV_LINC_DATA_ROOT=$LINC_DATA_ROOT
export APPTAINERENV_VLBI_DATA_ROOT=$VLBI_DATA_ROOT
export APPTAINERENV_PREPEND_PATH=$LINC_DATA_ROOT/scripts:$VLBI_DATA_ROOT/scripts
export APPTAINERENV_PYTHONPATH=$VLBI_DATA_ROOT/scripts:$LINC_DATA_ROOT/scripts:\$PYTHONPATH
export APPTAINER_BIND=$SING_BIND
export TOIL_CHECK_ENV=True

########################

singularity exec singularity/$SIMG \
python software/flocs/runners/create_ms_list.py \
VLBI \
split-directions \
--configfile=$CONFIG \
--h5merger=$PWD/software/lofar_helpers \
--selfcal=$PWD/software/lofar_facet_selfcal \
--do_selfcal=false \
--image_cat=$CAT \
--linc=$PWD/software/LINC \
--delay_solset=$SOLSET \
--ms_suffix ".ms" \
$SUBTRACTDATA

#SELECTION WAS ALREADY DONE
if [ "$DD_SELECTION" = "true" ]; then
  jq --arg dd_selection "$DD_SELECTION" '. + {dd_selection: true}' mslist_VLBI_split_directions.json > temp.json && mv temp.json mslist_VLBI_split_directions.json
fi
########################

# MAKE TOIL RUNNING STRUCTURE

# make folder for running toil
WORKDIR=$PWD/workdir
OUTPUT=$PWD/outdir
JOBSTORE=$PWD/jobstore
LOGDIR=$PWD/logs
TMPD=$PWD/tmpdir

mkdir -p $WORKDIR
mkdir -p $OUTPUT
mkdir -p $LOGDIR

#source ${VENV}/bin/activate

########################

# RUN TOIL

toil-cwl-runner \
--no-read-only \
--retryCount 2 \
--singularity \
--disableCaching \
--logFile full_log.log \
--writeLogs ${LOGDIR} \
--outdir ${OUTPUT} \
--tmp-outdir-prefix ${TMPD}/ \
--jobStore ${JOBSTORE} \
--workDir ${WORKDIR} \
--disableAutoDeployment True \
--bypass-file-store \
--batchSystem slurm \
--cleanWorkDir onSuccess \
--setEnv PATH=$VLBI_DATA_ROOT/scripts:$LINC_DATA_ROOT/scripts:\$PATH \
--setEnv PYTHONPATH=$VLBI_DATA_ROOT/scripts:$LINC_DATA_ROOT/scripts:\$PYTHONPATH \
software/VLBI_cwl/workflows/split-directions.cwl mslist_VLBI_split_directions.json

########################

deactivate
