# brainPAD
Predict brain age and calculate brain-predicted age difference scores from T1 MRIs

   

Relevant parameters (e.g. beta weights, training set intercept, training set slope, and training set voxelwise data - for z-scoring) are available for request from Zenodo through the following link: https://doi.org/10.5281/zenodo.2819646

Steps:

    1) Run auto_reorient.m

    2) Visually inspect orientation and check for artefacts

        a) Manually reorient poorly oriented images and discard images with artefacts
        OR
        b) Discard images with poor orientation and artefacts

    3) Run complete_SPM_preprocessing_job.m

    4) Visually QC/inspect preprocessed grey matter images for segmentation
    
    5) Load all smwc*.nii files into a new single folder
    
    6) Download model parameters from Zenodo https://doi.org/10.5281/zenodo.2819646 and load into MATLAB workspace
    
    7) Run getBrainPADs.m


The following must be added to your MATLAB path for this code to work:

    1) SPM
    2) all code downloaded from this repository
    
