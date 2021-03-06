mammo1 = load_uint8('C:\isbe\asymmetry_project\data\mammograms\2004_screening\abnormals\024RCC.mat');
figure; imagesc(mammo1); axis image; colormap(gray(256));
roi1 = sample_window(mammo1, 256, 1700, 1575);
figure; imagesc(roi1); axis image; colormap(gray(256));
%%
[line_strength1, orientation1] = gaussian_2nd_derivative_line(roi1, 1);
[line_strength2, orientation2] = gaussian_2nd_derivative_line(roi1, 2);
[line_strength4, orientation4] = gaussian_2nd_derivative_line(roi1, 4);
[line_strength8, orientation8] = gaussian_2nd_derivative_line(roi1, 8);

[line_strength_g2, orientation_g2] = gaussian_2nd_derivative_line(roi1, [1 2 4 8]);

%%
% xy = repmat(-128:127, 256, 1);
% mask = xy.^2 + xy'.^2 < 128^2;
% figure; imagesc(mask); axis image;

forest = u_load('C:\isbe\asymmetry_project\data\line_orientation_rfs\213209\random_forest.mat');
sampling_args = u_load('C:\isbe\asymmetry_project\data\line_orientation_rfs\213209\sampling_args.mat');
sampling_args_c.num_levels = sampling_args.num_levels;
sampling_args_c.feature_shape = sampling_args.feature_shape;
sampling_args_c.feature_type = sampling_args.feature_type;
sampling_args_c.do_max = sampling_args.do_max;
sampling_args_c.rotate = sampling_args.rotate;
sampling_args_c.win_size = sampling_args.win_size;
sampling_args_c.use_nag = sampling_args.use_nag;
%        
[orientation_rf] = classify_image(...
    'image_in', roi1, ...
    'forest', forest,...
    'sampling_args', sampling_args_c,...
    'forest_type', 'orientation',...
    'decomp_type', 'dt');
%%
d = 2;
figure; imagesc(line_strength1); axis image; colormap(gray(256)); hold on;
quiver(d:(2*d):256, d:(2*d):256,...
    line_strength1(d:(2*d):256, d:(2*d):256).*cos(orientation1(d:(2*d):256, d:(2*d):256)),...
    -line_strength1(d:(2*d):256, d:(2*d):256).*sin(orientation1(d:(2*d):256, d:(2*d):256)), 4);
figure; imagesc(line_strength2); axis image; colormap(gray(256)); hold on;
quiver(d:(2*d):256, d:(2*d):256,...
    line_strength2(d:(2*d):256, d:(2*d):256).*cos(orientation2(d:(2*d):256, d:(2*d):256)),...
    -line_strength2(d:(2*d):256, d:(2*d):256).*sin(orientation2(d:(2*d):256, d:(2*d):256)), 4);

figure; imagesc(line_strength4); axis image; colormap(gray(256)); hold on;
quiver(d:(2*d):256, d:(2*d):256,...
    line_strength4(d:(2*d):256, d:(2*d):256).*cos(orientation4(d:(2*d):256, d:(2*d):256)),...
    -line_strength4(d:(2*d):256, d:(2*d):256).*sin(orientation4(d:(2*d):256, d:(2*d):256)), 4);

figure; imagesc(line_strength8); axis image; colormap(gray(256)); hold on;
quiver(d:(2*d):256, d:(2*d):256,...
    line_strength8(d:(2*d):256, d:(2*d):256).*cos(orientation8(d:(2*d):256, d:(2*d):256)),...
    -line_strength8(d:(2*d):256, d:(2*d):256).*sin(orientation8(d:(2*d):256, d:(2*d):256)), 4);

figure; imagesc(abs(orientation_rf)); axis image; colormap(gray(256)); hold on;
quiver(d:(2*d):256, d:(2*d):256,...
    real(orientation_rf(d:(2*d):256, d:(2*d):256)),...
    -imag(orientation_rf(d:(2*d):256, d:(2*d):256)), 4);
%%
figure; imagesc(roi1); axis image; colormap(gray(256)); hold on;
quiver(d:(2*d):256, d:(2*d):256,...
    line_strength_g2(d:(2*d):256, d:(2*d):256).*cos(orientation_g2(d:(2*d):256, d:(2*d):256)),...
    -line_strength_g2(d:(2*d):256, d:(2*d):256).*sin(orientation_g2(d:(2*d):256, d:(2*d):256)),...
    2, 'b', 'ShowArrowHead', 'off');
quiver(d:(2*d):256, d:(2*d):256,...
    -line_strength_g2(d:(2*d):256, d:(2*d):256).*cos(orientation_g2(d:(2*d):256, d:(2*d):256)),...
    line_strength_g2(d:(2*d):256, d:(2*d):256).*sin(orientation_g2(d:(2*d):256, d:(2*d):256)),...
    2, 'b', 'ShowArrowHead', 'off');

figure; imagesc(roi1); axis image; colormap(gray(256)); hold on;
quiver(d:(2*d):256, d:(2*d):256,...
    real(orientation_rf(d:(2*d):256, d:(2*d):256)),...
    -imag(orientation_rf(d:(2*d):256, d:(2*d):256)),...
    1, 'b', 'ShowArrowHead', 'off');
quiver(d:(2*d):256, d:(2*d):256,...
    -real(orientation_rf(d:(2*d):256, d:(2*d):256)),...
    imag(orientation_rf(d:(2*d):256, d:(2*d):256)),...
    1, 'b', 'ShowArrowHead', 'off');
%%
for ii = 1: