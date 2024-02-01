#!/bin/bash

mkdir -p vlbi_workdir

#https://git.astron.nl/RD/VLBI-cwl/-/wikis/home

LINC_SOLUTIONS=target/L*_LINC_target/results_LINC_target/cal_solutions.h5
RAW_DATA=target/Data/*.MS
CSV=test.csv

mkdir -p vlbi_workdir/input
mkdir -p vlbi_workdir/output

cp $LINC_SOLUTIONS vlbi_workdir/input
#mv $RAW_DATA vlbi_workdir/input
cp $CSV vlbi_workdir/input

export INSTALL_DIR=/project/lofarvwf/Software #will contain all the necessary LOFAR software
export INPUT_DIR=vlbi_workdir/input # will contain the data to be processed, including
                                    # 1) observation data in MeasurementSet (MS) format
                                    # 2) solution tables generated by the LOFAR Initial Calibration (LINC) pipeline
                                    # 3) a catalogue containing a suitable delay calibrator in CSV format
export WORK_DIR=$PWD/vlbi_workdir #will contain the intermediate files produced during pipeline operation
export OUTPUT_DIR=vlbi_workdir/output #will contain the data products produced by the pipeline

if [ -d "${INSTALL_DIR}/vlbi" ]; then
  git pull ${INSTALL_DIR}/vlbi
else
  git clone https://git.astron.nl/RD/VLBI-cwl.git ${INSTALL_DIR}/vlbi
fi

if [ -d "${INSTALL_DIR}/lofar_helpers" ]; then
  git pull ${INSTALL_DIR}/lofar_helpers
else
  git clone https://github.com/jurjen93/lofar_helpers.git ${INSTALL_DIR}/lofar_helpers
fi

if [ -d "${INSTALL_DIR}/lofar_facet_selfcal" ]; then
  git pull ${INSTALL_DIR}/lofar_facet_selfcal
else
  git clone https://github.com/rvweeren/lofar_facet_selfcal.git ${INSTALL_DIR}/lofar_facet_selfcal
fi

if [-d "${INSTALL_DIR}/LINC"]; then
  git pull ${INSTALL_DIR}/LINC
else
  git clone https://git.astron.nl/RD/LINC ${INSTALL_DIR}/LINC
fi

source $INSTALL_DIR/vlbi/scripts/generate_input.sh $INPUT_DIR $INSTALL_DIR