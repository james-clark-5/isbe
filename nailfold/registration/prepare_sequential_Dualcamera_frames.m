function [] = prepare_sequential_Dualcamera_frames(frames_dir, varargin)

%REGISTER_DUAL_CAMERA_FRAMES *Insert a one line summary here*
%   [] = register_dual_camera_frames(varargin)
%
% REGISTER_DUAL_CAMERA_FRAMES uses the U_PACKARGS interface function
% and so arguments to the function may be passed as name-value pairs
% or as a struct with fields with corresponding names. The field names
% are defined as:
%
% Mandatory Arguments:
%
% Optional Arguments:
%
% Outputs:
%
% Example:
%
% Notes:
%
% See also:
%
% Created: 14-Aug-2013
% Author: Michael Berks 
% Email : michael.berks@manchester.ac.uk 
% Phone : +44 (0)161 275 7669 
% Copyright: (C) University of Manchester 

% Unpack the arguments:
args = u_packargs(varargin, '0', ...
    'time1_ext', '_t2_',...
    'time2_ext', '_tf_',...
    'image_format', 'bmp',...
    'time1_dualdif_frame', [],...
    'time2_dualdif_frame', [],...  
    'theta_range', 0,...
    'dirt_image', 0,...
    'num_frames', 2,...
    'offset_lim', 120,...
    'sigma', 8,...
    'transforms_dir', [], ...
    'corrected_dir', [], ...
    'rotated_dir', [], ...
    'make_videos', false,...
    'display_output', 1);
clear varargin;

%%-------------------------------------------------------------------------
% Create folder to store the transformed images
if isempty(args.transforms_dir)
    transforms_dir = [frames_dir 'timedual_transforms\'];
% else
%     transforms_dir = args.transforms_dir;
end

if isempty(args.corrected_dir)
    corrected_dir = [frames_dir 'timedual_corrections\'];
% else
%     corrected_dir = args.corrected_dir;
end

% if isempty(args.rotated_dir)
%     rotated_dir = [frames_dir 'timedual_rotated\'];
% else
%     rotated_dir = args.rotated_dir;
% end

create_folder(transforms_dir);
create_folder(corrected_dir);
%create_folder(timedual_rotated);

%%-------------------------------------------------------------------------
% Get list of frame names
%time1_frame_names = dir([frames_dir '*' args.time1_ext '*.' args.image_format]);
%time2_frame_names = dir([frames_dir '*' args.time2_ext '*.' args.image_format]);

%%
%--------------------------------------------------------------------------
% Flip all the frames from camera 2, and rotate all the frames from both
% PROBABLY DON'T NEED THIS           ?
% % % % % cameras
% % % % for i_frame = 1:num_frames
% % % %     % JJ: frame_names includes folder structure, so don't need frames_dir?
% % % %     % JJ: frame_name needs to have folder structure removed from it
% % % %     frame1 = imread([frames_dir camera1_frame_names{i_frame}]);    % replace frames with the timedual frames
% % % %     frame2 = imread([frames_dir camera2_frame_names{i_frame}]);
% % % %     %frame1 = time1_dualdif_frame;
% % % %         %frame1 = time1_dualdif_frame;
% % % % %                                           MAY NEED THIS?
% % % % %     if args.rotation1 
% % % % %         frame1 = rot90(frame1, args.rotation1);  
% % % % %     end
% % % % %     if args.rotation2
% % % % %         frame2 = rot90(frame2, args.rotation2);
% % % % %     end
% % % %     
% % % %     imwrite(frame1, [rotated_dir camera1_frame_names{i_frame}]);    
% % % %     imwrite(frame2, [rotated_dir camera2_frame_names{i_frame}]);   
% % % % end

%%
% Now prepare the frames from each time period
% 1) Load in each frame, subtracting the dirt image if supplied
% 2) Register sequential frames
% 3) Make mosaic and write out the cleaned frames, saving the tranforms

% MAKE FRAMES THE SAME SIZE ???
% don't change args.time1_dualdif_frame
[nrows1, ncols1] = size(args.time1_dualdif_frame);
[nrows2, ncols2] = size(args.time2_dualdif_frame);

time2_dualdif_frame_adjusted = args.time2_dualdif_frame;

if (nrows2 > nrows1) || (ncols2 > ncols1)
    fprintf('either nrows2>nrows1 , or ncols2>ncols1\n'); 
    time2_dualdif_frame_adjusted(nrows1 + 1:nrows2,:) = [];
    time2_dualdif_frame_adjusted(ncols1 + 1:ncols2,:) = [];
end
if (nrows2 < nrows1) || (ncols2 < ncols1)
        fprintf('either nrows2<nrows1 , or ncols2<ncols1\n'); 
time2_dualdif_frame_adjusted(nrows1, ncols1) = 0;
end


[nrows, ncols] = size(args.time1_dualdif_frame); % create empty array to store the two timedual images; sizes are fine, no problem
frames = zeros(nrows, ncols, args.num_frames); 
frames(:,:,1) = args.time1_dualdif_frame; % keep same 
frames(:,:,2) = time2_dualdif_frame_adjusted; % use adjusted
% frames(:,:,3) = time3_dualdif_frame;
fprintf('');

reg_params.theta_range = args.theta_range;
reg_params.offset_lim = args.offset_lim;
reg_params.sigma = args.sigma;

prepare_frames(args.time1_dualdif_frame, frames, frames_dir, ... 
    corrected_dir, transforms_dir, ...
    reg_params,...
    'time1', args.display_output, args.make_videos);

prepare_frames(time2_dualdif_frame_adjusted, frames, frames_dir, ... 
    corrected_dir, transforms_dir, ...
    reg_params,...
    'time2', args.display_output, args.make_videos);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

function prepare_frames(frames, frame_names, frames_dir, ...
    dirt_image, corrected_dir, transforms_dir, ...
    reg_params,...
    display_name, display_output, make_video)
%The preparation steps are
% 1) Register sequential frames
% 2) Make mosaic and write out the cleaned frames, saving the tranforms

%At this stage the transforms may be quite large, so need large theta
%and offset ranges
[compound_transforms] = ...
    register_tiles_features(frames, ...
                            'dirt_image', dirt_image,...
                            'theta_range', reg_params.theta_range, ...
                            'offset_lim', reg_params.offset_lim, ...
                            'sigma', reg_params.sigma,...
                            'debug', display_output > 1);


[nailfold_mosaic, ~, mosaic_transforms] = ...
    create_mosaic(frames, compound_transforms); %#ok

if display_output
    figure; imgray(nailfold_mosaic);
    title(['Compound mosaic of all consecutively registered frames for' display_name]);
end

%save these transforms
save([transforms_dir display_name '_reg_timedual_transforms.mat'], 'mosaic_transforms');

% if make_video
%     reg_folder = [frames_dir 'registered\'];
%     g_lims = [min(nailfold_mosaic(:)) max(nailfold_mosaic(:))];
% 
%     delete([reg_folder 'frame*']);
% 
%     write_trans_tiles(frames, mosaic_transforms, ...
%                              reg_folder, 'frame', g_lims, nailfold_mosaic);
% 
%     cmd = ['ffmpeg -y -r 15 -i "' reg_folder 'frame%04d.png" -c:v libx264 -preset slow -crf 18 -an "' reg_folder '_' display_name '_movie.mp4"'];
%     system(cmd);
% 
% end