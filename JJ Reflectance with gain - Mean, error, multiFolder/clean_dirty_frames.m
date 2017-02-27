function [] = clean_dirty_frames(frames_dir, varargin)
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
    'time1_ext', '',...
    ...%RESPONSE'time2_ext', '_t1_',...
    'image_format', 'bmp',...
    'dirt_image', [],...
    'theta_range', 0,...
    'offset_lim', 120,...
    'sigma', 8,...
    'transforms_dir', [], ...
    'corrected_dir', [], ...
    'make_videos', false,...
    'display_output', 1);
clear varargin;

%%-------------------------------------------------------------------------
% Create folder to store the transformed images
if isempty(args.corrected_dir)
    corrected_dir = [frames_dir 'corrections\'];
else
    corrected_dir = args.corrected_dir;
end
create_folder(corrected_dir);
%%-------------------------------------------------------------------------
% Get list of frame names
%NEED TO ADD 560/530/500
%fprintf('DID YOU SPECIFY WHICH WAVELENGTH FILES TO LOOK AT? CLEAN_DIRTY_FRAMES.M');
time1_frame_names = dir([frames_dir '*C_500_' '*.bmp']);
%RESPONSE time2_frame_names = dir([frames_dir '*' args.time2_ext '*.' args.image_format]);

time1_frame_names = {time1_frame_names(:).name}';
% RESPONSE time2_frame_names = {time2_frame_names(:).name}';

%num_frames1 = length(time1_frame_names);
% RESPONSE num_frames2 = length(time2_frame_names);

%%
%--------------------------------------------------------------------------
% Don't need to worry about flipping or rotating frames now - they're from
% the same camera
%--------------------------------------------------------------------------
%%
% Now prepare the frames from each time period
% 1) Load in each frame, subtracting the dirt image if supplied
% 2) Register sequential frames
% 3) Make mosaic and write out the cleaned frames, saving the tranforms

prepare_frames(time1_frame_names, frames_dir, ...
    args.dirt_image, corrected_dir);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

function prepare_frames(frame_names, frames_dir, ...
    dirt_image, corrected_dir)
%The preparation steps are
% 1) Load in each frame, subtracting the dirt image if supplied
% 2) Register sequential frames
% 3) Make mosaic and write out the cleaned frames, saving the tranforms

%Load in frame subtracting dirt image
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
