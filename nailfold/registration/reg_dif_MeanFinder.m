%% load in data
load difference_image_t2tf001_meanFINDERLOL.mat
reg_dif_double = registered_difference;
%% remove NaN from data
reg_dif_double(isnan(reg_dif_double)) = [];
%% take mean brightness of dif_image
mean_brightness = mean(mean(reg_dif_double));
fprintf('mean brightness value %f\n',mean_brightness);
median_brightness = median(reg_dif_double);
fprintf('median brightness value %f\n',median_brightness);
% 
% A = reg_dif_double;
% size = size(A);
% B = reshape(A', size(A,1)*size(A,2), 1);
% B(isnan(B)) = [];
% B = reshape(B, size(2)-1, size(1));





%reg_dif_cell(cellfun(@(x) any(isnan(x)),reg_dif_cell)) = {''};

%  imshow(img)  % show image
% img_mean = mean(mean(img))
% fprintf('frame1 mean brightness: ');
