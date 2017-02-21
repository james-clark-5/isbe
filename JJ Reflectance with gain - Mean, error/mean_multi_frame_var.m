% Script to find the mean of mean brightness values, and variance

% jj Want to use cleaned frames?
% NEED TO CLEAN FRAMES BEFOREHAND - USE "dirt_remover_main.m" file
% so that you have some cleaned frames to load into frames_dir

%jj tell the code where to look for called files
addpath(genpath('C:\Users\MPhys2016\Documents\GitHub\isbe'));

%Set folder containing all the frames
frames_dir = 'C:\isbe\nailfold\camera_capture\dual_cameras\Finite microscope\Two Cameras\3-light\Reflectance with gain - Mean, error, c1 560\testing img\img\';

frames_list = dir([frames_dir '*.bmp']);
num_frames = length(frames_list);

%Get brightnesses of all frames, save to array
for i_frame = 1:num_frames
    frame = double(imread([frames_dir frames_list(i_frame).name]));
    
    %jj get mean brightness of a frame
    single_frame_mean = mean(mean(frame));
    %jj save mean brightness of a frame to an array
    meanBrightnesses(i_frame) = single_frame_mean; %#ok<SAGROW>
end
%Found array of mean brightness
%Now get mean of means, and variance
mean_of_means = mean(meanBrightnesses);

for i_frame = 1:num_frames
numerator_var_parts(i_frame) = (meanBrightnesses(i_frame) - mean_of_means)^2; %#ok<SAGROW>
end

variance = (sum(numerator_var_parts))/(num_frames-1);
std_dev = variance.^0.5;