%% from "DUAL_CAMERA_REGISTRATION_EXAMPLE.M"
%jj tell the code where to look for called files
addpath(genpath('C:\Users\MPhys2016\Documents\GitHub\isbe'));

%Set folder containing all the frames
frames_dir = 'C:\Users\MPhys2016\Desktop\Reflectance\16.12.13 - white circle - 530 nm 560 nm - 3000 K 3-light - g1 500, g2 320, exp 64.37\530nm\';

%jj attempt to create folder to save images to
%mkdir(frames_dir,'OurSavedImages')

filter_wavelength = 530; %jj change this when filter changes

%Make dirt image
%You want to use the (out-of-focus) frames you captured especially for this
dirty_dir = 'C:\Users\MPhys2016\Desktop\Reflectance\16.12.13 - white circle - 530 nm 560 nm - 3000 K 3-light - g1 500, g2 320, exp 64.37 dirt\530nm\'; %
[dirt_image] = make_dirt_image(dirty_dir);
figure; imgray(dirt_image); colorbar;
title(sprintf('Normalised compound dirt image for %d nm filter', filter_wavelength));

%% from "PREPARE_SEQUENTIAL_CAMERA_FRAMES.M"
frame_names = dir([frames_dir '*frame*']);

num_frames = length(frame_names);

for i_frame = 1:num_frames
    
    frame = double(imread([frames_dir frame_names{i_frame}]));

    if ~isempty(dirt_image)
        frame = frame - dirt_image;
        imwrite(uint8(frame), [corrected_dir frame_names{i_frame}]);
    end
    
    if i_frame == 1
        [nrows, ncols] = size(frame);
        frames = zeros(nrows, ncols, num_frames);
    end
    frames(:,:,i_frame) = frame;
    
end