%% load code
addpath(genpath('C:\Users\MPhys2016\Documents\GitHub\isbe'));
frames_dir = 'C:\Users\MPhys2016\Desktop\tf_split_testing\_testing_17.02.27 - exp60.04 g718 - Juliana - 560 500 cam1 t2tf\';

d0 = load(fullfile(frames_dir, 'difference_images_f\', 'difference_image_t2tf001'));

figure; difference_image = imgray(d0.registered_difference); % load grey image for using roipoly on, from d0
vessel_mask = roipoly; %Display image and allows you to interactively select region-of-interest
% if you want to get multiple vessels:
%vessel_mask = vessel_mask1 | vessel_mask2; % create overalls vessel mask
% imshow(vessel_mask); % displays mask OK

%**IMPORTANT** whenever you modify mosaic1, do the same to  vessel mask**%
 
% load in a few "inputs" for register_tiles_features(mosaic12,...)
   theta_range =  -15:3:15; ...
   offset_range = 240;
   sigma =  8;
   debug =  false;

 for dif_img_time_i = 1 %loop over difference images
      %CHANGE TO = 1:2 (OR 1:3 WHEN USING TF)
     if (dif_img_time_i == 1)
        d1 = load(fullfile(frames_dir, 'difference_images_f\', 'difference_image_t2tf001'));
     end

     if (dif_img_time_i == 2)
       d1 = load(fullfile(frames_dir, 'difference_images_f\', 'difference_image_t2tf003'));
     end
     

    
    
     %do this for a tf dualdif image too

     mosaic1 = d0.registered_mosaics(:,:,1); % e.g. t0,530 compound image
     mosaic2 = d1.registered_mosaics(:,:,1); % e.g. t1,530 compound image
     tile_mask1 = d0.registered_masks(:,:,1); % e.g. t0,530 & t0,560 overlapping area only
     tile_mask2 = d1.registered_masks(:,:,1); % e.g. t1,530 & t1,560 overlapping area only

     % TESTING TO SEE IF PADDING 1 IMAGE (2 IMAGES SAME) GIVES EQUAL FINAL
     % RESULTS
     % pad top left
    mosaic2 = padarray(mosaic2,[25 50], 0 ,'pre');
    % "antipad" bottom right
    [nrows_mos1 ncols_mos1] = size(mosaic1);
    % remove from top left, requires 'post' in above
%      mosaic2(1:25,:)= [];
%      mosaic2(:,1:50) = [];
            % remove from top right, requires 'pre' in above
            mosaic2(nrows_mos1 + 1:end,:)= [];
            mosaic2(:,ncols_mos1 +1:end) = [];
    
    tile_mask2 = padarray(tile_mask2,[25 50], 0 ,'pre');
    % "antipad" bottom right
    [nrows_tilemask1 ncols_tilemask1] = size(tile_mask1);
    % remove from top left, requires 'post' in above
%      tile_mask2(1:25,:)= [];
%      tile_mask2(:,1:50) = [];
        % remove from bottom right, requires 'pre' in above
        tile_mask2(nrows_tilemask1 + 1:end,:)= [];
        tile_mask2(:,ncols_tilemask1 +1:end) = [];
    
    
            %testing  
    figure; imgray(mosaic1.*vessel_mask); title('d0 mosaic initial');
    figure; imgray(mosaic2.*vessel_mask); title('d1 mosaic initial');
        
    %Get the relative sizes of the two mosaics, increase the size of the
    %smaller
    [nrows1 ncols1] = size(mosaic1);
    [nrows2 ncols2] = size(mosaic2);

    %**IMPORTANT** whenever you modify mosaic1, do the same to  vessel mask**%
    % resize mosaics and tile masks
    if nrows1 < nrows2
        mosaic1(nrows2, :) = 0;
        tile_mask1(nrows2, :) = 0;
        vessel_mask(nrows2, :) = 0;
    elseif nrows1 > nrows2
        mosaic2(nrows1, :) = 0;
        tile_mask2(nrows1, :) = 0;
    end

    if ncols1 < ncols2
        mosaic1(:, ncols2) = 0;
        tile_mask1(:, ncols2) = 0;
        vessel_mask(:, ncols2) = 0;
    elseif ncols1 > ncols2
        mosaic2(:, ncols1) = 0;
        tile_mask2(:, ncols1) = 0;
    end
    tile_sz = size(mosaic1);

    %Register the two mosaics
    mosaic12 = cat(3, mosaic1, mosaic2);
    tile_mask12 = cat(3, tile_mask1, tile_mask2);
        
    [frame_transforms] = register_tiles_features(mosaic12, ... 
        'tile_masks', tile_mask12,...
        'theta_range', theta_range, ...
        'offset_lim', offset_range, ...
        'sigma', sigma,...
        'debug', debug);

    % get mosaic_sz, rename a variable (frame_transforms) so it doesn't
    % get overwritten
    % Get size of the combined reference frame
    [mosaic_sz, adjusted_frame_transforms] = mosaic_limits(tile_sz, frame_transforms);
    
    %if vessel mask defined on d0
    [vessel_mask_adjusted_cell] = sample_tile_image(...
            {double(vessel_mask)}, ones(tile_sz), ...
            adjusted_frame_transforms(:,:,1), ...
            mosaic_sz, []);
    vessel_mask_adjusted = vessel_mask_adjusted_cell{1} > 0;
    
    mean_val_d0 = nanmean(d0.registered_difference(vessel_mask_adjusted)); % get mean of vessel_mask'd region
    mean_val_d1 = nanmean(d1.registered_difference(vessel_mask_adjusted)); % get mean of vessel_mask'd region
    
    % mike commented this out 
    % %else if vessel mask defined on d1
    % [vessel_mask_d0] = sample_tile_image(...
    %         {double(vessel_mask)}, ones(tile_sz), ...
    %         inv(frame_transforms(:,:,2)), ...
    %         mosaic_sz, []);    
    
    
  
    %save vessel_mask_d1
    filename2save = strcat('vessel_mask_d',num2str(dif_img_time_i),'.mat');
    save([fullfile(frames_dir, 'difference_images_f\', filename2save)],...
            'vessel_mask_d1');
    
    %use vessel mask to get summary stats from d1 difference image
    

    
    %vessel_mask_d1_asARRAY = cell2mat(vessel_mask_d1);
    %vessel_mask_d1_asARRAY(isnan(vessel_mask_d1_asARRAY))=0;
    % make d1 mask same size as d1.registereed difference
    
     %adjust mask so that it covers the same region on both tiles
         
    x0_t0 = frame_transforms(1,3,1);
    y0_t0 = frame_transforms(2,3,1); 
    % !!! TO DO: does t0 have zero x0 y0? Want to make mask on tile with
    % zero x0, y0 (ideally t0) and use second tile's nonzero x0 y0 to shift
    % mask
    
    %second time frame dual image's shift:
    x0_t1 = frame_transforms(1,3,2);
    y0_t1 = frame_transforms(2,3,2); 
    
    shift_x = (x0_t1 - x0_t0);        %TO DO: think use absolute value because shift is always positive???
    shift_y = (y0_t1 - y0_t0);
      
    %testing 'if' idea
    if (shift_x >0 && shift_y>0)    
    mask_adjusted = padarray(vessel_mask_d1_asARRAY,[shift_y shift_x], 0 ,'pre');
    end
    
    %Testing
    %if (shift_x < 0 && shift_y < 0)    
    %mask_adjusted = padarray(vessel_mask_d1_asARRAY,[-shift_y -shift_x], 0 ,'pre');
    %end
    
    [nrows_di ncols_di] = size(d1.registered_difference);
    [nrows_vm ncols_vm] = size(vessel_mask_adjusted);
    
    if (nrows_vm > nrows_di) || (ncols_vm > ncols_di) 
        mask_adjusted(nrows_di + 1:end,:)= [];
        mask_adjusted(:,ncols_di +1:end) = [];
    end
    
    if (nrows_vm < nrows_di) || (ncols_vm < ncols_di)
            mask_adjusted(nrows_di, ncols_di) = 0;
    end    
    
    
    mean_val_d0 = nanmean(d0.registered_difference(vessel_mask)); % get mean of vessel_mask'd region
    mean_val_d1 = nanmean(d1.registered_difference(logical(mask_adjusted))); % get mean of vessel_mask'd region
   
    
    fprintf('The mean value for the selected ROI is %f for d0\n',mean_val_d0);
    fprintf('The mean value for the selected ROI is %f for d1\n',mean_val_d1);
    
    figure; imgray(d0.registered_difference.*vessel_mask); title('d0 final');
    figure; imgray(d1.registered_difference.*logical(mask_adjusted)); title('d1 final');
    
 end
