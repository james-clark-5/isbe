% Script to find the mean brightness of registered difference images
% place this file in a folder with a trial's t0't0, t0t1, t0t2, etc. etc.
% requires you to have already run the dual_time_registration_example.m
% code, to 1) clean, 2) register, 3) difference the images. This uses a
% saved .mat file to get the mean brightness in the difference image

%ignore this dodgy lazy hack
clear all;
close all;

backslash = '\';

%Get folders (ignoring files and the two "." ".." folders
d = dir;
isub = [d(:).isdir];
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
%Get number of folders
numFolders=size(nameFolds, 1);
%Get current main directory, as string
main_directory = cellstr(pwd);
dif_img_dir = '\difference_images_f';
%%%%%%%%%%%%%%%%%%%%%%%%%%
%Loop through all folders containing images
%Initialise iFolders
iFolders = 1;
%Prepare array to store mean of means and s.d.
folder_dif_array = zeros(numFolders,2);
while iFolders<numFolders+1
    clearvars fullfilename; % lose these each loop
    
    % get difference registered .mat file
    current_frames_dir = nameFolds(iFolders);
    frames_dir = sprintf('%s%s%s%s', main_directory{1},backslash, current_frames_dir{1},dif_img_dir,backslash);
    fullfilename = fullfile(frames_dir, 'difference_image001.mat');
    load(fullfilename);
     
    reg_dif_double = registered_difference;
    % remove NaN from data
    reg_dif_double(isnan(reg_dif_double)) = [];
    % take mean brightness of dif_image
    mean_brightness = mean(mean(reg_dif_double));        
        
        
        %Save mean of means & s.d. to array (one pair of values for each folder of images)
        current_dir=num2str(cell2mat(current_frames_dir));
        mean_array(iFolders)= mean_brightness;
        current_dir_array{iFolders}=current_dir;     
        
        iFolders = iFolders + 1;
end
% make 1 row turn into 1 column
current_dir_array = current_dir_array';
mean_array = mean_array';
% merge folders and mean values into 1 cell
trial_and_mean_cell = [current_dir_array, num2cell(mean_array)];

% all done
fprintf('program has finished running!');
