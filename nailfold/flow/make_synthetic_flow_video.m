function [] = make_synthetic_flow_video(vessel_name, max_flow, varargin)
%MAKE_SYNTHETIC_FLOW_COMPARISON_VIDEO generates synthetic flow videos using real
%capillary shapes
%   [] = make_synthetic_flow_comparison_video('normalapex0008', 3, 1.5, 'adjacent_videos', 0)
%
% MAKE_SYNTHETIC_FLOW_COMPARISON_VIDEO uses the U_PACKARGS interface function
% and so arguments to the function may be passed as name-value pairs
% or as a struct with fields with corresponding names.
%
% Mandatory Arguments:
% - vessel_name: name of the real vessel contour used as the shape (defines
% the vessel's centre line, inner and outer edges and locations of any
% apices in variables: vessel_centre, inner_edge, outer_edge (all n x 2)
% and apex_idx (m x 1, where vessel_centre(apex_idx(i),:) are the x,y
% coordinates of the i'th apex). For normal 'single loop' capillaries m = 1
%
% - max_flow: the maximum flow (effectively the number of pixels a red
% blood moves in a signle frame) in the synthesised flow field. Flow in the
% rest of the vessel will be scaled to the inverse square of vessel width
% so that a constant theoretical volumetric flow rate is maintained
% throught the vessel. One set of coloured tags in the final will move at the
% exact rate defined by this flow field
%
% - speed_factor: the factor by which the 'wrong' display tags are scaled.
% This scaling is applied equally throughout the flow field, so for example
% if speed_factor = 1.5, the 'wrong' tags will be 50% faster than the true
% flow throughout the vessel
%
% Optional Arguments: see unpack arguments below
%
% Outputs:
%
% Example:[] = make_flow_comparison_video('normal001', 3, 1.5, 'load_saved', 0)
%
% Notes: Uses real vessel outlines to generate synthetic flow videos with
% user defined flow rates, and display tags, one set of which follow the
% true flow, one set of which are faster/slower by a user defined scale
% factor. The videos can either be generated with the vessels side by side
% and one set of red tags on each, or as one vessel, with red/green tags.
% In either case whether the 'right' tags are red/green or left/right is
% randomly selected at run time, and recorded in the video name
%
% See also:
%
% Created: 15-Feb-2016
% Author: Michael Berks 
% Email : michael.berks@manchester.ac.uk 
% Phone : +44 (0)161 275 7669 
% Copyright: (C) University of Manchester 

% Unpack the arguments:
args = u_packargs(varargin,... % the user's input
    '0', ... % non-strict mode
    'contour_dir',          '\\nasr.man.ac.uk\epsrss$\snapped\replicated\MSI\flow_project\vessel_contours\',... %Where the contour data files live
    'video_dir',            '\\nasr.man.ac.uk\epsrss$\snapped\replicated\MSI\flow_project\flow_videos\synthesised\',... %Where the videos (and associated flow data) are saved to
    'load_saved',           false,... %If true, will load previous flow field and cell positions. Allows user to quickly generate multiple wrong examples for the same underlying true speed
    'overwrite',            true,... %If true, saves the new flow field over the top of any existing data for the contour in the video directory
    'cell_density',         10,... %Density of cells in the synthesised video - try adjusting to see how it affects the ability to perceive flow
    'num_frames',           240,... %Together with frame_rate defines video length
    'speckle_noise',        0.01,... %Changes how noisy the videos are, increasing speckle noise decreases video quality, may be worth experimenting with to see if effects how easy the task is
    'snap_to_centre',       true,... %Leave true, not snapping to centre doesn't work properly!
    'tag_spacing',          100,... %Approx number of pixels along the vessel path between starting positions of the display tags
    'scale_cell_width',     0,... %Can choose to scale red blood cell size to the vessel width, physiologically this doesn't make much sense, so best leave at 0
    'fixed_cell_width',     10,... %If above is 0, this defines blood cell width
    'scale_tag_width',      0,... %Can scale tag size to vessel width, can experiment to see which you think makes the task easier
    'fixed_tag_width',      2, ... %If above is zero, defines the radius of the tags
    'solid_tags',           true,... %If false, creates rings rather than solids circles
    'adjacent_videos',      false,... %If false produces an overlay video with one vessel and red green tags, if true creates adjacent videos with red tags.
    'temp_frames_dir',      [],... if empty, uses the system temporary dir
    'frame_rate',           30,...
    'debug',                false,...
    'plot', 0);
clear varargin;

%We need this created (if not already) to save data to
if ~exist(args.video_dir, 'dir')
	mkdir(args.video_dir);
end

if args.load_saved
    %Load flowmap, mask, vessel_centre, widths, cell_sz and cell_positions 
    %from saved data
    load([args.video_dir vessel_name '_syn_flow.mat'],...
        'flowmap', 'mask', 'vessel_centre', 'widths', 'apex_idx', 'cell_sz', 'cell_positions');
    
else

    %Load in the vessel contour - will load variables vessel_centre,
    %inner_edge, outer_edge and apex_idx
    load([args.contour_dir vessel_name '_vessel_vc.mat'],...
        'vessel_centre', 'inner_edge', 'outer_edge', 'apex_idx');
    apex_idx = sort(apex_idx); %#ok
    
    %Make a flowmap for the vessel shape
    [flowmap, mask, vessel_centre, widths] = ...
        create_flowmap_profile(vessel_centre, inner_edge, outer_edge, apex_idx, []); %#ok
    flowmap = max_flow*flowmap;
    
    %Set the cell size and compute number of cells to use
    if args.scale_cell_width
        cell_sz = min(widths(:));
    else
        cell_sz = args.fixed_cell_width;    
    end
    %Doing this by area only seems to work well for normal size vessels,
    %because their volume is commensurate with their width, for giants we
    %need to consider cell and vessel volume
    %n_pixels_per_cell = cell_sz^2;
    %n_mask_pixels = sum(mask(:)>0);
    cell_vol = cell_sz^3;
    vessel_vol = sum(mask(:)>0) * mean(widths);
    num_cells = ceil(args.cell_density * vessel_vol / cell_vol);

    %Generate cell positions for each frame
    cell_positions = generate_cell_positions_layers(flowmap, mask, ...
        vessel_centre, widths, ...
        num_cells, args.num_frames+1);
    
    %Save this data
    if ~exist([args.video_dir vessel_name '_syn_flow.mat'], 'file') || ...
            args.overwrite
        
        save([args.video_dir vessel_name '_syn_flow.mat'],...
            'flowmap', 'mask', 'vessel_centre', 'widths', 'apex_idx', 'cell_sz', 'cell_positions');
    end
            
end

%Get size of flow map
[flow_h flow_w n_layers] = size(flowmap);

%Set the display tag radius - fixed or based on the frame width?
if args.scale_tag_width
    tag_radius = widths(apex_idx(1)) * args.scale_tag_width * 0.25;
else
    tag_radius = args.fixed_tag_width;    
end
tag_radius2 = tag_radius^2;

%Set the first point, the select equally spaced further points on the
%vessel
first_pt = ceil(tag_radius) + ceil(tag_radius*rand);

vessel_centre_hi = spline_contour(vessel_centre, [], 1);
num_pts = size(vessel_centre_hi,1);

apex_idx_hi = zeros(n_layers,1);
for i_n = 1:n_layers-1
    d = ...
        (vessel_centre(apex_idx(i_n),1) - vessel_centre_hi(:,1)).^2 + ...
        (vessel_centre(apex_idx(i_n),2) - vessel_centre_hi(:,2)).^2;
    [~,apex_idx_hi(i_n)] = min(d);
end
apex_idx_hi(n_layers) = num_pts;   

num_tags = ceil(num_pts / args.tag_spacing);
idx = round(linspace(first_pt, num_pts, num_tags+1));
idx(end) = [];

%Tag points define x,y coordinate and flow layer
tag_pts = zeros(num_tags, 4, 2);
tag_pts(:,1:2,1) = vessel_centre_hi(idx,:);
tag_pts(:,1:2,2) = vessel_centre_hi(idx+2,:);

tag_pts(:,3,:) = 1;
for i_layer = 1:n_layers - 1
    tag_pts(idx > apex_idx_hi(i_layer),3,:) = i_layer + 1;
end
tag_pts(:,4,1) = idx;
tag_pts(:,4,2) = idx+2;

if args.debug
    tag_history = zeros(num_tags, 4, 2, args.num_frames);
    tag_history(:,:,:,1) = tag_pts;
end

%Set up points matrices to compute tag masks
xx = repmat(1:flow_w, flow_h, 1);
yy = repmat((1:flow_h)', 1, flow_w);

%Make a temporary directory to store frame in
if isempty(args.temp_frames_dir)
    temp_frames_dir = tempname;
else
    temp_frames_dir = args.temp_frames_dir;
end
mkdir(temp_frames_dir);

%Choose which colour tags are the 'true' tags
if rand > 0.5
    scaling = [1.0 speed_factor];
else
    scaling = [speed_factor 1.0];
end

%Make background texture
cloud_add = noiseonf(max(flow_h, flow_w), 1.5);
cloud_add = 32 * normim(cloud_add(1:flow_h,1:flow_w), 'stretch_fixed');

cloud_mult = noiseonf(max(flow_h, flow_w), 1.5);
cloud_mult = 0.75 * normim(cloud_mult(1:flow_h,1:flow_w), 'stretch_fixed');
cloud_mult = 1 - cloud_mult;

%--------------------------------------------------------------------------
%Now we can make our video
%--------------------------------------------------------------------------
for i_fr = 1:args.num_frames;

    if args.adjacent_videos
        vid_frame = zeros(flow_h, 2*flow_w + 16, 3, 'uint8'); 
    else
        vid_frame = zeros(flow_h, flow_w, 3, 'uint8'); 
    end
    
    %Make the synthetic frame
    vid_frame_i = make_frame(cell_positions(:,:,i_fr:i_fr+1), ...
                     [flow_h flow_w], cell_sz, ...
                     [], 128 + cloud_add, 200 * cloud_mult, inf, args.speckle_noise); %
                 
    if i_fr > 1
        tag_history(:,:,:,i_fr) = tag_pts;
    end

    for i_dim = 1:2
        %Add the display tags to this frame
        frame_i = vid_frame_i;

        %For each tag
        for i_tag = 1:num_tags

            %Make cell mask at current position
            ix = tag_pts(i_tag,1,i_dim);
            iy = tag_pts(i_tag,2,i_dim);
            iz = tag_pts(i_tag,3,i_dim);
            ii = tag_pts(i_tag,4,i_dim);
            
            xy2 = (xx-ix).^2 + (yy-iy).^2;
            cell_mask = xy2 < tag_radius2;
            if ~args.solid_tags
                cell_mask = cell_mask & xy2 > (tag_radius2/4);
            end
            frame_i(cell_mask) = 255;    

            %If we're still in a valid position, move to next position
            %based on flow estimate
            if ix > 1 && ix < flow_w && iy > 1 && iy < flow_h;
                
                %Check if we've moved layers
                if iz < n_layers && ...
                        ~mask(round(iy), round(ix), iz) && mask(round(iy), round(ix), iz+1)
                    jz = iz + 1;
                else
                    jz = iz;
                end                  
                
                fxyi = flowmap(round(iy), round(ix), iz);
                
                if ~isnan(fxyi)
                    jx = ix + scaling(i_dim)*real(fxyi);
                    jy = iy + scaling(i_dim)*imag(fxyi);
                    
                    if jz < n_layers && ii > apex_idx_hi(iz)
                        jz = iz + 1;
                    else
                        jz = iz;
                    end
                    
                    if args.snap_to_centre
                        %Allow to move only to vessel points in this layer
                        %or the first 5 points of the next layer to avoid
                        %crossing on to the next layer (while still alowing
                        %it to transition layers)!
                        available_pts = ii+1:min(apex_idx_hi(jz)+5,num_pts);
                        d = ...
                            (vessel_centre_hi(available_pts,1)-jx).^2 +...
                            (vessel_centre_hi(available_pts,2)-jy).^2;
                        [~,idx] = min(d);
                        ji = idx + ii;
                        jx = vessel_centre_hi(ji,1);
                        jy = vessel_centre_hi(ji,2);
                    else
                        ji = ii;
                    end
                    tag_pts(i_tag,1,i_dim) = jx;
                    tag_pts(i_tag,2,i_dim) = jy;
                    tag_pts(i_tag,3,i_dim) = jz;
                    tag_pts(i_tag,4,i_dim) = ji;
                else
                    %Otherwise start at the beginning
                    tag_pts(i_tag,:,i_dim) = [vessel_centre_hi(first_pt,1:2) 1 first_pt];
                end
            else
                %Otherwise start at the beginning
                tag_pts(i_tag,:,i_dim) = [vessel_centre_hi(first_pt,1:2) 1 first_pt];
            end
        end

        %Put frames either on top or by one another
        if args.adjacent_videos
            vid_frame(:, (1:flow_w) + (i_dim-1)*(flow_w + 16), 1) = uint8(frame_i);
            vid_frame(:, (1:flow_w) + (i_dim-1)*(flow_w + 16), 2) = uint8(vid_frame_i);
            vid_frame(:, (1:flow_w) + (i_dim-1)*(flow_w + 16), 3) = uint8(vid_frame_i);
        else
            vid_frame(:, :, i_dim) = uint8(frame_i);
        end

    end
    if ~args.adjacent_videos
        vid_frame(:, :, 3) = uint8(vid_frame_i);
    end

    %Write the frame to the temporary directory
    imwrite(vid_frame,...
        [temp_frames_dir '\frame' zerostr(i_fr,4) '.bmp']);
end

%Make path to save video
if args.adjacent_videos
    video_path = [args.video_dir vessel_name ...
        '_f1_' num2str(scaling(1),3) '_f2_' num2str(scaling(2),3) '_adjacent.mp4'];
else
    video_path = [args.video_dir vessel_name ...
        '_f1_' num2str(scaling(1),3) '_f2_' num2str(scaling(2),3) '_overlay.mp4'];
end
cmd = ['ffmpeg -y -r ' num2str(args.frame_rate) ' -i "' temp_frames_dir '\frame%04d.bmp" -c:v libx264 -preset slow -crf 18 -an "' video_path '"'];
system(cmd);

delete([temp_frames_dir '\*']);
rmdir(temp_frames_dir);