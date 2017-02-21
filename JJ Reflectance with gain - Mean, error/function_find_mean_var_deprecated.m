function [mean_of_means,var] = find_mean_var(frames_dir, image_format)
%MAKE_DIRT_IMAGE *Insert a one line summary here*
%   [dirt_image] = make_dirt_image(frame_dir)
%
% Inputs:
%      frames_dir - Folder of frames used to make dirt image
%
%      image_format (optional): Default 'bmp'
%
%
% Outputs:
%      mean of mean brightness values across whole of image
%      varaince of these mean brightnesses
%
% Example:
%
% Notes:
%
% See also:
%
% Created: 05-Dec-2016
% Author: Michael Berks 
% Email : michael.berks@manchester.ac.uk 
% Phone : +44 (0)161 275 7669 
% Copyright: (C) University of Manchester 

%if ~exist('image_format', 'var') || isempty(image_format)
%    image_format = 'bmp';
%end

%Get list of frames
frames_list = dir([frames_dir '*.bmp']);
num_frames = length(frames_list);

%Get brightnesses of all frames, save to array
for i_frame = 1:num_frames
    frame = double(imread([frames_dir frames_list(i_frame).name]));
    
    %jj get mean brightness of a frame
    img_mean = mean(mean(frame));
    %jj save mean brightness of a frame to an array
    meanBrightnesses(i_frame) = img_mean; %#ok<AGROW>
    
end
%Found array of mean brightness
%Now get mean of means, and variance
mean_of_means = mean(meanBrightnesses);
x2 = meanBrightnesses.^2;
var = sum(x2) - mean_of_means^2;

% ! don't forget to change input to/output of function, and input when calling
% fucntion
