function [] = mike_regdifImg_constantScale(frames_dir)
% "correction factor CF?" 
% Load in the .mat files w/ registered images

save_dir = strcat('C:\Users\MPhys2016\Desktop\tf_split_testing\_testing_17.02.27 - exp60.04 g718 - Juliana - 560 500 cam1 t2tf\','difference_images_f\'); % replace first string with "frames_dir"
save_name = 'difference_image_t2tf';
glims_all = zeros(60, 2);
glims_r_all = zeros(60, 2);
for i_diff = 1:60
    load([save_dir save_name zerostr(i_diff, 3) '.mat'],...
        'gmin', 'gmax','gmin_r', 'gmax_r');
    % store the max and min values of difference image
    glims_all(i_diff, :) = [gmin gmax];
    glims_r_all(i_diff, :) = [gmin_r gmax_r];
end
% find overall max/min 
gmin = min(glims_all(:,1));
gmax = max(glims_all(:,2));

gmin_r = min(glims_r_all(:,1));
gmax_r = max(glims_r_all(:,2));

% make new difference images
for i_diff = 1:60
    load([save_dir save_name 'difference_image' zerostr(i_rng, 3) '.mat'],...
        'mosaic12', 'tile_mask12', 'registered_difference', ...
            'registered_mosaics', 'registered_masks');
    mosaic_rgb = 1-(mosaic12 - gmin) / (gmax-gmin);
    mosaic_rgb(~tile_mask12) = 0;
    mosaic_rgb(:,:,3) = 0;


    reg_mosaic_rgb = 1-(registered_mosaics - gmin_r) / (gmax_r-gmin_r);
    reg_mosaic_rgb(~registered_masks) = 0;
    reg_mosaic_rgb(:,:,3) = 0;

    % correction factor CF? 
    % registered_difference = registered_difference; % jj apply correction factor


    % registration images
    figure; 
    subplot(1,2,1); non_registered_image = imgray(mosaic_rgb); 
    title(sprintf('Non-overlapping compound frames pre-registration for %d nm filter', args.camera_filter));

    % Save the unregistered image
    fullfile_unreg = fullfile(args.frames_dir, 'Unregistered image_brightnessScaled'); 
    saveas(non_registered_image, fullfile_unreg, 'bmp'); %bmp
    saveas(non_registered_image, fullfile_unreg, 'meta'); %emf 
    saveas(non_registered_image, fullfile_unreg, 'fig'); %fig

    subplot(1,2,2); registered_image = imgray(reg_mosaic_rgb);
    title(sprintf('Aligned compound frames after registration for %d nm filter', args.camera_filter));
    % Save the registered image
    fullfile_reg = fullfile(args.frames_dir, 'Registered image_brightnessScaled');
    saveas(registered_image, fullfile_reg, 'bmp'); %bmp
    saveas(registered_image, fullfile_reg, 'meta'); %emf 
    saveas(registered_image, fullfile_reg, 'fig'); %fig

    % create difference image (using info directly from .mat file)
    figure;
    difference_image = imgray(registered_difference);
    title(sprintf('Difference between compound frames for %d nm filter', args.camera_filter));
    colormap jet;
    colorbar;
    % Save the difference image
    fullfile_dif = fullfile(args.frames_dir, 'Difference image_brightnessScaled');
    saveas(difference_image, fullfile_dif, 'bmp'); %bmp
    saveas(difference_image, fullfile_dif, 'meta'); %emf 
    saveas(difference_image, fullfile_dif, 'fig'); %fig
    
end

