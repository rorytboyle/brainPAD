function [brainPAD, subid, prediction] = getBrainPADs(niftiFolder, saveto,...
    betas, test_outcome, test_subid, training_data, int, slope)
% This function takes fully preprocessed T1 images, resizes the images to 
% 2mm^3 voxels, extracts voxelwise data, and applies parameters from a
% machine learning model to creatae a brainPAD score for each T1 scan.
%
% Requires user to load following info from training set model: 1) average
% beta weights, 2) participants' chronological age, 3) participants'
% subids, 4) voxelwise data used as model input in training set, 5)
% intercept of training set model, 6) slope of training set model
%
% INPUT:
% niftiFolder    = string containing absolute path to folder consisting of 
%                  images to be resized - make sure only images to be
%                  resized are contained in this folder as it loops through
%                  the whole folder. Output will also be saved here.
% saveto         = string containing folder in which to save extracted 
%                  voxelwise data. If folder does not exist, function will 
%                  create this folder. All data will be saved to file 
%                  called voxelwise_data_testSet.mat in the folder 
%                  specified by saveto.
% betas          = n (features) x 4 array containing avg beta weights in
%                  col 1 and MNI coords of voxel location in cols 2 (x),
%                  3 (y), 4 (z). (averaged_betas.mat from Zenodo)
% test_outcome   = array file of size m (participants) x 1 containing the 
%                  chronological age for each subject
% test_subid     = subid for each participants
% training_data  = array of size m (participants) x n (features) containing 
%                  data on which model was trained. Used here to z-score
%                  test_data (voxelwise_data.mat from Zenodo)
% int            = intercept of training set (betaInt.mat from Zenodo)
% slope          = slope of training set (training_slope.mat from Zenodo)

% SPM must be installed and following functions must be located in path:
% 1) resize_niftis.m
% 2) resize_img.m
% 3) extractTestVoxels.m
% 4) makePrediction.m

% Author: Rory Boyle rorytboyle@gmail.com
% Updated: 29/03/2019
    
%% 1) Resize .nii images
% call resize_niftis
    % resize preprocessed t1s to 2mm^3 voxels
resize_niftis(niftiFolder, [2 2 2]);

%% 2) Extract voxelwise data
% extract voxelwise data
[test_data, ~] = extractTestVoxels(niftiFolder, betas, saveto);

%% 3) Make predictions

% run MakePredictions
prediction = makePrediction(betas, test_data, test_outcome, test_subid,...
    training_data, int, slope);

%% 4) Extract brainPAD and subids
brainPAD = prediction.corrected_brainPAD
subid = prediction.test_subid
