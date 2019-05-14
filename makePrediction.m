function [prediction] = makePrediction(betas, test_data, test_outcome,...
    test_subid, training_data, int, slope)
% This function applies the beta weights learned from an ML model, with
% a correction for the proportional bias within the training set, to an 
% external validation test set. The correction adds the training set
% intercept to the raw brain age prediction and divides the result by the
% training set slope.

% INPUT:
% betas          = n (features) x 4 array containing avg beta weights in
%                  col 1 and MNI coords of voxel location in cols 2 (x),
%                  3 (y), 4 (z).
% test_data      = array of size n (features) x m (participants) containing 
%                  data to which you will apply the beta weights
% test_outcome   = array file of size m (participants) x 1 containing the 
%                  chronological age for each subject
% test_subid     = subid for each participants
% training_data  = array of size m (participants) x n (features) containing 
%                  data on which model was trained. Used here to z-score
%                  test_data
% int            = intercept of training set
% slope          = slope of training set

% OUTPUT:
% prediction     = struct containing subid, chronological ages, brain age
%                  predictions (raw + corrected), brainPAD scores (raw +
%                  corrected), Pearson's correlation results between brain
%                  predicted age and chronological age (raw + corrected),
%                  Pearson's correlation results between brainPAD and
%                  chronological age (raw + corrected)

% Author: Rory Boyle rorytboyle@gmail.com
% Updated: 27/03/2019

%% 1. Load vars and prepare
% load avg beta weights + MNI coords - remove MNI coords info
betas = betas(:,1);

% transpose test data -if data is set up incorrectly (i.e. rows = ppts, and
% columns = features) - this assumes that data has more features than ppts
size_test_data = size(test_data);
if size_test_data(1) < size_test_data(2)
    test_data = test_data';
end

% create array to store products of beta weight * feature
betas_applied = NaN(size(test_data));

%% 2. z-score test data using mean of training data
test_data_z = (test_data - mean(training_data(:)))/std(training_data(:));

%% 3. calculate age prediction
% loop through data and multiply by corresponding beta weight
for i=1:size(test_data_z, 2)
    betas_applied(:,i) = test_data_z(:,i).*(betas);
end
% sum all voxels
raw_brainAge = sum(betas_applied)';

% adjust for proportional bias/rescale predictions using correction
corrected_brainAge = (raw_brainAge + int)/slope;

% get residuals (i.e.  brain predicted age difference = brainPAD)
raw_brainPAD = raw_brainAge - test_outcome;
corrected_brainPAD = corrected_brainAge - test_outcome;

%% 4. calculate r values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get r values for ML predictions - uncorrected and corrected predicted age
% should have equal r values when correlated with true age
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% Pearson's correlations between age and predicted age
% raw age
[r_raw_predicted_Age_Pearson, p_raw_predicted_Age_Pearson] = corr(raw_brainAge, test_outcome);

% brain age
[r_corrected_brain_Age_Pearson, p_corrected_brain_Age_Pearson] = corr(corrected_brainAge, test_outcome);

%%%%%%%%%% Pearson's correlations between brainPAD and chronological age
% raw age
[r_raw_brainPAD_Pearson, p_raw_brainPAD_Pearson] = corr(raw_brainPAD, test_outcome);

% brain age
[r_corrected_brainPAD_Pearson, p_corrected_brainPAD_Pearson] = corr(corrected_brainPAD, test_outcome);

%% 5. parse output + save in structure
% Subid
prediction.test_subid = test_subid;
% Add chronological ages 
prediction.chronologicalAge = test_outcome;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Brain Age predictions
prediction.raw_brainAge = raw_brainAge;
prediction.corrected_brainAge = corrected_brainAge;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BrainPADs
prediction.raw_brainPAD = raw_brainPAD;
prediction.corrected_brainPAD = corrected_brainPAD;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pearson's r and p for brain predicted age and chronological age
prediction.r_raw_predicted_Age_Pearson = r_raw_predicted_Age_Pearson;
prediction.p_raw_predicted_Age_Pearson = p_raw_predicted_Age_Pearson;

prediction.r_brain_Age_Pearson = r_corrected_brain_Age_Pearson;
prediction.p_brain_Age_Pearson = p_corrected_brain_Age_Pearson;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pearson's r and p for BrainPAD and chronological age
prediction.r_raw_brainPAD_Pearson = r_raw_brainPAD_Pearson;
prediction.p_raw_brainPAD_Pearson = p_raw_brainPAD_Pearson;

prediction.r_corrected_brainPAD_Pearson = r_corrected_brainPAD_Pearson;
prediction.p_corrected_brainPAD_Pearson = p_corrected_brainPAD_Pearson;
