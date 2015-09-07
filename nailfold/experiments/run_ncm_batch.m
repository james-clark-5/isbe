%Sorting out data for the 2 year study

%Notes:
% Base directory on MB's local machine is C:/isbe/nailfold/data/2_year_study
% Original data stored on the network drive at "N:/musculoskeletal/NCM only studies/2 yr data incl marina mark up".  
% Images (originally in .bmp) from dir "anonymous_bmap_files1" and its sub-dir "Additional mosaics 28-03-2014" 
% converted to .png/.mat format and stored in "anonymous_png"/"images" respectively. 
% .mat images are downsized by a factor of 2
function run_ncm_batch(local_root, steps, varargin)

args = u_packargs(varargin,... % the user's input
    '0', ... % non-strict mode
    'im_names',             [],...
    'im_idx',               [],...
    'prob_dir',             'rf_classification/296655/',... 296655
    'ori_dir',              'rf_regression/296621/',...
    'width_dir',            'rf_regression/297037/',...
    'fov_mask_dir',         'fov_masks/',...
    'centre_dir',           'vessel_centres/',...
    'apex_map_dir',         'apex_maps/set12g_half_296655',...
    'candidates_dir',       'version0',...
    'hog_dir',              'hogs',...
    'rescore_dir',          'rescores',...
    'displacement_dir',     'displacements',...
    'selected_dir',         'selected_apexes',...
    'metrics_dir',          'apex_metrics',...
    'aam_dir',              'aam',...
    'feature_im_dir',       'images',...
    'save_dir',             'results',....
    'model_dir',            [nailfoldroot 'data/rsa_study/models/apex_templates/'],...
    'apex_class_rf',        [nailfoldroot 'models/apex/rescoring/miccai_all/rf.mat'],...        
    'class_map',            [nailfoldroot,'models/apex/final_MAP/miccai_class_MAP/class_map.mat'],...
    'aam_name',             'aam/orig/2/vessel_apex_orig.smd',...
    'xls_filename',         'all_image_auto_measures.xls',...
    'prob_sigma',           1,...
    'ori_sigma',            0,...
    'width_sigma',          1,...
    'exclusion_zone',       20,...
    'transform_scores',     0,...
    'apex_class_thresh',    0.5,...
    'discard_pts',          0,...
    'base_width',           20,...
    'use_island_max',       0,...
    'island_thresh',        0,...
    'feature_sigma',        0,...
    'num_cells',            8,...
    'cell_sz',              8,... %Size of HoG cells in blocks
    'block_sz',             [2 2],...%Size of blocks in cells
    'num_ori_bins',         12,... %Number of bins in orientation histograms
    'norm_method',          'l1-sqrt',... %Method for local normalisation
    'block_spacing',        8,... %Separation between blocks in pixels - controls level of overlap
    'gradient_operator',    [-1 0 1],...
    'spatial_sigma',        0, ...
    'angle_wrap',           1,...
    'dist_thresh',          24^2,...
    'min_candidates',       3,...
    'initial_thresh',       0.3,...
    'grid_spacing',         8,...
    'strong_vessel_thresh', 0.8,...
    'angle_discard_thresh', 75*pi/180,...
    'do_final_cull',        1,...
    'do_post_merge',        1,...
    'merge_dist_thresh',    60,...
    'merge_connect_thresh', 0.25,...
    'merge_n_pts',          20,...
    'overwrite',            0,...
    'do_aam',               0,...
    'width_predictor',      [],...[nailfoldroot 'models/apex/width/rf.mat'],...
    'do_distal',            1,...
    'do_nondistal',         1,...
    'selected_features',    [],... %Do them all for now
    'plot_distal',          1,...
    'plot_nondistal',       1, ...
    'um_per_pix',           1.25,...
    'aam_thresh',           -2e4,...
    'plot_rejected',        1,...
    'plot_r',               1,...
    'plot_c',               1);

if isempty(args.im_names)
    im_names_s = dir([nailfoldroot 'data/' local_root '/images/*.mat']);
    num_ims = length(im_names_s);
    im_names = cell(num_ims,1);
    for i_im = 1:num_ims
        im_names{i_im} = im_names_s(i_im).name(1:end-4);
    end
else
    im_names = args.im_names;
    num_ims = length(im_names);
end

if isempty(args.im_idx)
    args.im_idx = 1:num_ims;
end

for i_step = steps
    
    switch i_step
        
        case 1
        %% ------------------------------------------------------------------------
            extract_vessel_centres_set(...
                'data_dir', [nailfoldroot 'data/' local_root '/'],...
                'num_jobs', 1, ...
                'task_id', 1,...
                'prob_dir',             args.prob_dir,... 296655
                'ori_dir',              args.ori_dir,...
                'width_dir',            args.width_dir,...
                'fov_mask_dir',         args.fov_mask_dir,...
                'centre_dir',           args.centre_dir,...
                'prob_sigma',           args.prob_sigma,...
                'ori_sigma',            args.ori_sigma,...
                'width_sigma',          args.width_sigma,...
                'overwrite',            args.overwrite);
        %%
        %--------------------------------------------------------------------------
        %Copy data to the CSF, run apex offset predictor on CSF to compute apex
        %offset map
        % DATA_ROOT="scratch/nailfold/" MODEL_ROOT="models/apex" MODEL_PATH="set12g_half_296655" NUM_JOBS=577 IMAGE_ROOT="data/anniek" IMAGE_DIR="predictions/detection/rf_classification/296655" MASK_DIR="fov_masks" OVERWRITE=0 THRESH=0.5 MODEL_NAME="rf" MAX_SIZE=1000 qsub -V -t 1 -l twoday matlab_code/trunk/hydra/cuc/predict_apex_offsets_set.sh
        case 2

            extract_apex_map_maxima( ... % the user's input
                'image_names',          im_names(args.im_idx),...
                'data_dir',             [nailfoldroot 'data/' local_root '/'],...
                'fov_mask_dir',         args.fov_mask_dir,...
                'centre_dir',           args.centre_dir,...
                'apex_map_dir',         args.apex_map_dir,...
                'candidates_dir',       [args.apex_map_dir '/' args.candidates_dir],...
                'exclusion_zone',       args.exclusion_zone,...
                'transform_scores',     args.transform_scores,...
                'apex_class_thresh',    args.apex_class_thresh,...
                'discard_pts',          args.discard_pts,...
                'base_width',           args.base_width,...
                'use_island_max',       args.use_island_max,...
                'island_thresh',        args.island_thresh,...
                'overwrite',            args.overwrite);
        %%
        case 3
            compute_apex_candidate_hogs( ... % the user's input
                'image_names',          im_names(args.im_idx),...
                'data_dir',             [nailfoldroot 'data/' local_root '/'],...
                'feature_im_dir',       'images',...
                'ori_dir',              args.ori_dir,...
                'width_dir',            args.width_dir,...
                'candidates_dir',       [args.apex_map_dir '/' args.candidates_dir],...
                'hog_dir',              [args.apex_map_dir '/' args.candidates_dir '/' args.hog_dir],...
                'feature_sigma',        args.feature_sigma,...
                'prob_sigma',           args.prob_sigma,...
                'ori_sigma',            args.ori_sigma,...
                'width_sigma',          args.width_sigma,...
                'num_cells',            args.num_cells,...
                'cell_sz',              args.cell_sz,... %Size of HoG cells in blocks
                'block_sz',             args.block_sz,...%Size of blocks in cells
                'num_ori_bins',         args.num_ori_bins,... %Number of bins in orientation histograms
                'norm_method',          args.norm_method,... %Method for local normalisation
                'block_spacing',        args.block_spacing,... %Separation between blocks in pixels - controls level of overlap
                'gradient_operator',    args.gradient_operator,...
                'spatial_sigma',        args.spatial_sigma, ...
                'angle_wrap',           args.angle_wrap,...
                'base_width',           args.base_width, ...
                'dist_thresh',          args.dist_thresh,...
                'overwrite',            args.overwrite);
        %%
        case 4
            rf = u_load(args.apex_class_rf);
            predict_apex_candidate_rescore(...
                'image_names',          im_names(args.im_idx),...
                'apex_class_rf',        rf,...
                'data_dir',             [nailfoldroot 'data/' local_root '/'],...
                'candidates_dir',       [args.apex_map_dir '/' args.candidates_dir],...
                'rescore_dir',          [args.apex_map_dir '/' args.candidates_dir '/' args.rescore_dir],...
                'hog_dir',              [args.apex_map_dir '/' args.candidates_dir '/' args.hog_dir]);

            compute_apex_candidate_displacements(...
                'image_names',          im_names(args.im_idx),...
                'data_dir',             [nailfoldroot 'data/' local_root '/'],...
                'vessel_centre_dir',    args.centre_dir,...
                'displacement_dir',     [args.apex_map_dir '/' args.candidates_dir '/' args.displacement_dir],...
                'candidates_dir',       [args.apex_map_dir '/' args.candidates_dir '/' args.rescore_dir],...
                'min_candidates',       args.min_candidates,...
                'initial_thresh',       args.initial_thresh,...
                'grid_spacing',         args.grid_spacing);
        %%
        case 5
            class_map = u_load(args.class_map);
            select_vessels_from_candidates( ...
                'image_names',          im_names(args.im_idx),...
                'data_dir',             [nailfoldroot 'data/' local_root '/'],...
                'class_map',            class_map,...
                'selected_dir',         [args.apex_map_dir '/' args.candidates_dir '/' args.selected_dir],...
                'displacement_dir',     [args.apex_map_dir '/' args.candidates_dir '/' args.displacement_dir],...
                'rescore_dir',          [args.apex_map_dir '/' args.candidates_dir '/' args.rescore_dir],...
                'strong_vessel_thresh', args.strong_vessel_thresh,...
                'angle_discard_thresh', args.angle_discard_thresh,...
                'do_final_cull',        args.do_final_cull,...
                'do_post_merge',        args.do_post_merge,...
                'merge_dist_thresh',    args.merge_dist_thresh,...
                'merge_connect_thresh', args.merge_connect_thresh,...
                'merge_n_pts',          args.merge_n_pts);
        %%
        case 6
            extract_apex_measures_set(...
                'image_names',          im_names(args.im_idx),...
                'data_dir',             [nailfoldroot 'data/' local_root '/'],...
                'image_dir',            args.feature_im_dir,...
                'prob_dir',             args.prob_dir,...
                'ori_dir',              args.ori_dir,...
                'width_dir',            args.width_dir,...
                'candidates_dir',       [args.apex_map_dir '/' args.candidates_dir '/' args.rescore_dir],...
                'displacements_dir',    [args.apex_map_dir '/' args.candidates_dir '/' args.displacement_dir],...
                'selected_dir',         [args.apex_map_dir '/' args.candidates_dir '/' args.selected_dir],...
                'metrics_dir',          [args.apex_map_dir '/' args.candidates_dir '/' args.metrics_dir],...
                'aam_dir',              args.aam_dir,...
                'do_aam',               args.do_aam,...
                'model_dir',            args.model_dir,...
                'aam_name',             args.aam_name,...
                'width_predictor',      args.width_predictor,...[nailfoldroot 'models/apex/width/rf.mat'],...
                'prob_sigma',           args.prob_sigma,...
                'ori_sigma',            args.ori_sigma,...
                'width_sigma',          args.width_sigma,...
                'do_distal',            args.do_distal,...
                'do_nondistal',         args.do_nondistal,...
                'plot', 0);
        %%
        case 7

            apex_stats_to_xls([],...auto_stats,...
                'image_names',          im_names(args.im_idx),...
                'data_dir',             [nailfoldroot 'data/' local_root '/'],...
                'vessel_centre_dir',    args.centre_dir,...
                'selected_dir',         [args.apex_map_dir '/' args.candidates_dir '/' args.selected_dir],...
                'metrics_dir',          [args.apex_map_dir '/' args.candidates_dir '/' args.metrics_dir],...
                'selected_features',    [],... %Do them all for now
                'xls_filename',         [args.results_dir '/' args.xls_filename],...
                'save_dir',             args.results_dir);
            
        case 8
            
            display_automated_markup(... % the user's input
                'image_names',          im_names(args.im_idx),...
                'data_dir',             [nailfoldroot 'data/' local_root '/'],...
                'image_dir',            args.image_dir,...
                'vessel_centre_dir',    args.centre_dir,...
                'selected_dir',         [args.apex_map_dir '/' args.candidates_dir '/' args.selected_dir],...
                'candidates_dir',       [args.apex_map_dir '/' args.candidates_dir '/' args.rescore_dir],...
                'metrics_dir',          [args.apex_map_dir '/' args.candidates_dir '/' args.metrics_dir],...
                'selected_features',    args.selected_features,...
                'plot_distal',          args.plot_distal,...
                'plot_nondistal',       args.plot_nondistal, ...
                'um_per_pix',           args.um_per_pix,...
                'aam_thresh',           args.aam_thresh,...
                'plot_rejected',        args.plot_rejected,...
                'plot_r',               args.plot_r,...
                'plot_c',               args.plot_c);
    end
end
%% ------------------------------------------------------------------------
%**************************************************************************
%**************************************************************************
%% ------------------------------------------------------------------------





   