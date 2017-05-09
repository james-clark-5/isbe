% ------------------------------------------------------------------------
% frame_analyser - for calculating the pixel distances between points on
% consecutive images and then converting to real distances.
% ------------------------------------------------------------------------
% Sebastian Ward
% 21/11/2016
% ------------------------------------------------------------------------
% This program loads images in a sequence and then accepts mouse input to
% track moving points across a series of images.
% ------------------------------------------------------------------------
 
 
% colormap('default')

% set the image directory:
im_dir = 'C:\n\';
 
frame_list = dir([im_dir '*.bmp']);
 
% selects the number of frames that will be analysed in the sequence.
num_frames = 20;
 
% creates a matrix of zeros for the x and y pixel coordinates.
xy_pos = zeros(num_frames, 2);
 
% open a new figure in whch to load the images.
figure;
 
% loop over the number of frames;
for i_im = 1 : 20
    
    % names the frame as it is pulled from the directory.
    frame_name = [im_dir frame_list(i_im).name];
    
    % reads in the frame to matlab as an array.
    frame = imread(frame_name);
    
    % display the image.
    imshow(frame)
    
    % sets the frame to fit tightly around the data.
    axis image; 
    
    % sets hold on, stops the frame from closing between images.
    hold on;
    
    % gives the frame a title - the name of the image.
    title(['Frame ' num2str(i_im)]);
    
    % sets up new vectors for the x and y coordinates.
    x = [];
    y = [];
    
    % reloops a frame if there are more or less than one point selected.
    while (length(x) ~= 1)
        
        [x, y, ~] = impixel();
        
    end
    
    % fills in xy_pos with the x and y coords selected.
    xy_pos(i_im, :) = [x y];
 
end
 
% creates a new array of 2 by n-1 of the difference between x and y
% coordinates of consecutive points.
frame_shifts = diff(xy_pos);
 
% calculates the pixel distance between each point => a 1 by n-1 vector.
frame_dists = sqrt(sum(frame_shifts.^2, 2));
 
% calculate the flow speed
meandist = mean(frame_dists); % take the mean
distpersec = meandist * 60; % flow rate per second
distmm = distpersec / 170 % flow rate in mm/s
 
fprintf('the flow rate for this sequence is calculated to be: \n%fmm/s \n\n', distmm)
 
% END



