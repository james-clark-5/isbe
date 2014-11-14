extract_apex_map_maxima( ... % the user's input
    'image_names',          {'l06V1LD4X3LrgMosaic','l06V5LD4X3LrgMosaic','l06V6LD4X3LrgMosaic'},...
    'data_dir',             [nailfoldroot 'data/2_year_study/'],...
    'fov_mask_dir',         'fov_masks',...
    'centre_dir',           'vessel_centres',...
    'apex_map_dir',         'apex_maps\set12g_half_296655',...
    'candidates_dir',       'apex_maps\set12g_half_296655\miccai_maxima',...
    'exclusion_zone',       20,...
    'transform_scores',     0,...
    'apex_class_thresh',    0.5,...
    'discard_pts',          0,...
    'base_width',           20,...
    'overwrite',            1);
%%
compute_apex_candidate_hogs( ... % the user's input
    'image_names',          {'l06V1LD4X3LrgMosaic','l06V5LD4X3LrgMosaic','l06V6LD4X3LrgMosaic'},...
    'data_dir',             [nailfoldroot 'data/2_year_study/'],...
    'feature_im_dir',       'images',...
    'ori_dir',              'rf_regression/296621/',...
    'width_dir',            'rf_regression/297037/',...
    'candidates_dir',       'apex_maps\set12g_half_296655\miccai_maxima',...
    'hog_dir',              'apex_maps\set12g_half_296655\miccai_maxima\hogs\',...
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

%%
rf = u_load('C:\isbe\nailfold\models\apex\rescoring\miccai_all\rf.mat');
predict_apex_candidate_rescore(...
    'image_names',          {'l06V1LD4X3LrgMosaic','l06V5LD4X3LrgMosaic','l06V6LD4X3LrgMosaic'},...
    'apex_class_rf',        rf,...
    'data_dir',             [nailfoldroot 'data/2_year_study/'],...
    'candidates_dir',       'apex_maps\set12g_half_296655\miccai_maxima',...
    'rescore_dir',          'apex_maps\set12g_half_296655\miccai_maxima\rescores',...
    'hog_dir',              'apex_maps\set12g_half_296655\miccai_maxima\hogs');
%%
compute_apex_candidate_displacements(...
    'image_names', {'l06V1LD4X3LrgMosaic','l06V5LD4X3LrgMosaic','l06V6LD4X3LrgMosaic'},...
    'data_dir', [nailfoldroot 'data/2_year_study/'],...
    'vessel_centre_dir', 'vessel_centres',...
    'displacement_dir', 'apex_maps\set12g_half_296655\miccai_maxima\displacements',...
    'candidates_dir', 'apex_maps\set12g_half_296655\miccai_maxima\rescores',...
    'min_candidates', 3,...
    'initial_thresh', 0.3,...
    'grid_spacing', 8,...
    'do_plot', 1);
%%
load([nailfoldroot,'models/apex/final_MAP/miccai_class_MAP/class_map.mat']);
select_vessels_from_candidates( ...
    'image_names',          {'l06V1LD4X3LrgMosaic','l06V5LD4X3LrgMosaic','l06V6LD4X3LrgMosaic'},...im_names(11:end),...
    'data_dir', [nailfoldroot 'data/2_year_study/'],...
    'class_map',            class_map,...
    'selected_dir',         'apex_maps\set12g_half_296655\miccai_maxima\selected_apexes',...
    'displacement_dir',     'apex_maps\set12g_half_296655\miccai_maxima\displacements',...
    'rescore_dir',          'apex_maps\set12g_half_296655\miccai_maxima\rescores',...
    'strong_vessel_thresh', 0.8,...
    'angle_discard_thresh', 75*pi/180,...
    'do_final_cull',        1,...
    'do_post_merge', 1,...
    'merge_dist_thresh', 60,...
    'merge_connect_thresh', 0.5,...
    'merge_n_pts', 20,...
    'do_plot', 1);
%%
extract_apex_measures_set(...
    'image_names',          {'l06V1LD4X3LrgMosaic','l06V5LD4X3LrgMosaic','l06V6LD4X3LrgMosaic'},...im_names(11:100),...
    'data_dir',             [nailfoldroot 'data/2_year_study/'],...
    'image_dir',            'images',...
    'prob_dir',             'rf_classification/296655',...
    'ori_dir',              'rf_regression/296621',...
    'width_dir',            'rf_regression/297037',...
    'candidates_dir',       'apex_maps\set12g_half_296655\miccai_maxima\rescores',...
    'displacements_dir',    'apex_maps\set12g_half_296655\miccai_maxima\displacements',...
    'selected_dir',         'apex_maps\set12g_half_296655\miccai_maxima\selected_apexes',...
    'metrics_dir',          'apex_maps\set12g_half_296655\miccai_maxima\apex_metrics',...
    'aam_dir',              'aam',...
    'do_aam',               1,...
    'model_dir',            [nailfoldroot 'data/rsa_study/models/apex_templates/'],...
    'aam_name',             'aam/orig/2/vessel_apex_orig.smd',...
    'width_predictor',      [],...[nailfoldroot 'models/apex/width/rf.mat'],...
    'prob_sigma',           2,...
    'ori_sigma',            0,...
    'width_sigma',          2,...
    'do_distal',            1,...
    'do_nondistal',         1,...
    'plot', 0);
%%
display_automated_markup(... % non-strict mode
    'image_names',         im_names(21:30),... {'l06V1LD4X3LrgMosaic','l06V5LD4X3LrgMosaic','l06V6LD4X3LrgMosaic'},...
    'data_dir',             [nailfoldroot 'data/2_year_study/'],...
    'image_dir',            'images',...
    'vessel_centre_dir',    'vessel_centres',...
    'metrics_dir',          'apex_maps\set12g_half_296655\miccai_maxima\apex_metrics',...
    'selected_features', [],...
    'do_xls',           1,...
    'do_make_stats',    0,...
    'do_image_plots',   0, ...
    'do_people_plots',  0,...
    'fig_dir',          [],...
    'um_per_pix',       1.25,...
    'xls_filename',     'auto_stats.xls',...
    'aam_thresh',       -2e4);
%%
predicted_class = ...
    interp2(class_map.x, class_map.y, class_map.post_class,...
            all_candidate_rescores, all_candidate_disp, 'linear', 0) + 1;
%%
figure; 
hist(all_candidate_width, 1:60); 
title('Widths of all candidates');
%
labels = {'X', 'Distal', 'Non-distal'};
figure;
plot_n = 1;
for gt_c = 1:3
    for pred_c = 1:3
        idx = (all_candidate_labels==gt_c) & (predicted_class==pred_c);
        subplot(3,3,plot_n);  hist(all_candidate_width(idx), 1:60);
        title(['True class: ' labels{gt_c} ', predicted class: ' labels{pred_c}]);
        xlabel('Candidate width');
        plot_n = plot_n + 1;
    end
end
%%
%--------------------------------------------------------------------------
%%
load('C:\isbe\nailfold\data\rsa_study\data_lists\image_id_data.mat');
load('C:\isbe\nailfold\data\rsa_study\data_lists\miccai_lists.mat', 'miccai_selection');
%%
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
%%
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
%%
extract_apex_candidate_class( ... % the user's input
    'image_names',          image_id_data.im_names(miccai_selection.validation),...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'prob_dir',             'rf_classification/296655/',...
    'candidates_dir',       'apex_maps\set12g_half_296655\island_maxima',...
    'apex_gt_dir',          'apex_gt',...
    'label_dir',            'apex_maps\set12g_half_296655\island_maxima\labels',...
    'prob_sigma',           2,...
    'overwrite',            0);
%%
im_names = image_id_data.im_names(miccai_selection.validation);
train_hog_apex_rescorer(... % the user's input
    'image_names',          im_names(1:228),...
    'data_path',            [],...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'model_id',             'ims_1_228',...
    'model_root',           [unixenv('DATA_ROOT',[]) unixenv('MODEL_ROOT',[nailfoldroot,'models/apex'])], ...
    'model_name',           'rf',...
    'num_trees',            unixenv('NUM_TREES',100), ...
    'labels_dir',           'apex_maps\set12g_half_296655\island_maxima\labels',...
    'hog_dir',              'apex_maps\set12g_half_296655\island_maxima\hogs',...
    'save_data',            0);
%%
train_hog_apex_rescorer(... % the user's input
    'image_names',          im_names(229:456),...
    'data_path',            [],...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'model_id',             'ims_229_456',...
    'model_root',           [unixenv('DATA_ROOT',[]) unixenv('MODEL_ROOT',[nailfoldroot,'models/apex'])], ...
    'model_name',           'rf',...
    'num_trees',            unixenv('NUM_TREES',100), ...
    'labels_dir',           'apex_maps\set12g_half_296655\island_maxima\labels',...
    'hog_dir',              'apex_maps\set12g_half_296655\island_maxima\hogs',...
    'save_data',            0);
%%
train_hog_apex_rescorer(... % the user's input
    'image_names',          im_names,...
    'data_path',            [],...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'model_id',             'miccai_all',...
    'model_root',           [unixenv('DATA_ROOT',[]) unixenv('MODEL_ROOT',[nailfoldroot,'models/apex'])], ...
    'model_name',           'rf',...
    'num_trees',            unixenv('NUM_TREES',100), ...
    'labels_dir',           'apex_maps\set12g_half_296655\island_maxima\labels',...
    'hog_dir',              'apex_maps\set12g_half_296655\island_maxima\hogs',...
    'save_data',            0);
%%
im_names = image_id_data.im_names(miccai_selection.validation);
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
%%
compute_apex_candidate_displacements(...
    'image_names', im_names(2),...
    'data_dir', [nailfoldroot 'data/rsa_study/master_set/'],...
    'vessel_centre_dir', 'vessel_centres\full_centres',...
    'displacement_dir', 'apex_maps\set12g_half_296655\island_maxima\displacements(test)',...
    'candidates_dir', 'apex_maps\set12g_half_296655\island_maxima\rescores',...
    'min_candidates', 3,...
    'initial_thresh', 0.3,...
    'grid_spacing', 8,...
    'use_snake', 1,...
    'do_plot', 1);
%%
make_apex_candidate_class_probs(...
    'image_names',          image_id_data.im_names(miccai_selection.validation),...
    'model_id',             'miccai_class_MAP',...
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
    'image_names',          im_names(1:20),...
    'class_map',            class_map,...
    'selected_dir',         'apex_maps\set12g_half_296655\island_maxima\selected_apexes',...
    'displacement_dir',     'apex_maps\set12g_half_296655\island_maxima\displacements',...
    'rescore_dir',          'apex_maps\set12g_half_296655\island_maxima\rescores',...
    'strong_vessel_thresh', 0.8,...
    'angle_discard_thresh', 75*pi/180,...
    'do_final_cull',        1,...
    'do_plot', 1);
%%
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
%%
display_automated_markup(... % non-strict mode
    'image_names',         {'10598c'},...im_names(1:20),... {'l06V1LD4X3LrgMosaic','l06V5LD4X3LrgMosaic','l06V6LD4X3LrgMosaic'},...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'image_dir',            'images',...
    'vessel_centre_dir',    'vessel_centres',...
    'metrics_dir',          'apex_maps\set12g_half_296655\island_maxima\apex_metrics',...
    'selected_features', [],...
    'do_xls',           1,...
    'do_make_stats',    0,...
    'do_image_plots',   0, ...
    'do_people_plots',  0,...
    'fig_dir',          [],...
    'um_per_pix',       1.25,...
    'xls_filename',     'auto_stats.xls',...
    'aam_thresh',       -2e4);
%%
[co_occurrence a_b_widths a_c_widths b_c_widths] = miccai_results_cooc_fun(...
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
%%
[co_occurrence_m] = miccai_results_cooc_fun(...
    'image_names',          im_names,...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'prob_dir',             'rf_classification/296655',...
    'cluster_dir',          'apex_clusters_merged',...
    'candidates_dir',       'apex_maps\set12g_half_296655\miccai_maxima\rescores',...
    'selected_dir',         'apex_maps\set12g_half_296655\miccai_maxima\selected_apexes',...
    'metrics_dir',          'apex_maps\set12g_half_296655\miccai_maxima\apex_metrics',...
    'do_distal',            1,...
    'do_nondistal',         1,...
    'plot', 0);
%%
%--------------------------------------------------------------------------
extract_apex_map_maxima( ... % the user's input
    'image_names',          {'10598c'},...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'fov_mask_dir',         'fov_masks',...
    'centre_dir',           'vessel_centres\full_centres',...
    'apex_map_dir',         'apex_maps\set12g_half_296655',...
    'candidates_dir',       'apex_maps\set12g_half_296655\bob0',...
    'separate_trees',       0,...
    'exclusion_zone',       20,...
    'transform_scores',     1,...
    'apex_class_thresh',    0.5,...
    'discard_pts',          1,...
    'base_width',           20,...
    'overwrite',            1);
extract_apex_map_maxima( ... % the user's input
    'image_names',          {'10598c'},...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'fov_mask_dir',         'fov_masks',...
    'centre_dir',           'vessel_centres\full_centres',...
    'apex_map_dir',         'apex_maps\set12g_half_296655',...
    'candidates_dir',       'apex_maps\set12g_half_296655\bob1',...
    'separate_trees',       1,...
    'exclusion_zone',       20,...
    'transform_scores',     1,...
    'apex_class_thresh',    0.5,...
    'discard_pts',          1,...
    'base_width',           20,...
    'overwrite',            1);
%%
analyse_apex_candidate_displacements(...
    'image_names', im_names(101:120),...
    'data_dir', [nailfoldroot 'data/rsa_study/master_set/'],...
    'vessel_centre_dir', 'vessel_centres\full_centres',...
    'label_dir', 'apex_maps\set12g_half_296655\island_maxima\labels',...
    'candidates_dir', 'apex_maps\set12g_half_296655\island_maxima\rescores',...
    'min_candidates', 3,...
    'initial_thresh', 0.5,...
    'grid_spacing', 8,...
    'use_snake', 1,...
    'do_plot', 1);
%%
compute_apex_candidate_displacements(...
    'image_names', im_names(1:10),...
    'data_dir', [nailfoldroot 'data/rsa_study/master_set/'],...
    'vessel_centre_dir', 'vessel_centres\full_centres',...
    'displacement_dir', 'apex_maps\set12g_half_296655\island_maxima\displacements(test)',...
    'candidates_dir', 'apex_maps\set12g_half_296655\island_maxima\rescores',...
    'min_candidates', 3,...
    'initial_thresh', 0.3,...
    'grid_spacing', 8,...
    'use_snake', 1,...
    'alpha', 1,...
    'beta', 1,...
    'snake_delta_y', 30,...
    'snake_res_y', 1,...
    'snake_spacing', 50,...
    'do_plot', 1);