function [] = mike_regdifImg_constantScale(save_dir, camera_filter)
% "correction factor CF?" 
% Load in the .mat files w/ registered images

camera_filter = '560nm'; %remove this when using as a function!
save_dir = strcat('C:\Users\MPhys2016\Desktop\tf_split_testing\_testing_17.02.27 - exp60.04 g718 - Juliana - 560 500 cam1 t2tf\','difference_images_f\'); % replace first string with "frames_dir"
save_name = 'difference_image_t2tf';
glims_all = zeros(60, 2);
glims_r_all = zeros(60, 2);

bright_all = zeros(60, 2);

for i_diff = 1:60
    load([save_dir save_name zerostr(i_diff, 3) '.mat'],...
        'gmin', 'gmax','gmin_r', 'gmax_r');
    % store the max and min values of difference image
    %glims_all(i_diff, :) = [gmin gmax];
    %glims_r_all(i_diff, :) = [gmin_r gmax_r];
    
    bright_min_array(i_diff) = nanmin(nanmin(registered_difference));
    bright_max_array(i_diff) = nanmax(nanmax(registered_difference));
    
end
% find overall max/min 
gmin = min(glims_all(:,1));
gmax = max(glims_all(:,2));

bright_min = min(bright_min_array);
bright_max = max(bright_max_array);


gmin_r = min(glims_r_all(:,1));
gmax_r = max(glims_r_all(:,2));

%% make new difference images
for i_diff = 1:60 % change to e.g. 60, or a variable
    load([save_dir save_name zerostr(i_diff, 3) '.mat'],...
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
    figure('Visible','Off');
    subplot(1,2,1); non_registered_image = imgray(mosaic_rgb); 
    title(sprintf('Non-overlapping compound frames pre-registration for %d nm filter', camera_filter));

    % Save the unregistered image
%     fullfile_unreg = fullfile(save_dir, strcat('Unregistered image_brightnessScaled',zerostr(i_diff, 3))); 
%     saveas(non_registered_image, fullfile_unreg, 'bmp'); %bmp
%     saveas(non_registered_image, fullfile_unreg, 'meta'); %emf 
%     saveas(non_registered_image, fullfile_unreg, 'fig'); %fig

    subplot(1,2,2); registered_image = imgray(reg_mosaic_rgb);
    title(sprintf('Aligned compound frames after registration for %s nm filter', camera_filter));
    % Save the registered image
    fullfile_reg = fullfile(save_dir, strcat('Registered image_brightnessScaled',zerostr(i_diff, 3)));
%     saveas(registered_image, fullfile_reg, 'bmp'); %bmp     
%     saveas(registered_image, fullfile_reg, 'meta'); %emf 
    saveas(registered_image, fullfile_reg, 'fig'); %fig    %have to resize later

    % create difference image (using info directly from .mat file)
    figure('Visible','Off');
    difference_image = imgray(registered_difference);
    title(sprintf('Difference between compound frames for %s nm filter, t2tf%i', camera_filter, i_diff));
    colormap jet;
    colorbar;
    caxis_min = round(bright_min,1);
    caxis_max = round(bright_max,1);
    caxis([caxis_min,caxis_max]); % caxis([bright_min,bright_max]

    % Save the difference image
    %fullfile_dif = fullfile(save_dir, strcat('Difference_image_brightnessScaled',zerostr(i_diff, 3)));
    fullfile_dif = fullfile(save_dir, strcat('Dif_img_cScaled_t2tf',zerostr(i_diff, 3),'c_min',num2str(caxis_min),'_c_max',num2str(caxis_max)));
    saveas(difference_image, fullfile_dif, 'bmp'); %bmp
    saveas(difference_image, fullfile_dif, 'meta'); %emf 
    saveas(difference_image, fullfile_dif, 'fig'); %fig
    
    fprintf('Number figures made with constant colourbar: %i. %i loops remaining!\n',i_diff,60-i_diff);
    
end

