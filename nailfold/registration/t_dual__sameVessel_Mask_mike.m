 d0 = load([]);
 vessel_mask_d0 = [];
 

 
 
 for %loop over difference images
     d1 = load([]);

     mosaic1 = d0.registered_mosaics(:,:,1);
     mosaic2 = d1.registered_mosaics(:,:,1);
     tile_mask1 = d0.registered_masks(:,:,1);
     tile_mask2 = d1.registered_masks(:,:,1);

    %Get the relative sizes of the two mosaics, increase the size of the
    %smaller
    [nrows1 ncols1] = size(mosaic1); % what's in view of all frames at first time
    [nrows2 ncols2] = size(mosaic2); % what's in view of all frames at second time

    % resize
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
        'tile_masks', tile_mask12,...
        'theta_range', args.theta_range, ...
        'offset_lim', args.offset_range, ...
        'sigma', args.sigma,...
        'debug', args.debug);

    %if vessel mask defined on d0
    [vessel_mask_d1] = sample_tile_image(...
            {double(vessel_mask_d0)}, ones(tile_sz), ...
            frame_transforms(:,:,2), ...
            mosaic_sz, []);
        
    %use vessel mask to get summary stats from d1 difference image
 end

% %else if vessel mask defined on d1
% [vessel_mask_d0] = sample_tile_image(...
%         {double(vessel_mask)}, ones(tile_sz), ...
%         inv(frame_transforms(:,:,2)), ...
%         mosaic_sz, []);