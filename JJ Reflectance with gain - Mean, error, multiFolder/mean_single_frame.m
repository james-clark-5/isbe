%% compute mean brightness FOR A SINGLE FRAME!
% SINGLE FRAME! NOT E.G. 60 FRAMES!

img = imread('frame_Right_D2_Mx300_C_560_16_55_20_925_0001_g2_300.bmp');
fprintf('frame1 mean brightness: ');
img_mean = mean(mean(img))
fprintf('\n');

% look at variation with time (static object, expect tiny change
img2 = imread('frame_Right_D2_Mx300_C_560_16_55_21_908_0060_g2_300.bmp');
fprintf('frame2 mean brightness: ');
img_mean2 = mean(mean(img2))
fprintf('\n');
% show difference (noise)
img3 = img-img2;
fprintf('noise (f1-f60) mean brightness: ');
img_mean3 = mean(mean(img3))
fprintf('\n');
fprintf('\n');

figure; imgray(img3); colorbar;
title(sprintf('60th frame - 1st frame (no dirt-removed), for Camera 1 w/ 530nm filter'));
% show original image for contrast
figure; imgray(img); colorbar;
title(sprintf('1st frame (no dirt removed), for Camera 1 w/ 530nm filter'));
