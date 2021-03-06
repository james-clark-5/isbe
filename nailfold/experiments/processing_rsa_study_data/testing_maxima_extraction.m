load('C:\isbe\nailfold\data\rsa_study\data_lists\image_id_data.mat');
load('C:\isbe\nailfold\data\rsa_study\data_lists\miccai_lists.mat', 'miccai_selection');
im_names = image_id_data.im_names(miccai_selection.validation);
%--------------------------------------------------------------------------
%% Standard maxima
%
%--------------------------------------------------------------------------

extract_apex_map_maxima( ... % the user's input
    'image_names',          image_id_data.im_names(miccai_selection.validation),...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'fov_mask_dir',         'fov_masks',...
    'centre_dir',           'vessel_centres\full_centres',...
    'apex_map_dir',         'apex_maps\set12g_half_296655',...
    'candidates_dir',       'apex_maps\set12g_half_296655\standard_maxima',...
    'exclusion_zone',       20,...
    'transform_scores',     1,...
    'separate_trees',       0,...
    'apex_class_thresh',    0.5,...
    'discard_pts',          1,...
    'base_width',           20,...
    'use_island_max',       0,...
    'island_thresh',        0,...
    'overwrite',            1);
%
compute_apex_candidate_hogs( ... % the user's input
    'image_names',          image_id_data.im_names(miccai_selection.validation),...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'feature_im_dir',       'images',...
    'ori_dir',              'rf_regression/296621/',...
    'width_dir',            'rf_regression/297037/',...
    'candidates_dir',       'apex_maps\set12g_half_296655\standard_maxima',...
    'hog_dir',              'apex_maps\set12g_half_296655\standard_maxima\hogs\',...
    'feature_sigma',        0,...
    'prob_sigma',           2,...
    'ori_sigma',            0,...
    'width_sigma',          2,...
    'num_cells',            8,...
    'cell_sz',              8,... %Size of HoG cells in blocks
    'block_sz',             [2 2],...%Size of blocks in cells
    'num_ori_bins',         12,... %Number of bins in orientation histograms
    'norm_method',          'l1-sqrt',... %Method for local normalisation
    'block_spacing',        8,... %Separation between blocks in pixels - controls level of overlap
    'gradient_operator',    [-1 0 1],...
    'spatial_sigma',        0, ...
    'angle_wrap',           1,...
    'base_width',           20, ...
    'dist_thresh',          24^2,...
    'overwrite',            1);
%
extract_apex_candidate_class( ... % the user's input
    'image_names',          image_id_data.im_names(miccai_selection.validation),...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'prob_dir',             'rf_classification/296655/',...
    'candidates_dir',       'apex_maps\set12g_half_296655\standard_maxima',...
    'apex_gt_dir',          'apex_gt',...
    'label_dir',            'apex_maps\set12g_half_296655\standard_maxima\labels',...
    'prob_sigma',           2,...
    'overwrite',            0);
%
rf = u_load('C:\isbe\nailfold\models\apex\rescoring\ims_1_228\rf.mat');
predict_apex_candidate_rescore(...
    'image_names',          im_names(229:456),...
    'apex_class_rf',        rf,...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'candidates_dir',       'apex_maps\set12g_half_296655\standard_maxima',...
    'rescore_dir',          'apex_maps\set12g_half_296655\standard_maxima\rescores',...
    'hog_dir',              'apex_maps\set12g_half_296655\standard_maxima\hogs');

rf = u_load('C:\isbe\nailfold\models\apex\rescoring\ims_229_456\rf.mat');
predict_apex_candidate_rescore(...
    'image_names',          im_names(1:228),...
    'apex_class_rf',        rf,...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'candidates_dir',       'apex_maps\set12g_half_296655\standard_maxima',...
    'rescore_dir',          'apex_maps\set12g_half_296655\standard_maxima\rescores',...
    'hog_dir',              'apex_maps\set12g_half_296655\standard_maxima\hogs');
%
compute_apex_candidate_displacements(...
    'image_names', im_names,...
    'data_dir', [nailfoldroot 'data/rsa_study/master_set/'],...
    'vessel_centre_dir', 'vessel_centres\full_centres',...
    'displacement_dir', 'apex_maps\set12g_half_296655\standard_maxima\displacements',...
    'candidates_dir', 'apex_maps\set12g_half_296655\standard_maxima\rescores',...
    'min_candidates', 3,...
    'initial_thresh', 0.3,...
    'grid_spacing', 8,...
    'do_plot', 0);
%%
make_apex_candidate_class_probs(...
    'image_names',          image_id_data.im_names(miccai_selection.validation),...
    'model_id',             'standard_class_MAP',...
    'model_root',           [nailfoldroot,'models/apex'], ...
    'model_name',           'class_map',...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'displacement_dir',     'apex_maps\set12g_half_296655\standard_maxima\displacements',...
    'candidates_dir',       'apex_maps\set12g_half_296655\standard_maxima\rescores',...
    'label_dir',            'apex_maps\set12g_half_296655\standard_maxima\labels',...
    'plot',                 1,...
    'fig_dir',              []);
%%
load([nailfoldroot,'models/apex/final_MAP/miccai_class_MAP/class_map.mat']);
select_vessels_from_candidates( ...
    'image_names',          im_names,...
    'class_map',            class_map,...
    'selected_dir',         'apex_maps\set12g_half_296655\standard_maxima\selected_apexes',...
    'displacement_dir',     'apex_maps\set12g_half_296655\standard_maxima\displacements',...
    'rescore_dir',          'apex_maps\set12g_half_296655\standard_maxima\rescores',...
    'strong_vessel_thresh', 0.8,...
    'angle_discard_thresh', 75*pi/180,...
    'do_final_cull',        1,...
    'do_plot', 0);
%%
extract_apex_measures_set(...
    'image_names',          image_id_data.im_names(miccai_selection.validation),...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'image_dir',            'images',...
    'prob_dir',             'rf_classification/296655',...
    'ori_dir',              'rf_regression/296621',...
    'width_dir',            'rf_regression/297037',...
    'candidates_dir',       'apex_maps\set12g_half_296655\standard_maxima\rescores',...
    'displacements_dir',    'apex_maps\set12g_half_296655\standard_maxima\displacements',...
    'selected_dir',         'apex_maps\set12g_half_296655\standard_maxima\selected_apexes',...
    'metrics_dir',          'apex_maps\set12g_half_296655\standard_maxima\apex_metrics(rf)',...
    'width_predictor',      [nailfoldroot 'models/apex/width/rf.mat'],...
    'do_aam',               0,...
    'prob_sigma',           2,...
    'ori_sigma',            0,...
    'width_sigma',          2,...
    'all',                  0,...
    'plot', 0);
%%
[co_occurrence_s] = miccai_results_cooc_fun(...
    'image_names',          im_names,...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'prob_dir',             'rf_classification/296655',...
    'cluster_dir',          'apex_clusters_merged',...
    'candidates_dir',       'apex_maps\set12g_half_296655\standard_maxima\rescores',...
    'selected_dir',         'apex_maps\set12g_half_296655\standard_maxima\selected_apexes',...
    'metrics_dir',          'apex_maps\set12g_half_296655\standard_maxima\apex_metrics',...
    'do_distal',            1,...
    'do_nondistal',         1,...
    'plot', 0);
% ------------------------------------------------------------------------
%% Island maxima
%
%--------------------------------------------------------------------------

extract_apex_map_maxima( ... % the user's input
    'image_names',          image_id_data.im_names(miccai_selection.validation),...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'fov_mask_dir',         'fov_masks',...
    'centre_dir',           'vessel_centres\full_centres',...
    'apex_map_dir',         'apex_maps\set12g_half_296655',...
    'candidates_dir',       'apex_maps\set12g_half_296655\island_maxima',...
    'exclusion_zone',       20,...
    'transform_scores',     1,...
    'separate_trees',       0,...
    'apex_class_thresh',    0.5,...
    'discard_pts',          1,...
    'base_width',           20,...
    'use_island_max',       1,...
    'island_thresh',        0,...
    'overwrite',            1);
%
compute_apex_candidate_hogs( ... % the user's input
    'image_names',          image_id_data.im_names(miccai_selection.validation),...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'feature_im_dir',       'images',...
    'ori_dir',              'rf_regression/296621/',...
    'width_dir',            'rf_regression/297037/',...
    'candidates_dir',       'apex_maps\set12g_half_296655\island_maxima',...
    'hog_dir',              'apex_maps\set12g_half_296655\island_maxima\hogs\',...
    'feature_sigma',        0,...
    'prob_sigma',           2,...
    'ori_sigma',            0,...
    'width_sigma',          2,...
    'num_cells',            8,...
    'cell_sz',              8,... %Size of HoG cells in blocks
    'block_sz',             [2 2],...%Size of blocks in cells
    'num_ori_bins',         12,... %Number of bins in orientation histograms
    'norm_method',          'l1-sqrt',... %Method for local normalisation
    'block_spacing',        8,... %Separation between blocks in pixels - controls level of overlap
    'gradient_operator',    [-1 0 1],...
    'spatial_sigma',        0, ...
    'angle_wrap',           1,...
    'base_width',           20, ...
    'dist_thresh',          24^2,...
    'overwrite',            1);
%
extract_apex_candidate_class( ... % the user's input
    'image_names',          image_id_data.im_names(miccai_selection.validation),...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'prob_dir',             'rf_classification/296655/',...
    'candidates_dir',       'apex_maps\set12g_half_296655\island_maxima',...
    'apex_gt_dir',          'apex_gt',...
    'label_dir',            'apex_maps\set12g_half_296655\island_maxima\labels',...
    'prob_sigma',           2,...
    'overwrite',            0);
%
rf = u_load('C:\isbe\nailfold\models\apex\rescoring\ims_1_228\rf.mat');
predict_apex_candidate_rescore(...
    'image_names',          im_names(229:456),...
    'apex_class_rf',        rf,...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'candidates_dir',       'apex_maps\set12g_half_296655\island_maxima',...
    'rescore_dir',          'apex_maps\set12g_half_296655\island_maxima\rescores',...
    'hog_dir',              'apex_maps\set12g_half_296655\island_maxima\hogs');

rf = u_load('C:\isbe\nailfold\models\apex\rescoring\ims_229_456\rf.mat');
predict_apex_candidate_rescore(...
    'image_names',          im_names(1:228),...
    'apex_class_rf',        rf,...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'candidates_dir',       'apex_maps\set12g_half_296655\island_maxima',...
    'rescore_dir',          'apex_maps\set12g_half_296655\island_maxima\rescores',...
    'hog_dir',              'apex_maps\set12g_half_296655\island_maxima\hogs');
%
compute_apex_candidate_displacements(...
    'image_names', im_names,...
    'data_dir', [nailfoldroot 'data/rsa_study/master_set/'],...
    'vessel_centre_dir', 'vessel_centres\full_centres',...
    'displacement_dir', 'apex_maps\set12g_half_296655\island_maxima\displacements',...
    'candidates_dir', 'apex_maps\set12g_half_296655\island_maxima\rescores',...
    'min_candidates', 3,...
    'initial_thresh', 0.3,...
    'grid_spacing', 8,...
    'do_plot', 0);
%%
make_apex_candidate_class_probs(...
    'image_names',          image_id_data.im_names(miccai_selection.validation),...
    'model_id',             'island_class_MAP',...
    'model_root',           [nailfoldroot,'models/apex'], ...
    'model_name',           'class_map',...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'displacement_dir',     'apex_maps\set12g_half_296655\island_maxima\displacements',...
    'candidates_dir',       'apex_maps\set12g_half_296655\island_maxima\rescores',...
    'label_dir',            'apex_maps\set12g_half_296655\island_maxima\labels',...
    'plot',                 1,...
    'fig_dir',              []);
%%
load([nailfoldroot,'models/apex/final_MAP/miccai_class_MAP/class_map.mat']);
select_vessels_from_candidates( ...
    'image_names',          im_names,...
    'class_map',            class_map,...
    'selected_dir',         'apex_maps\set12g_half_296655\island_maxima\selected_apexes',...
    'displacement_dir',     'apex_maps\set12g_half_296655\island_maxima\displacements',...
    'rescore_dir',          'apex_maps\set12g_half_296655\island_maxima\rescores',...
    'strong_vessel_thresh', 0.8,...
    'angle_discard_thresh', 75*pi/180,...
    'do_final_cull',        1,...
    'do_plot', 0);
%
extract_apex_measures_set(...
    'image_names',          image_id_data.im_names(miccai_selection.validation),...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'image_dir',            'images',...
    'prob_dir',             'rf_classification/296655',...
    'ori_dir',              'rf_regression/296621',...
    'width_dir',            'rf_regression/297037',...
    'candidates_dir',       'apex_maps\set12g_half_296655\island_maxima\rescores',...
    'displacements_dir',    'apex_maps\set12g_half_296655\island_maxima\displacements',...
    'selected_dir',         'apex_maps\set12g_half_296655\island_maxima\selected_apexes',...
    'metrics_dir',          'apex_maps\set12g_half_296655\island_maxima\apex_metrics',...
    'width_predictor',      [],...[nailfoldroot 'models/apex/width/rf.mat'],...
    'prob_sigma',           2,...
    'ori_sigma',            0,...
    'width_sigma',          2,...
    'all',                  0,...
    'plot', 0);
%
[co_occurrence_i] = miccai_results_cooc_fun(...
    'image_names',          im_names,...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'prob_dir',             'rf_classification/296655',...
    'cluster_dir',          'apex_clusters_merged',...
    'candidates_dir',       'apex_maps\set12g_half_296655\island_maxima\rescores',...
    'selected_dir',         'apex_maps\set12g_half_296655\island_maxima\selected_apexes',...
    'metrics_dir',          'apex_maps\set12g_half_296655\island_maxima\apex_metrics',...
    'do_distal',            1,...
    'do_nondistal',         1,...
    'plot', 0);