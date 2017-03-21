%testing_meanDifImg_multiFolder
function [regDif_meanBrightness_array] = testing_meanDifImg_multiFolder(frames_dir)

% get mat files from directory
difImg_dir = [frames_dir 'difference_images_f\']; 
difImg_mat_names = dir([difImg_dir '*.mat']);
difImg_mat_names = {difImg_mat_names(:).name}';
numBatches = length(difImg_mat_names);

%preallocate array for storing mean values
regDif_meanBrightness_array = zeros(1,numBatches)';

for i = 1:numBatches
    % load in the registered_differnce file, find the mean brightness,
    % output to an array
matFile_To_Load = cell2mat(fullfile(difImg_dir, difImg_mat_names(i))); 
load (matFile_To_Load);

reg_dif_double = registered_difference;
reg_dif_double(isnan(reg_dif_double)) = [];


regDif_meanBrightness_array(i) = mean(reg_dif_double);
end

