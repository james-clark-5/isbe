save_dir = [];
save_name = [];
glims_all = zeros(60, 2);
glims_r_all = zeros(60, 2);
for i_diff = 1:60
    load([save_dir save_name 'difference_image' zerostr(i_rng, 3) '.mat'],...
        'gmin', 'gmax','gmin_r', 'gmax_r');
    
    glims_all(i_diff, :) = [gmin gmax];
    glims_r_all(i_diff, :) = [gmin_r gmax_r];
end

gmin = min(glims_all(:,1));
gmax = max(glims_all(:,2));

gmin_r = min(glims_r_all(:,1));
gmax_r = max(glims_r_all(:,2));

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

    % jj don't seem to be applying correction factor twice
    %mosaic_rgb = mosaic_rgb * args.correction_factor; % jj apply correction factor
    %reg_mosaic_rgb = reg_mosaic_rgb * args.correction_factor; % jj apply correction factor
         % didn't want to apply the correction here actually - registration comparison washed out  
    registered_difference = registered_difference * args.correction_factor; % jj apply correction factor


    % registration images
    figure; 
    subplot(1,2,1); non_registered_image = imgray(mosaic_rgb); 
    title(sprintf('Non-overlapping compound frames pre-registration for %d nm filter', args.camera_filter));

    % Save the unregistered image
    fullfile_unreg = fullfile(args.frames_dir, '_Unregistered image'); 
    saveas(non_registered_image, fullfile_unreg, 'bmp'); %bmp
    saveas(non_registered_image, fullfile_unreg, 'meta'); %emf 
    saveas(non_registered_image, fullfile_unreg, 'fig'); %fig

    subplot(1,2,2); registered_image = imgray(reg_mosaic_rgb);
    title(sprintf('Aligned compound frames after registration for %d nm filter', args.camera_filter));
    % Save the registered image
    fullfile_reg = fullfile(args.frames_dir, '_Registered image');
    saveas(registered_image, fullfile_reg, 'bmp'); %bmp
    saveas(registered_image, fullfile_reg, 'meta'); %emf 
    saveas(registered_image, fullfile_reg, 'fig'); %fig

    % difference image
    % NOT SURE IF THIS WILL WORK WITH COLORMAP & COLORBAR
    figure;
    difference_image = imgray(registered_difference);
    title(sprintf('Difference between compound frames for %d nm filter', args.camera_filter));
    colormap jet;
    colorbar;
    % Save the difference image
    fullfile_dif = fullfile(args.frames_dir, '_Difference image');
    saveas(difference_image, fullfile_dif, 'bmp'); %bmp
    saveas(difference_image, fullfile_dif, 'meta'); %emf 
    saveas(difference_image, fullfile_dif, 'fig'); %fig
    
end

