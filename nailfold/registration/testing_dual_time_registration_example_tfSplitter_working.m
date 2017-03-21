%Example script for preparing and the registering frames captured from the
%dual camera system

fprintf('Did you change the frames to be loaded in? ~ line 11\n');
fprintf('Did you specify which wavelength is being analysed? ~ line 23\n');
fprintf('Did you specify which trial is being analysed? ~ line 24\n');
fprintf('Did you change the dirt frames folder? ~ line 32\n');

%jj tell the code where to look for called files
addpath(genpath('C:\Users\MPhys2016\Documents\GitHub\isbe'));

%Set folder containing all the frames
frames_dir = 'C:\Users\MPhys2016\Desktop\tf_split_testing\_testing_17.02.27 - exp60.04 g718 - Juliana - 560 500 cam1 t2tf\';
trial_number = 1;
%jj wavelength of filter for images
filter_wavelength = 560; %jj change this when filter changes

%%Make dirt image
%You want to use the (out-of-focus) frames you captured especially for this
dirty_dir = 'C:\Users\MPhys2016\Desktop\tf_split_testing\_testing_17.02.27_dirt_ - exp60.04 g718 - 560 cam1\'; %
[dirt_image] = make_dirt_image(dirty_dir);
figure; imgray(dirt_image); colorbar;
title(sprintf('Normalised compound dirt image for %d nm filter, part of trial %d', filter_wavelength,trial_number));

%% prepare the frames
%Prepare the frames - I've included all the optional arguments below with
%their default values, you shouldn't need to change these, but you might
%want to:
% - Increase offset_lim if it is too small to capture the motion between
% frames (the value is the number of pixels in each direction successive
% frames can move and still be matched)
% - Add a range of theta's if you think you are seeing rotational movement
% between frames
% - Play with different values of sigma - this will change the feature
% points used to match vessels between frames. Higher values of sigma pick
% large scale smoother vessels edges. A value about half the width (in
% pixels) of the vessel is probably about right
% - Change what output you display 1 = summary figures, 2 = full debug
% matching during registration. I suggest running with 2 to start with, and
% watching the registration in real-time to check frames are being matched
% appropriately

testing_prepare_sequential_camera_frames(frames_dir, ... 
    'time1_ext', '_t2_',...
    'time2_ext', '_tf_',...
    'image_format', 'bmp',...
    'dirt_image', dirt_image,...
    'theta_range', 0,...
    'offset_lim', 120,...
    'sigma', 8,...
    'corrections_dir', [], ...
    'transforms_dir', [], ...
    'make_videos', false,... %Switch to true if you have ffmpeg installed and included on your system path and want to make videos of vessel flow
    'display_output', 0);
%% register and take difference images of all frames

%Load in the transforms from the above registrations
t1_transforms = u_load([frames_dir 'transforms\time1_reg_transforms.mat']);
t2_transforms = u_load([frames_dir 'transforms\time2_reg_transforms.mat']);

%Register pairs of compund frames from each camera - define the range used
%in each compound frame either by frame numbers (which will be the same for
%both cameras) or by time interval in seconds over the sequence (in which
%case different frames may be used for each camera because the times may
%not match up)
testing_register_time_camera_frames([frames_dir 'corrections\'],...
    t1_transforms, t2_transforms, [1 60], 'frames',...
    'camera_filter', filter_wavelength,... % jj change this appropriately
    'camera1_ext', '_t2_',...
    'camera2_ext', '_tf_',...
    'frames_dir', frames_dir,... % jj pass the frames dir, to save final images to
    'trial_number', trial_number,... % jj update figures saying which trial images are from
    'image_format', 'bmp',...
    'theta_range', 0,...
    'offset_range', 240,...
    'save_images', 1, ...,
    'save_dir', [frames_dir 'difference_images_f\']);
%% take the mean of all t2tfx registered difference images

% call a function to do this
regDif_meanBrightness_array = testing_meanDifImg_multiFolder(frames_dir); 
x = 0:59;
figure;
plot(x,regDif_meanBrightness_array,'bx');

