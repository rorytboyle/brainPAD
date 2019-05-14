function resize_niftis(folder, Voxdim)
% Function calls resize_img on all .nii files in the folder specified by
% user and resizes images according to dimensions provided by Voxdim input
% resize_img taken from here: http://www0.cs.ucl.ac.uk/staff/gridgway/vbm/resize_img.m
% INPUT:
% folder    = string containing absolute path to folder consisting of images
%             to be resized - make sure only images to be resized are 
%             contained in this folder as it loops through the whole
%             folder. Output will also be saved here.
% Voxdim    = 1 x 3 array of values to resize nii to

% Author: Rory Boyle rorytboyle@gmail.com
% Updated: 28/03/2019

%% 1. Check and parse input
% check folder name is provided as a string
if ~ischar(folder)
    error('Results file name invalid - Please enter file name, containing absolute path to .mat file, as a string.')
end
% check folder is a valid folder 
if ~isdir(folder)
    error('Folder does not exist - Please enter valid folder name')
end

% check Voxdims is a valid array
if length(Voxdim) ~= 3
    error('Incorrect voxel dimensions provided - Please provide a 1 x 3 array of voxel dimensions')
end

%% 2. Load folder
files = dir(folder);
files = files(3:end); % first two rows created by dir(folder) are just punctutation marks

%% 3. Resize each image
for i=1:length(files)
    resize_img([files(i).folder filesep files(i).name], Voxdim, nan(2,3));
end