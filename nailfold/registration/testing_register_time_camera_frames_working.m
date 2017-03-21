function [] = testing_register_time_camera_frames_working(frames_dir, camera1_transforms, camera2_transforms, ranges, range_type, varargin)
%REGISTER_DUAL_CAMERA_FRAMES *Insert a one line summary here*
%   [] = register_dual_camera_frames(varargin)
%
% REGISTER_DUAL_CAMERA_FRAMES uses the U_PACKARGS interface function
% and so arguments to the function may be passed as name-value pairs
% or as a struct with fields with corresponding names. The field names
% are defined as:
%
% Mandatory Arguments:
%
% Optional Arguments:
%
% Outputs:
%
% Example:
%
% Notes:
%
% See also:
%
% Created: 14-Aug-2013
% Author: Michael Berks 
% Email : michael.berks@manchester.ac.uk 
% Phone : +44 (0)161 275 7669 
% Copyright: (C) University of Manchester 
% Unpack the arguments:
args = u_packargs(varargin, '0', ...
    'camera1_ext', '_C_1_',...
    'camera2_ext', '_C_2_',...
    'frames_dir', '',... %%jj frames directory, to save images to
    'correction_factor', 1,... % jj default factor of 1. 500nm overrrides this w/ 1.6
    'trial_number', 'trial number N' ,... % jj default trial number unknown
    'camera_filter', 'X nm',... 
    'image_format', 'bmp',...
    'save_images', 1,...
    'save_dir', [], ...
    'save_name', [], ...
    'theta_range', -15:3:15,...
    'offset_range', 240,...
    'sigma', 8,...
    'display_output', 1,...
    'debug', false);
clear varargin;

if args.save_images && isempty(args.save_dir)
    args.save_dir = [frames_dir 'difference_images\'];
end
if args.save_images
    create_folder(args.save_dir);
end

%%-------------------------------------------------------------------------
% Get list of frame names
camera1_frame_names = dir_to_file_list([frames_dir '*' args.camera1_ext '*.' args.image_format]);
camera2_frame_names_safe = dir_to_file_list([frames_dir '*' args.camera2_ext '*.' args.image_format]);

num_frames1 = length(camera1_frame_names);
num_frames2 = length(camera2_frame_names_safe);
numLoops = num_frames2/60; %jj 
camera2_frame_names=camera2_frame_names_safe(1:60);


    if num_frames1 == 0
        error('No frames found for camera 1');
    elseif num_frames2 == 0
        error('No frames found for camera 1');
    elseif num_frames1 ~= num_frames2
        %error('Number of frames do not match');
    end
    num_frames = num_frames1; clear num_frames1 num_frames2;

for iLoops = 1:numLoops % 1:numLoops, if doing a whole analysis

    if strcmp(range_type, 'time')
        %Get list of their times relative to the first frame of camera 1
        [dummy, frame_name] = fileparts(camera1_frame_names{1});
        clear dummy;

        mm = str2num(frame_name(28:29));
        ss = str2num(frame_name(31:32));
        ms = str2num(frame_name(34:36));
        t1_base = 60*mm + ss + ms/1000;

        times1 = zeros(num_frames, 1);
        times2 = zeros(num_frames, 1);

        for i_frame = 1:num_frames

            [dummy, frame_name] = fileparts(camera1_frame_names{i_frame});
            clear dummy;

            mm = str2num(frame_name(28:29));
            ss = str2num(frame_name(31:32));
            ms = str2num(frame_name(34:36));

            times1(i_frame) = (60*mm + ss + ms/1000) - t1_base;

            [dummy, frame_name] = fileparts(camera2_frame_names{i_frame});
            clear dummy;

            mm = str2num(frame_name(28:29));
            ss = str2num(frame_name(31:32));
            ms = str2num(frame_name(34:36));

            times2(i_frame) = (60*mm + ss + ms/1000) - t1_base;
        end
    end

    num_ranges = size(ranges, 1);
    for i_rng = 1:num_ranges
        if strcmp(range_type, 'time')
            %Get frames from each camera in this time ranges
            include_frames1 = find(...
                (times1 >= ranges(i_rng,1)) & (times1 < ranges(i_rng,2)) );
            include_frames2 = find(...
                (times2 >= ranges(i_rng,1)) & (times2 < ranges(i_rng,2)) );

        else
            %Otherwise the ranges should just be the ith row of ranges
            include_frames1 = ranges(i_rng,1):ranges(i_rng,2);
            include_frames2 = ranges(i_rng,1):ranges(i_rng,2);
        end

        %Create mosaic for each camera
        [mosaic1, weights1] = create_mosaic(...
            camera1_frame_names(include_frames1), camera1_transforms(:,:,include_frames1), 'uniform');    
        tile_mask1 = weights1 == length(include_frames1);

        [mosaic2, weights2] = create_mosaic(...
            camera2_frame_names(include_frames2), camera2_transforms(:,:,include_frames2), 'uniform');
        tile_mask2 = weights2 == length(include_frames2);

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
            'tile_masks', tile_mask12,...
            'theta_range', args.theta_range, ...
            'offset_lim', args.offset_range, ...
            'sigma', args.sigma,...
            'debug', args.debug);

        % Get size of the combined reference frame
        [mosaic_sz, frame_transforms] = mosaic_limits(tile_sz, frame_transforms);

        registered_mosaics = zeros(mosaic_sz(1), mosaic_sz(2), 2);
        registered_masks = false(mosaic_sz(1), mosaic_sz(2), 2);
        for i_cam = 1:2

            [tile_out] = sample_tile_image(...
                {mosaic12(:,:,i_cam)}, ones(tile_sz), ...
                inv(frame_transforms(:,:,i_cam)), ...
                mosaic_sz, []);

            [mask_out] = sample_tile_image(...
                {double(tile_mask12(:,:,i_cam))}, ones(tile_sz), ...
                inv(frame_transforms(:,:,i_cam)), ...
                mosaic_sz, []);

            registered_masks(:,:,i_cam) = full(mask_out{1}) > 0.5;
            registered_mosaics(:,:,i_cam) = full(tile_out{1});

        end

        registered_difference = registered_mosaics(:,:,1) - registered_mosaics(:,:,2);
        joint_mask = registered_masks(:,:,1) & registered_masks(:,:,2);
        registered_difference(~joint_mask) = NaN;

        % create difference image name
        %difference_mat_name = strcat('difference_image_t2tf',zerostr(iLoops, 3)) ;
        
    if args.save_images % add gmin, gmax to save file 
        gmin = nanmin(mosaic12(tile_mask12)); %get gmin & gmax before saving of .mat (so scaledBrightness image can be made)
        gmax = nanmax(mosaic12(tile_mask12));
        gmin_r = nanmin(registered_mosaics(registered_masks)); %
        gmax_r = nanmax(registered_mosaics(registered_masks));
        
        save([args.save_dir 'difference_image_t2tf' zerostr(iLoops, 3) '.mat'],...
            'mosaic12', 'tile_mask12', 'registered_difference', ...
            'registered_mosaics', 'registered_masks', 'include_frames1', 'include_frames2',...
            'gmin', 'gmax', 'gmin_r', 'gmax_r');
    end

        if args.display_output

            gmin = nanmin(mosaic12(tile_mask12));
            gmax = nanmax(mosaic12(tile_mask12));

            mosaic_rgb = 1-(mosaic12 - gmin) / (gmax-gmin);
            mosaic_rgb(~tile_mask12) = 0;
            mosaic_rgb(:,:,3) = 0;

            gmin_r = nanmin(registered_mosaics(registered_masks));
            gmax_r = nanmax(registered_mosaics(registered_masks));
            reg_mosaic_rgb = 1-(registered_mosaics - gmin_r) / (gmax_r-gmin_r);
            reg_mosaic_rgb(~registered_masks) = 0;
            reg_mosaic_rgb(:,:,3) = 0;

            % jj don't seem to be applying correction factor twice
            %mosaic_rgb = mosaic_rgb * args.correction_factor; % jj apply correction factor
            %reg_mosaic_rgb = reg_mosaic_rgb * args.correction_factor; % jj apply correction factor
                 % didn't want to apply the correction here actually - registration comparison washed out  
            registered_difference = registered_difference * args.correction_factor; % jj apply correction factor


% % % % % % %             %% registration images
% % % % % % %             figure; 
% % % % % % %             subplot(1,2,1); non_registered_image = imgray(mosaic_rgb); 
% % % % % % %             title(sprintf('Non-overlapping compound frames pre-registration for %d nm filter', args.camera_filter));
% % % % % % % 
% % % % % % %             % Save the unregistered image
% % % % % % %             fullfile_unreg = fullfile(args.frames_dir, '_Unregistered image'); 
% % % % % % %             saveas(non_registered_image, fullfile_unreg, 'bmp'); %bmp
% % % % % % %             saveas(non_registered_image, fullfile_unreg, 'meta'); %emf 
% % % % % % %             saveas(non_registered_image, fullfile_unreg, 'fig'); %fig
% % % % % % % 
% % % % % % %             subplot(1,2,2); registered_image = imgray(reg_mosaic_rgb);
% % % % % % %             title(sprintf('Aligned compound frames after registration for %d nm filter', args.camera_filter));
% % % % % % %             % Save the registered image
% % % % % % %             fullfile_reg = fullfile(args.frames_dir, '_Registered image');
% % % % % % %             saveas(registered_image, fullfile_reg, 'bmp'); %bmp
% % % % % % %             saveas(registered_image, fullfile_reg, 'meta'); %emf 
% % % % % % %             saveas(registered_image, fullfile_reg, 'fig'); %fig
% % % % % % % 
            %% difference image
            figure('visible','off');
            difference_image = imgray(registered_difference);
            title(sprintf('Difference between compound frames for %d nm filter, for t2tf%i', args.camera_filter, iLoops)); % FOR T2TFX  iLoops
            colormap jet;
            colorbar;
            % Save the difference image
            fullfile_dif = fullfile(args.save_dir,strcat('_Difference image_t2tf',zerostr(iLoops, 3))); % FOR T2TFX
            saveas(difference_image, fullfile_dif, 'meta'); %emf
            saveas(difference_image, fullfile_dif, 'fig'); %fig  
            saveas(difference_image, fullfile_dif, 'bmp'); %bmp  
% % % % % % % 
% % % % % % %             %% max and min of difference image
% % % % % % %             % NOT SURE IF THIS WILL WORK WITH COLORMAP & COLORBAR
% % % % % % %             %fprintf('Max of dif_image: %d\nMin of dif_image: %d\n',max(max(difference_image)),min(min(difference_image)));

        end
    end
    camera2_frame_names_safe(1:60)=[]; % remove the first 60 frames of "many" frames
    camera2_frame_names=camera2_frame_names_safe(1:60); % load the next 60 frames in for registration
    fprintf('Number of batches registered and differenced: %i. %i loops remaining!\n',iLoops,numLoops-iLoops);
end                            
                            

