% fix offset of capillaries
% method 1
% register the difference images
% method 2 
% offsets applied to t1 (t1t2); frame_transforms, the second output from mosaic_limits
% r_x = frame_transforms(1,3)
% r_y = frame_transforms(2,3).
 
%% run code for roipoly means
% ADD USER OPTION FOR #ROIs
addpath(genpath('C:\Users\MPhys2016\Documents\GitHub\isbe'));

% Investigate ROI after accouting for translation of image
figure; difference_image = imgray(registered_difference); % load grey image for using roipoly on
vessel_mask1 = roipoly; %Display image and allows you to interactively select region-of-interest
vessel_mask2 = roipoly;
vessel_mask = vessel_mask1 | vessel_mask2; % create overalls vessel mask
% imshow(vessel_mask); % displays mask OK


mean_val = nanmean(registered_difference(vessel_mask)); % get overall mean
fprintf('The mean value for the overall ROI is %f.\n',mean_val);
mean_val1 = nanmean(registered_difference(vessel_mask1)); % get first mask mean
fprintf('The mean value for the first ROI is %f.\n',mean_val1);
mean_val2 = nanmean(registered_difference(vessel_mask2)); % get second mask mean
fprintf('The mean value for the second ROI is %f.\n\n',mean_val2);

% use multiple ROIPoly regions
% vessel_mask = vessel_mask1 | vessel_mask2 | vessel_mask3 etc.
%% shifts
[vessel_mask roi_x roi_y] = roipoly(difference_image1);
figure; imgray(difference_image2);
plot(roi_x, roi_y);



% B1 = horzcat(zeros(K,size(a,2)).A)
% %would have "A" as its right-hand side, moved right by K positions.
% B2 = B1(K+1:end,:)
% %would drop the first K columns of B1, moving it left by K positions.
% B3 = vertcat(A, zeros(size(a,1),J))
% %would have "A" as its top, moved up by J positions.
% B4 = B3(:1:end-J)
% %would drop the bottom J columns of B3, moving it down by J positions.