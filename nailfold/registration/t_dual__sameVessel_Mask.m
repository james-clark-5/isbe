% butchered code to find the amount by which capillaries move between dualcam_dif compound difference images
% (not between time_dif);
% this allows us to simply get the dual_cam mean value on the same vessel
% for t0dual, t1dual, and t2dual (tf dual is too computationally expensive)

%% load code
addpath(genpath('C:\Users\MPhys2016\Documents\GitHub\isbe'));
frames_dir = 'C:\Users\MPhys2016\Desktop\tf_split_testing\_testing_17.02.27 - exp60.04 g718 - Juliana - 560 500 cam1 t2tf\';

% load tXdual images, e.g. t0dual & t1dual
% N.B. using the following .mat files (time-dif) just for testing 
load (fullfile(frames_dir, 'difference_images_f\', 'difference_image_t2tf001'));  % WILL WANT load difference_image_t0dual.mat 
time1_dualdif_frame = registered_difference;
load (fullfile(frames_dir, 'difference_images_f\', 'difference_image_t2tf002'));  % WILL WANT load difference_image_t1dual.mat  
time2_dualdif_frame = registered_difference;
num_frames = 2;


%% use a modified preparation function to get camera1/2_transforms
prepare_sequential_Dualcamera_frames(frames_dir, ... 
    'time1_ext', '_t0_',...
    'time2_ext', '_t1_',...
    'time1_dualdif_frame', time1_dualdif_frame,...
    'time2_dualdif_frame', time2_dualdif_frame,...   
    'theta_range', 0,...
    'offset_lim', 120,...
    'sigma', 8,...
    'corrections_dir', [], ...
    'transforms_dir', [], ...
    'make_videos', false,... %Switch to true if you have ffmpeg installed and included on your system path and want to make videos of vessel flow
    'display_output', 0);




%% Create mosaic for each camera
    
camera1_transforms = u_load([frames_dir 'transforms\time1_reg_transforms.mat']);
camera2_transforms = u_load([frames_dir 'transforms\time2_reg_transforms.mat']);

    [mosaic1, weights1] = create_mosaic(...
        time1_dualdif_frame, camera1_transforms(:,:,1), 'uniform');  %camera1_transforms COMES FROM PREPARE_FRAMES; SO NEED TO PREPARE THESE TWO DUAL_DIF FRAMES  
    tile_mask1 = weights1 == 1; % error: Subscript indices must either be real positive integers or logicals.

    [mosaic2, weights2] = create_mosaic(...
        time2_dualdif_frame, camera2_transforms(:,:,1), 'uniform'); % CAMERA2_TRANSFORMS(:,:,?), WHERE ? DEPENDS ON SAVED FILE FROM PREPARING FRAMES. NEED TO PREPARE DUAL_DIF FRAMES?
    tile_mask2 = weights2 == 1;

    %Get the relative sizes of the two mosaics, increase the size of the
    %smaller
    [nrows1 ncols1] = size(mosaic1);
    [nrows2 ncols2] = size(mosaic2);

    if nrows1 < nrows2
        mosaic1(nrows2, :) = 0;
        tile_mask1(nrows2, :) = 0;
    elseif nrows1 > nrows2
        mosaic2(nrows1, :) = 0;
        tile_mask2(nrows1, :) = 0;
    end

    if ncols1 < ncols2
        mosaic1(:, ncols2) = 0;
        tile_mask1(:, ncols2) = 0;
    elseif ncols1 > ncols2
        mosaic2(:, ncols1) = 0;
        tile_mask2(:, ncols1) = 0;
    end
    tile_sz = size(mosaic1);

    %Register the two mosaics
    mosaic12 = cat(3, mosaic1, mosaic2);
    tile_mask12 = cat(3, tile_mask1, tile_mask2);
    [frame_transforms] = register_tiles_features(mosaic12, ...
        'tile_masks', tile_mask12,... % NEED TO PASS IN THESE ARGS 
        'theta_range', args.theta_range, ...
        'offset_lim', args.offset_range, ...
        'sigma', args.sigma,...
        'debug', args.debug);

    % Get size of the combined reference frame
    [mosaic_sz, frame_transforms] = mosaic_limits(tile_sz, frame_transforms);

    save([args.save_dir 'difference_image_t2tf1_2_reginfo' zerostr(iLoops, 3) '.mat'],... % will save as "dif_img_t0dual_reginfo"
        'frame_transforms');

    
    
    
    %% Get capillary masks (see code in ROIPoly_Test.m)
    x0_t0 = frame_transforms(1,3,1);
    y0_t0 = frame_transforms(2,3,1); 
    % !!! TO DO: does t0 have zero x0 y0? Want to make mask on tile with
    % zero x0, y0 (ideally t0) and use second tile's nonzero x0 y0 to shift
    % mask
    
    %second time frame dual image's shift:
    x0_2 = frame_transforms(1,3,2);
    y0_2 = frame_transforms(2,3,2); 
    
    shift_x = abs(x0_2 - x0_t0);        %TO DO: think use absolute value because shift is always positive???
    shift_y = abs(y0_2 - y0_t0);
    
   
    %adjust mask so that it covers the same region on both tiles
    mask_adjusted = padarray(mask,[y0 x0], 0 ,'pre');
    [nrows_di ncols_di] = size(difference_image);
    [nrows_ma ncols_ma] = size(mask_adjusted);
    
    if (nrows_ma > nrows_di) || (ncols_ma > ncols_di) 
    mask_adjusted(nrows_di + 1:nrows_ma,:) = [];
    mask_adjusted(ncols_di + 1:ncols_ma,:) = [];
end
if (nrows_ma < nrows_di) || (ncols_ma < ncols_di)
        mask_adjusted(nrows_di, ncols_di) = 0;
end
    
    