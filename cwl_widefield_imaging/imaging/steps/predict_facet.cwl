class: CommandLineTool
cwlVersion: v1.2
id: predict_facet
label: Predict with WSClean
doc: This step subtracts all sources using WSClean.

baseCommand: python

inputs:
  - id: subtracted_ms
    type: Directory
    doc: The measurement set file used for source prediction in subtracted data.
    inputBinding:
      prefix: "--mslist"
      position: 1

  - id: model_image_folder
    type: Directory
    doc: The folder containing the model images.
    inputBinding:
      prefix: "--model_image_folder"
      position: 2

  - id: polygon_regions
    type: File
    doc: The DS9 region file that defines the facets for prediction.
    inputBinding:
      prefix: "--region"
      position: 3

  - id: h5parm
    type: File
    doc: The HDF5 file containing the solutions for prediction.
    inputBinding:
      prefix: "--h5parm_predict"
      position: 4

  - id: lofar_helpers
    type: Directory
    doc: The HDF5 file containing the solutions for prediction.

  - id: polygon_info
    type: File
    doc: csv with polygon information.

outputs:
  - id: logfile
    type: File[]
    doc: Log files from subtraction fov.
    outputBinding:
      glob: subtract_fov*.log
  - id: facet_ms
    type: Directory
    doc: MS subtracted data
    outputBinding:
      glob: sub1.2*.ms


arguments:
  - valueFrom: $( inputs.lofar_helpers.path + '/subtract/subtract_with_wsclean.py' )
  - valueFrom: --applybeam
  - valueFrom: --applycal
  - valueFrom: --forwidefield
  - valueFrom: --inverse

requirements:
  - class: StepInputExpressionRequirement
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.subtracted_ms)
        writable: true
      - entry: $(inputs.model_image_folder)
        writable: true
      - entry: $(inputs.polygon_regions)
      - entry: $(inputs.h5parm)
        writable: true
      - entry: $(inputs.polygon_info)

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
  - class: ResourceRequirement
    coresMin: 15

stdout: subtract_fov.log
stderr: subtract_fov_err.log