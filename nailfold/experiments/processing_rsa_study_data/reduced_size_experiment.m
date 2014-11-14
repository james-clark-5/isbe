%
dir_list = {'fov_masks', 'images', 'vessel_centre_masks', 'vessel_masks', 'images_n', 'width_maps', 'orientations'};

orig_dir = 'C:\isbe\nailfold\data\rsa_study\set12g\';
new_dir = 'C:\isbe\nailfold\data\rsa_study\set12g_half\';
create_folder(new_dir);
for i_dir = 1%1:length(dir_list)
    
    create_folder([new_dir dir_list{i_dir}]);
    
    file_list = dir([orig_dir dir_list{i_dir} '\*mat']);
    
    for i_file = 1:length(file_list)
  
        s = load([orig_dir dir_list{i_dir} '\' file_list(i_file).name]);

        f = fieldnames(s);
        s.(f{1}) = imresize(s.(f{1}), 0.5);
        
        if dir_list{i_dir}(1) == 'w'
            s.(f{1}) = s.(f{1}) / 2;
        end
        if dir_list{i_dir}(1) == 'f'
            s.(f{1})([1 end],:) = 0;
            s.(f{1})(:,[1 end]) = 0;
        end
        
        eval([f{1} ' = s.(f{1});']);
        save([new_dir dir_list{i_dir} '\' file_list(i_file).name], f{1});
    end
end
%%
vc_list = dir('C:\isbe\nailfold\data\rsa_study\set12g\vessel_contours\*.mat');
mkdir C:\isbe\nailfold\data\rsa_study\set12g_half\vessel_contours\
for i_vc = 1:length(vc_list)
    load(['C:\isbe\nailfold\data\rsa_study\set12g\vessel_contours\' vc_list(i_vc).name]);
    inner_edge = inner_edge / 2;
    outer_edge = outer_edge / 2;
    vessel_centre = vessel_centre / 2;
    save(['C:\isbe\nailfold\data\rsa_study\set12g_half\vessel_contours\' vc_list(i_vc).name],...
        'apex_idx', 'inner_edge', 'outer_edge', 'vessel_centre');
end
%%
im_list = dir('C:\isbe\nailfold\data\rsa_study\test\images\*.mat');
% mkdir C:\isbe\nailfold\data\rsa_study\test_half\predictions\detection\rf_classification\257273\
% mkdir C:\isbe\nailfold\data\rsa_study\test_half\predictions\orientation\rf_regression/259076\
% mkdir C:\isbe\nailfold\data\rsa_study\test_half\predictions\width\rf_regression/257847\
% mkdir C:\isbe\nailfold\data\rsa_study\test_half\fov_masks\
mkdir C:\isbe\nailfold\data\rsa_study\test_half\apex_gt\
for i_im = 101:601
    im_name = im_list(i_im).name(1:6);
    
%     %
%     vessel_prob = u_load(...
%         ['C:\isbe\nailfold\data\rsa_study\test\predictions\detection\rf_classification\257273\' im_name '_pred.mat']);
%     vessel_prob = imresize(vessel_prob, 0.5);
%     save(['C:\isbe\nailfold\data\rsa_study\test_half\predictions\detection\rf_classification\257273\' im_name '_pred.mat'],...
%         'vessel_prob');
%     
%     %
%     vessel_ori = u_load(...
%         ['C:\isbe\nailfold\data\rsa_study\test\predictions\orientation\rf_regression/259076\' im_name '_pred.mat']);
%     vessel_ori = imresize(vessel_ori, 0.5);
%     save(['C:\isbe\nailfold\data\rsa_study\test_half\predictions\orientation\rf_regression/259076\' im_name '_pred.mat'],...
%         'vessel_ori');
%     
%     %
%     vessel_width = u_load(...
%         ['C:\isbe\nailfold\data\rsa_study\test\predictions\width\rf_regression/257847\' im_name '_pred.mat']);
%     vessel_width = imresize(vessel_width, 0.5) / 2;
%     save(['C:\isbe\nailfold\data\rsa_study\test_half\predictions\width\rf_regression/257847\' im_name '_pred.mat'],...
%         'vessel_width');
%     
    %
    fov_mask = u_load(...
        ['C:\isbe\nailfold\data\rsa_study\test\fov_masks\' im_name '_f_mask.mat']);
    fov_mask = imresize(fov_mask, 0.5) / 2;
    fov_mask = bwmorph(fov_mask, 'spur');
    save(['C:\isbe\nailfold\data\rsa_study\test_half\fov_masks\' im_name '_f_mask.mat'],...
        'fov_mask');
    
    %
    load(...
        ['C:\isbe\nailfold\data\rsa_study\test\apex_gt\' im_name '_gt.mat']);
    apex_xy = apex_xy / 2;
    save(['C:\isbe\nailfold\data\rsa_study\test_half\apex_gt\' im_name '_gt.mat'],...
        'grades',...
        'majority_grade',...
        'gradeable',...
        'apex_xy',...
        'apex_widths',...
        'num_apex_markers',...
        'is_non_distal',...
        'is_undefined',...
        'is_distal',...
        'num_im_markers',...
        'apex_shape',...
        'apex_size');
end
%%
extract_vessel_centres_set(...
    'data_dir', 'C:\isbe\nailfold\data\rsa_study\test_half\',...
    'num_jobs', 6, 'task_id', 1,...
    'prob_dir',             'rf_classification/304666/',... 29655
    'ori_dir',              'rf_regression/296621/',...
    'width_dir',            'rf_regression/297037/',...
    'fov_mask_dir',         'fov_masks/',...
    'centre_dir',           'vessel_centres/centreline_centres/',...
    'prob_sigma',           1,...
    'ori_sigma',            0,...
    'width_sigma',          1);
%%
extract_vessel_centres_set(...
    'data_dir', 'C:\isbe\nailfold\data\rsa_study\test_half\',...
    'num_jobs', 6, 'task_id', 1,...
    'prob_dir',             'rf_classification/29655/',... 29655
    'ori_dir',              'rf_regression/296621/',...
    'width_dir',            'rf_regression/297037/',...
    'fov_mask_dir',         'fov_masks/',...
    'centre_dir',           'vessel_centres/full_centres/',...
    'prob_sigma',           1,...
    'ori_sigma',            0,...
    'width_sigma',          1);
%%
extract_vessel_centres_set(...
    'data_dir', 'C:\isbe\nailfold\data\rsa_study\set12g_half\',...
    'num_jobs', 1, 'task_id', 1,...
    'prob_dir',             'rf_classification/304666/',... 296655
    'ori_dir',              'rf_regression/296621/',...
    'width_dir',            'rf_regression/297037/',...
    'fov_mask_dir',         'fov_masks/',...
    'centre_dir',           'vessel_centres/centreline_centres/',...
    'prob_sigma',           1,...
    'ori_sigma',            0,...
    'width_sigma',          1);
%%
extract_vessel_centres_set(...
    'data_dir', 'C:\isbe\nailfold\data\rsa_study\set12g_half\',...
    'num_jobs', 1, 'task_id', 1,...
    'prob_dir',             'rf_classification/296655/',... 296655
    'ori_dir',              'rf_regression/296621/',...
    'width_dir',            'rf_regression/297037/',...
    'fov_mask_dir',         'fov_masks/',...
    'centre_dir',           'vessel_centres/full_centres/',...
    'prob_sigma',           1,...
    'ori_sigma',            0,...
    'width_sigma',          1);
%%
compute_apex_offsets(... % the user's input
    'task_id',              1, ...
    'num_jobs',             1, ...
    'data_dir',             [nailfoldroot 'data/rsa_study/set12g_half/'],...
    'centre_dir',           'vessel_centres/full_centres/',...
    'contour_dir',          'vessel_contours/',...
    'mask_dir',             'vessel_masks/',...
    'apex_class_dir',       'apex_class_data/full_centres/',...
    'base_width',           20,...
    'dist_thresh',          24);
%%
compute_vessel_centre_hogs( ... % non-strict mode
    'task_id',              1, ...
    'num_jobs',             1, ...
    'data_dir',             [nailfoldroot 'data/rsa_study/set12g_half/'],...
    'feature_im_dir',       'predictions/detection/rf_classification/296655/',...
    'centre_dir',           'vessel_centres/full_centres/',...
    'hog_dir',              'vessel_hogs/296655/',...
    'max_size',             inf,...
    'smoothing_sigma',      1,...
    'num_cells',            8,...
    'cell_sz',              8,... %Size of HoG cells in blocks
    'block_sz',             [2 2],...%Size of blocks in cells
    'num_ori_bins',         9,... %Number of bins in orientation histograms
    'norm_method',          'l1-sqrt',... %Method for local normalisation
    'block_spacing',        8,... %Separation between blocks in pixels - controls level of overlap
    'gradient_operator',    [-1 0 1],...
    'spatial_sigma',        0, ...
    'angle_wrap',           1,...
    'base_width',           20, ...
    'make_parts_folders',   0);
%%
train_hog_apex_detectors(... % the user's input
    'data_path',            [],...
    'data_dir',             [nailfoldroot 'data/rsa_study/set12g_half/'],...
    'model_id',             'set12g_half_296655',...
    'model_root',           [nailfoldroot,'models/apex'], ...
    'model_name',           'rf',...
    'num_pos_samples',      2e4,...
    'neg_ratio',            1,...
    'num_trees',            100, ...
    'selected_ims',         [],...
    'labels_dir',           'apex_class_data/full_centres',...
    'hog_dir',              'vessel_hogs/296655',...
    'num_cells',            8,...
    'cell_sz',              8,... %Size of HoG cells in blocks
    'block_sz',             [2 2],...%Size of blocks in cells
    'num_ori_bins',         9,... %Number of bins in orientation histograms
    'norm_method',          'l1-sqrt',... %Method for local normalisation
    'block_spacing',        8,... %Separation between blocks in pixels - controls level of overlap
    'gradient_operator',    [-1 0 1],...
    'spatial_sigma',        0, ...
    'angle_wrap',           1,...
    'base_width',           20,...
    'dist_thresh',          24,...
    'save_data',            0);
%%
predict_apex_offsets_set(...
    'task_id',              i_tk, ...
    'num_jobs',             60, ...
    'model_id',             'set12g_half',...
    'model_root',           [nailfoldroot,'models/apex'], ...
    'model_name',           'rf',...
    'data_dir',             [nailfoldroot 'data/rsa_study/test_half'],...
    'feature_im_dir',       'predictions/detection/rf_classification/304666',...
    'centre_dir',           'vessel_centres',...
    'apex_map_dir',         'apex_maps',...
    'max_size',             1000,...
    'smoothing_sigma',      1,...
    'num_cells',            8,...
    'cell_sz',              8,... %Size of HoG cells in blocks
    'block_sz',             [2 2],...%Size of blocks in cells
    'num_ori_bins',         9,... %Number of bins in orientation histograms
    'norm_method',          'l1-sqrt',... %Method for local normalisation
    'block_spacing',        8,... %Separation between blocks in pixels - controls level of overlap
    'gradient_operator',    [-1 0 1],...
    'spatial_sigma',        0, ...
    'angle_wrap',           1,...
    'base_width',           20,...
    'apex_class_thresh',    0.5,...
    'overwrite',            1);
%%
predict_apex_offsets_set(...
    'task_id',              1, ...
    'num_jobs',             1, ...
    'model_id',             'set12g_half_296655',...
    'model_root',           [nailfoldroot,'models/apex'], ...
    'model_name',           'rf',...
    'data_dir',             [nailfoldroot 'data/rsa_study/test_half'],...
    'feature_im_dir',       'predictions/detection/rf_classification/296655',...
    'centre_dir',           'vessel_centres',...
    'apex_map_dir',         'apex_maps',...
    'max_size',             1000,...
    'smoothing_sigma',      1,...
    'num_cells',            8,...
    'cell_sz',              8,... %Size of HoG cells in blocks
    'block_sz',             [2 2],...%Size of blocks in cells
    'num_ori_bins',         9,... %Number of bins in orientation histograms
    'norm_method',          'l1-sqrt',... %Method for local normalisation
    'block_spacing',        8,... %Separation between blocks in pixels - controls level of overlap
    'gradient_operator',    [-1 0 1],...
    'spatial_sigma',        0, ...
    'angle_wrap',           1,...
    'base_width',           20,...
    'apex_class_thresh',    0.5,...
    'overwrite',            0);
%%
compute_mosiac_midline_set(...
    'C:\isbe\nailfold\data\rsa_study\test_half\fov_masks\', ...
    'C:\isbe\nailfold\data\rsa_study\test_half\image_rotations\',...
    'start_i', 101, 'end_i', [],...
    'resize_factor', 4, 'min_depth', 235, 'edge_ori_sigma', 8);

%% 1) First run through all the apex off set maps and extract the local maxima
im_list = dir('C:\isbe\nailfold\data\rsa_study\test_half\images\*.mat');

apex_map_dir = 'C:\isbe\nailfold\data\rsa_study\test_half\apex_maps\frog\old_centres\';
fov_mask_dir = 'C:\isbe\nailfold\data\rsa_study\test_half\fov_masks\';
vessel_centres_dir = 'C:\isbe\nailfold\data\rsa_study\test_half\vessel_centres\from_all_vessel_probs\';
create_folder([apex_map_dir 'local_maxima']);
create_folder('C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\half_upscaled\');

exclsuion_zone = 20;
apex_class_thresh = 0.5;
base_width = 20;

for i_im = 1:length(im_list);
    im_name = im_list(i_im).name(1:6);
    display(['Processing image ' num2str(i_im) ', ' datestr(now)]);
    
    load([apex_map_dir im_name '_pred.mat']);
    load([vessel_centres_dir im_name '_vc.mat']);
    f_mask = u_load([fov_mask_dir im_name '_f_mask.mat']);
    
    [discard_pts] = discard_edge_preds(vessel_centre, f_mask);
    include_pts = ~discard_pts & (apex_class_pred > apex_class_thresh);
    
    [apex_offset_map] = ...
        transform_apex_offset_preds(apex_class_pred, apex_offset_x_pred, apex_offset_y_pred,...
            vessel_centre, nrows, ncols, base_width, include_pts);
        
    [candidate_xy candidate_scores] = ...
        local_image_maxima(apex_offset_map, exclsuion_zone, f_mask, 0);
    
    save([apex_map_dir 'local_maxima\' im_name '_candidates'],...
        'candidate_xy', 'candidate_scores');
    
%     candidate_xy = 2*candidate_xy;
%     save(['C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\half_upscaled\' im_name '_candidates'],...
%         'candidate_xy', 'candidate_scores');
end
%%
im_list = dir('C:\isbe\nailfold\data\rsa_study\test_half\images\*.mat');

apex_map_dir = 'C:\isbe\nailfold\data\rsa_study\test_half\apex_maps\set12g_half_296655\';
fov_mask_dir = 'C:\isbe\nailfold\data\rsa_study\test_half\fov_masks\';
vessel_centres_dir = 'C:\isbe\nailfold\data\rsa_study\test_half\vessel_centres\full_centres\';
create_folder([apex_map_dir 'local_maxima']);

exclsuion_zone = 20;
apex_class_thresh = 0.5;
base_width = 20;

for i_im = 1:length(im_list);
    im_name = im_list(i_im).name(1:6);
    display(['Processing image ' num2str(i_im) ', ' datestr(now)]);
    
    load([apex_map_dir im_name '_pred.mat']);
    load([vessel_centres_dir im_name '_vc.mat']);
    f_mask = u_load([fov_mask_dir im_name '_f_mask.mat']);
    
    [discard_pts] = discard_edge_preds(vessel_centre, f_mask);
    include_pts = ~discard_pts & (apex_class_pred > apex_class_thresh);
    
    [apex_offset_map] = ...
        transform_apex_offset_preds(apex_class_pred, apex_offset_x_pred, apex_offset_y_pred,...
            vessel_centre, nrows, ncols, base_width, include_pts);
        
    [candidate_xy candidate_scores] = ...
        local_image_maxima(apex_offset_map, exclsuion_zone, f_mask, 0);
    
    save([apex_map_dir 'local_maxima\' im_name '_candidates'],...
        'candidate_xy', 'candidate_scores');
end

%% 2)
select_vessels_from_candidates_set('start_i', 1, 'end_i', 100,...
    'do_fill_gaps', 0, 'do_distal_sub', 0, 'do_save', 1, 'do_plot', 0,...
    'data_dir', 'C:\isbe\nailfold\data\rsa_study\test_half\',...
    'candidates_dir', 'apex_maps\frog\local_maxima2\',...
    'upper_ydist', -70,...
    'lower_ydist', 45);

select_vessels_from_candidates_set('start_i', 1, 'end_i', 601,...
    'do_fill_gaps', 0, 'do_distal_sub', 0, 'do_save', 1, 'do_plot', 0,...
    'data_dir', 'C:\isbe\nailfold\data\rsa_study\test_half\',...
    'candidates_dir', 'apex_maps\frog\full_centres\local_maxima\',...
    'upper_ydist', -70,...
    'lower_ydist', 45);

select_vessels_from_candidates_set('start_i', 101, 'end_i', 601,...
    'do_fill_gaps', 0, 'do_distal_sub', 0, 'do_save', 1, 'do_plot', 0,...
    'data_dir', 'C:\isbe\nailfold\data\rsa_study\test\',...
    'candidates_dir', 'apex_maps\frog\half_upscaled\');

select_vessels_from_candidates_set('start_i', 1, 'end_i', 601,...
    'do_fill_gaps', 0, 'do_distal_sub', 0, 'do_save', 1, 'do_plot', 0,...
    'data_dir', 'C:\isbe\nailfold\data\rsa_study\test_half\',...
    'candidates_dir', 'apex_maps\set12g_half\local_maxima\',...
    'upper_ydist', -70,...
    'lower_ydist', 45);

select_vessels_from_candidates_set('start_i', 1, 'end_i', 601,...
    'do_fill_gaps', 0, 'do_distal_sub', 0, 'do_save', 1, 'do_plot', 0,...
    'data_dir', 'C:\isbe\nailfold\data\rsa_study\test_half\',...
    'candidates_dir', 'apex_maps\set12g_half_296655\local_maxima\',...
    'upper_ydist', -70,...
    'lower_ydist', 45);

select_vessels_from_candidates_set('start_i', 1, 'end_i', 601,...
    'do_fill_gaps', 0, 'do_distal_sub', 0, 'do_save', 1, 'do_plot', 0,...
    'data_dir', 'C:\isbe\nailfold\data\rsa_study\test_half\',...
    'candidates_dir', 'apex_maps\set12g_half_296655c\local_maxima\',...
    'upper_ydist', -70,...
    'lower_ydist', 45);
%% 3) Start doing some analysis
mkdir([nailfoldroot 'data/rsa_study/test_half/results/']); 
make_detection_results_struc(...
    'results_name', 'rf_offset_', ...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test_half\apex_maps\frog\local_maxima2\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test_half/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test_half/results/'],...
    'prob_dir', [nailfoldroot 'data/rsa_study/test_half/predictions/detection/rf_classification/257273/'],...
    'selected_gt', 1:100,...
    'selected_candidates', []);
make_detection_results_struc(...
    'results_name', 'rf_offset_half_', ...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test_half\apex_maps\frog\old_centres\local_maxima\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test_half/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test_half/results/'],...
    'prob_dir', [nailfoldroot 'data/rsa_study/test_half/predictions/detection/rf_classification/296655/'],...
    'selected_gt', [],...
    'selected_candidates', []);
make_detection_results_struc(...
    'results_name', 'half_upscaled_', ...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\half_upscaled\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test/results/'],...
    'prob_dir', [nailfoldroot 'data/rsa_study/test/predictions/detection/rf_classification/257273/'],...
    'selected_gt', [],...
    'selected_candidates', [], ...
    'selected_prob', []);
make_detection_results_struc(...
    'results_name', 'rf_offset_set12g_half_', ...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test_half\apex_maps\set12g_half\local_maxima\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test_half/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test_half/results/'],...
    'prob_dir', [nailfoldroot 'data/rsa_study/test_half/predictions/detection/rf_classification/304666/'],...
    'selected_gt', [],...
    'selected_candidates', []);

make_detection_results_struc(...
    'results_name', 'rf_offset_set12g_half_296655_', ...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test_half\apex_maps\set12g_half_296655\local_maxima\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test_half/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test_half/results/'],...
    'prob_dir', [nailfoldroot 'data/rsa_study/test_half/predictions/detection/rf_classification/296655/'],...
    'selected_gt', 1:601,...
    'selected_candidates', 1:601,...
    'selected_prob', 1:601);

make_detection_results_struc(...
    'results_name', 'rf_offset_set12g_half_296655c_', ...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test_half\apex_maps\set12g_half_296655c\local_maxima\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test_half/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test_half/results/'],...
    'prob_dir', [nailfoldroot 'data/rsa_study/test_half/predictions/detection/rf_classification/296655/'],...
    'selected_gt', 1:601,...
    'selected_candidates', 1:601,...
    'selected_prob', 1:601);
%%
im_by_im_counts_half = analyse_detection_results(...
    'results_name', 'rf_offset_half_20140110T153933',... rf_offset_half_20131210T123607
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test_half\apex_maps\frog\full_centres\local_maxima\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test_half/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test_half/results/'],...
    'selected_images', [],...
    'use_only_gradeable', 1,...
    'min_num_markers', 2,...
    'max_missing_markers', inf,...
    'overall_summary', 1,...
    'summary_by_grade', 0,...
    'summary_by_shape', 0,...
    'summary_by_size', 0,...
    'compute_rocs', 0,...
    'analysis_by_width', 0,...
    'fixed_counting', 0,...
    'pct_counting', 0,...
    'perfect_counting', 0,...
    'final_selection', 1,...
    'intermediate_selection', 0);

im_by_im_counts_centre = analyse_detection_results(...
    'results_name', 'rf_offset_set12g_half_296655_20140113T172139',...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test_half\apex_maps\set12g_half_296655\local_maxima\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test_half/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test_half/results/'],...
    'selected_images', [],...
    'use_only_gradeable', 1,...
    'min_num_markers', 2,...
    'max_missing_markers', inf,...
    'overall_summary', 1,...
    'summary_by_grade', 1,...
    'summary_by_shape', 1,...
    'summary_by_size', 1,...
    'compute_rocs', 1,...
    'analysis_by_width', 0,...
    'fixed_counting', 0,...
    'pct_counting', 0,...
    'perfect_counting', 0,...
    'final_selection', 1,...
    'intermediate_selection', 0);


im_by_im_counts_all = analyse_detection_results(...
    'results_name', 'rf_offset_set12g_half_296655c_20140110T141343',...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test_half\apex_maps\set12g_half_296655c\local_maxima\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test_half/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test_half/results/'],...
    'selected_images', [],...
    'use_only_gradeable', 1,...
    'min_num_markers', 2,...
    'max_missing_markers', inf,...
    'overall_summary', 1,...
    'summary_by_grade', 0,...
    'summary_by_shape', 0,...
    'summary_by_size', 0,...
    'compute_rocs', 0,...
    'analysis_by_width', 0,...
    'fixed_counting', 0,...
    'pct_counting', 0,...
    'perfect_counting', 0,...
    'final_selection', 1,...
    'intermediate_selection', 1);

% im_by_im_counts_downscaled = analyse_detection_results(...
%     'results_name', 'rf_offset_20131204T154351',...
%     'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test_half\apex_maps\frog\local_maxima2\',... %mandatory arguments
%     'apex_gt_dir', [nailfoldroot 'data/rsa_study/test_half/apex_gt/'],...
%     'results_dir', [nailfoldroot 'data/rsa_study/test_half/results/'],...
%     'selected_images', [],...
%     'use_only_gradeable', 1,...
%     'min_num_markers', 2,...
%     'max_missing_markers', inf,...
%     'overall_summary', 1,...
%     'summary_by_grade', 1,...
%     'summary_by_shape', 1,...
%     'summary_by_size', 1,...
%     'compute_rocs', 1,...
%     'analysis_by_width', 0,...
%     'fixed_counting', 0,...
%     'pct_counting', 0,...
%     'perfect_counting', 0,...
%     'final_selection', 1,...
%     'intermediate_selection', 1);

% im_by_im_counts_upscaled = analyse_detection_results(...
%     'results_name', 'half_upscaled_20131210T124223',...
%     'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\half_upscaled\',... %mandatory arguments
%     'apex_gt_dir', [nailfoldroot 'data/rsa_study/test/apex_gt/'],...
%     'results_dir', [nailfoldroot 'data/rsa_study/test/results/'],...
%     'selected_images', [],...
%     'use_only_gradeable', 1,...
%     'min_num_markers', 2,...
%     'max_missing_markers', inf,...
%     'overall_summary', 1,...
%     'summary_by_grade', 1,...
%     'summary_by_shape', 1,...
%     'summary_by_size', 1,...
%     'compute_rocs', 1,...
%     'analysis_by_width', 0,...
%     'fixed_counting', 0,...
%     'pct_counting', 0,...
%     'perfect_counting', 0,...
%     'final_selection', 1,...
%     'intermediate_selection', 1);

im_by_im_counts = analyse_detection_results(...
    'results_name', 'rf_offsets_20131121T181011',...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\local_maxima2\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test/results/'],...
    'selected_images', [],...
    'use_only_gradeable', 1,...
    'min_num_markers', 2,...
    'max_missing_markers', inf,...
    'overall_summary', 1,...
    'summary_by_grade', 1,...
    'summary_by_shape', 1,...
    'summary_by_size', 1,...
    'compute_rocs', 1,...
    'analysis_by_width', 0,...
    'fixed_counting', 0,...
    'pct_counting', 0,...
    'perfect_counting', 0,...
    'final_selection', 1,...
    'intermediate_selection', 1);
            