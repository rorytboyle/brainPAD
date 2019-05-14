function [extracted_test_data, volNames] = extractTestVoxels(nifti_folder, betas, saveto)
% This function extracts voxelwise data from .nii images in a held out test
% set and returns only the voxels that were extracted in the training set
%
% INPUT:
% nifti_folder  = string containing absolute path to folder containing
%                 niftis. This folder must only contain niftis.
% betas         = n (features) x 4 array containing avg beta weights in
%                 col 1 and MNI coords of voxel location in cols 2 (x),
%                 3 (y), 4 (z). Created from training ML model.
% saveto        = string containing folder in which to save output. If
%                 folder does not exist, function will create this folder.
%                 All data will be saved to file called 
%                 voxelwise_data_testSet.mat in the folder specified by
%                 saveto
%
% OUTPUT:
% extracted_test_data   = nfeatures x nparticipants array of voxelwise data
%                         for each participant in test set
% volNames              = 1 x nparticipants cell array containing filenames
%                         of each participants T1 scan

% Author: Rory Boyle rorytboyle@gmail.com
% Date: 28/03/2019
%% 1. Clean and parse input
% check niftis is a valid directory
if ~isfolder(nifti_folder)
    error('Please enter, as a string, a valid path to your folder of nifti images')
end

% check betas
if ~isnumeric(betas) | min(size(betas)) ~= 4
    error('Please enter a nfeatures(voxels) x 4 array of avg beta weights and MNI coordinates from your training set')
end
% check saveto is a valid string
if ~ischar(saveto)
    error('Please enter, as a string, a valid directory to save output to')
end
% create directory if saveto is not already a directory
if ~isfolder(saveto)
    mkdir(saveto);
end

%% 2. Load niftis and get filenames
% load niftis
cd(nifti_folder)
file_list = dir('*.nii');
cd(saveto)

% check niftis contains niftis images 
if isempty(file_list)
    error('The folder provided does not contain any nifti (.nii) images. Please call the function with the correct folder.')
end

% get number of nifti images (to use in for loops)
num_ims = length(file_list);

% create volNames
volNames = cell(size(file_list)); %preallocation

for i=1:num_ims
    volNames{i} = [file_list(i).folder filesep file_list(i).name];
end

clear file_list


%% 3. extract all voxelwise data from test set
% read in header info of nifti images
V = spm_vol(volNames);

% create matrix to store values of all nifti images
Y = zeros(V{1,1}.dim(1), V{1,1}.dim(2), V{1,1}.dim(3), length(volNames));

% create matrix to store coordinates of all nifti images 
XYZmm = zeros(3, prod(V{1,1}.dim), 1);

% Loop through images, read them in and store values in Y and coords in XYZmm 
for i=1:length(volNames)
    if i == 1
        [Y(:,:,:,i),XYZmm(:,:,i)] = spm_read_vols(V{i});
    else
        Y(:,:,:,i) = spm_read_vols(V{i});
    end
end


%% 4. from all voxelwise data, select only data from the same MNI coordinates as training set
% extract MNI coords from training data
trainMNI = betas(:,2:4);

% reshape Y into voxels x num_ims matrix - should be same length as XYZmm
newY = reshape(Y,[], num_ims);
XYZmm = XYZmm';
if length(newY) ~= length(XYZmm)
    error('Length of reshape voxels does not equal number of MNI coordinates for the extract voxelwise data')
end

% find shared coords
[commonMNI, indexXYZmm, ~] = intersect(XYZmm, trainMNI, 'rows');

% index into reshaped voxel mx (newY)
unsorted_test_data = zeros(length(trainMNI), num_ims);
for ppt = 1:num_ims
    current_ppt = newY(:,ppt);
    unsorted_test_data(:,ppt) = current_ppt(indexXYZmm);
end

% Find where coords in common MNI are in train MNI - then add in voxel
% values in the order according to these indices
[~, loc] = ismember(commonMNI, trainMNI, 'rows');

extracted_test_data = zeros(size(unsorted_test_data));

for row = 1:length(trainMNI)
    extracted_test_data(loc(row),:) = unsorted_test_data(row,:);
end

%% 5. Save output
volNames = volNames';
save('voxelwise_data_testSet.mat', 'extracted_test_data', 'volNames')

end