load('C:\isbe\nailfold\data\rsa_study\data_lists\image_id_data.mat');
load('C:\isbe\nailfold\data\rsa_study\data_lists\miccai_lists.mat', 'miccai_selection');
%%
make_apex_candidate_ims( ... % the user's input
    'image_names',          image_id_data.im_names(miccai_selection.validation | miccai_selection.test),...
    'data_dir',             'G:/isbe/nailfold/data/rsa_study/master_set/',...
    'feature_im_dir',       'images',...
    'ori_dir',              'rf_regression/296621/',...
    'width_dir',            'rf_regression/297037/',...
    'candidates_dir',       'apex_maps\set12g_half_296655\miccai_maxima',...
    'output_format',        'graysc',...
    'patch_lims',           [-63.5 63.5 -31.5 95.5],...
    'feature_sigma',        0,...
    'ori_sigma',            0,...
    'width_sigma',          2,...
    'base_width',           20, ...
    'dist_thresh',          24^2,...
    'overwrite',            0);
%%
make_apex_candidate_ims( ... % the user's input
    'image_names',          image_id_data.im_names(miccai_selection.validation | miccai_selection.test),...
    'data_dir',             'G:/isbe/nailfold/data/rsa_study/master_set/',...
    'feature_im_dir',       'predictions/detection/rf_classification/296655',...
    'ori_dir',              'rf_regression/296621/',...
    'width_dir',            'rf_regression/297037/',...
    'candidates_dir',       'apex_maps\set12g_half_296655\miccai_maxima',...
    'output_im_dir',        'apex_images_det',...
    'output_format',        'gray',...
    'patch_lims',           [-63.5 63.5 -31.5 95.5],...
    'feature_sigma',        0,...
    'ori_sigma',            0,...
    'width_sigma',          2,...
    'base_width',           20, ...
    'dist_thresh',          24^2,...
    'overwrite',            0);
%
make_apex_candidate_ims( ... % the user's input
    'image_names',          image_id_data.im_names(miccai_selection.validation | miccai_selection.test),...
    'data_dir',             'G:/isbe/nailfold/data/rsa_study/master_set/',...
    'feature_im_dir',       'predictions/orientation/rf_regression/296621',...
    'ori_dir',              'rf_regression/296621/',...
    'width_dir',            'rf_regression/297037/',...
    'candidates_dir',       'apex_maps\set12g_half_296655\miccai_maxima',...
    'output_im_dir',        'apex_images_ori',...
    'output_format',        'complex',...
    'patch_lims',           [-63.5 63.5 -31.5 95.5],...
    'feature_sigma',        0,...
    'ori_sigma',            0,...
    'width_sigma',          2,...
    'base_width',           20, ...
    'dist_thresh',          24^2,...
    'overwrite',            0);
%%
make_apex_candidate_im_list(...
    image_id_data.im_names(miccai_selection.validation), ...
    'C:\isbe\nailfold\data\rsa_study\master_set\apex_maps\set12g_half_296655\miccai_maxima\labels\',...
    'C:\isbe\nailfold\data\rsa_study\data_lists\apex_patch_list_val.txt')
%
make_apex_candidate_im_list(...
    image_id_data.im_names(miccai_selection.test), ...
    'C:\isbe\nailfold\data\rsa_study\master_set\apex_maps\set12g_half_296655\miccai_maxima\labels\',...
    'C:\isbe\nailfold\data\rsa_study\data_lists\apex_patch_list_test.txt')
%%
study_dir = 'C:\isbe\nailfold\data\fellowship\';
im_dir = [study_dir 'images\'];
im_list = dir([im_dir '*.bmp']);
fid = fopen('C:\isbe\nailfold\data\fellowship\image_list.txt', 'wt');

num_ims = length(im_list);
im_names = cell(num_ims,1);

for i_im = 1:num_ims
    old_name = im_list(i_im).name;
    space_idx = old_name == ' ';
    if any(space_idx)
        new_name = old_name;
        new_name(space_idx) = '_';
        movefile([im_dir old_name], [im_dir new_name]);
        old_name = new_name;
    end
    im_names{i_im} = old_name(1:end-4);
    fprintf(fid, '%s\n', im_names{i_im});
end
fclose(fid);
%%
%%
study_dir = 'C:\isbe\nailfold\data\fellowship\';
im_dir = [study_dir 'images\'];
im_list = dir([im_dir '*.jpg']);
fid = fopen('C:\isbe\nailfold\data\fellowship\image_list_jpg.txt', 'wt');

num_ims = length(im_list);
im_names = cell(num_ims,1);

for i_im = 1:num_ims
    old_name = im_list(i_im).name;
    space_idx = old_name == ' ';
    if any(space_idx)
        new_name = old_name;
        new_name(space_idx) = '_';
        movefile([im_dir old_name], [im_dir new_name]);
        old_name = new_name;
    end
    im_names{i_im} = old_name(1:end-4);
    fprintf(fid, '%s\n', im_names{i_im});
end
fclose(fid);
%%
create_folder([study_dir 'apex_metrics']);
im_list = [dir([im_dir '*.bmp']); dir([im_dir '*.jpg'])];

num_ims = length(im_list);
im_names = cell(num_ims,1);

for i_im = 1:num_ims
    im_names{i_im} = im_list(i_im).name(1:end-4);
    [apex_measures, apex_data] = ...
        make_apex_measures_from_cxx(study_dir, im_names{i_im});
    save([study_dir 'apex_metrics\' im_names{i_im} '_am.mat'],...
        'apex_measures');
end
%%
study_dir = 'C:\isbe\nailfold\data\fellowship\';

fig_dir = [study_dir 'figures\'];
results_dir = [study_dir 'results\'];
create_folder(fig_dir);
create_folder(results_dir);

xls_filename = [results_dir 'all_image_auto_measures(1).xls'];

auto_stats = analyse_qseries_apex_measures([],...auto_stats,...
    'image_names',          im_names,...
    'data_dir',             [nailfoldroot 'data/fellowship/'],...
    'metrics_dir',          'apex_metrics',...
    'do_auto_stats',    1,...
    'do_xls',           1,...
    'do_image_plots',   0, ...
    'selected_features', [],... %Do them all for now
    'do_people_plots',  0,...
    'fig_dir', fig_dir,...
    'xls_filename', xls_filename);
%%
xls_filename = [results_dir 'image_auto_measures(1).xls'];
selected_features = {...
    'num_distal_vessels',...
    'num_giant_vessels',...
    'num_enlarged_vessels',...
    'vessel_density',...%'mean_mean_width',...
    'mean_mean_width',...%adjusted_width
    'max_mean_width',...
    'mean_connected_orientation_dispersion',...
    'dispersion_connected_orientation'};%,...

analyse_qseries_apex_measures(auto_stats,...
    'image_names',          im_names,...
    'data_dir',             [nailfoldroot 'data/fellowship/'],...
    'metrics_dir',          'apex_metrics',...
    'do_auto_stats',    0,...
    'do_xls',           1,...
    'do_image_plots',   0, ...
    'selected_features', selected_features,... %Do them all for now
    'do_people_plots',  0,...
    'fig_dir', fig_dir,...
    'xls_filename', xls_filename);
