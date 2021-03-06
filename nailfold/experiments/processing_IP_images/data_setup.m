%Sorting out data for the 2 year study

%Notes:
% Base directory on MB's local machine is C:\isbe\nailfold\data\fellowship_IP
% Original data stored on the network drive at "N:\musculoskeletal\NCM only studies\2 yr data incl marina mark up".  
% Images (originally in .bmp) from dir "anonymous_bmap_files1" and its sub-dir "Additional mosaics 28-03-2014" 
% converted to .png/.mat format and stored in "anonymous_png"/"images" respectively. 
% .mat images are downsized by a factor of 2

%% ------------------------------------------------------------------------
% 1) Convert and copy images from network directory, make a mosaic mask
local_root = 'C:\isbe\nailfold\data\fellowship_IP\';

bmp_dir = 'images_bmp\';
png_dir = 'images_png\';
mat_dir = 'images\';
mask_dir = 'fov_masks\';

create_folder([local_root png_dir]);
create_folder([local_root mat_dir]);
create_folder([local_root mask_dir]);

%%
do_plot = 1;

im_list = dir([local_root bmp_dir '*.bmp']);

for i_im = 1:length(im_list)

    im_name = im_list(i_im).name(1:end-4);

    %Load in image
    nailfold = imread([local_root bmp_dir im_name '.bmp']);

    %Select single channel if in RGB format (R=G=B for grayscale bmps)
    if size(nailfold, 3) == 3
        nailfold = nailfold(:,:,1);
    end

    %Write as png
    imwrite(nailfold, [local_root png_dir im_name '.png']);

    %Downsize and write as mat
    nailfold = imresize(nailfold, 0.5);
    save([local_root mat_dir im_name '.mat'], 'nailfold');

    %Make mosaic field-of-view mask
    fov_mask = make_nailfold_mosaic_mask(nailfold, 250, 5);
    save([local_root mask_dir im_name '_f_mask.mat'], 'fov_mask');

    %Show some images to check all is as expected
    if do_plot && i_im <= 5
        figure;
        subplot(2,1,1); imgray(nailfold);
        subplot(2,1,2); imgray(fov_mask);
    end
end
%%
%--------------------------------------------------------------------------
extract_vessel_centres_set(...
    'data_dir', [nailfoldroot 'data\fellowship_IP\'],...
    'num_jobs', 1, 'task_id', 1,...
    'prob_dir',             'rf_classification/296655/',... 296655
    'ori_dir',              'rf_regression/296621/',...
    'width_dir',            'rf_regression/297037/',...
    'fov_mask_dir',         'fov_masks/',...
    'centre_dir',           'vessel_centres/',...
    'prob_sigma',           1,...
    'ori_sigma',            0,...
    'width_sigma',          1,...
    'overwrite',            0);
%Copy data to the CSF, run apex offset predictor on CSF to compute apex
%offset maps

% DATA_ROOT="scratch/nailfold/" MODEL_ROOT="models/apex" MODEL_PATH="set12g_half_296655" NUM_JOBS=577 IMAGE_ROOT="data/fellowship_IP" IMAGE_DIR="predictions/detection/rf_classification/296655" MASK_DIR="fov_masks" OVERWRITE=0 THRESH=0.5 MODEL_NAME="rf" MAX_SIZE=1000 qsub -V -t 1 -l twoday matlab_code/trunk/hydra/cuc/predict_apex_offsets_set.sh
%%
%% ------------------------------------------------------------------------
%**************************************************************************
%**************************************************************************
%% ------------------------------------------------------------------------
im_names_s = dir([nailfoldroot 'data/fellowship_IP/images/*.mat']);
num_ims = length(im_names_s);
im_names = cell(num_ims,1);
for i_im = 1:num_ims
    im_names{i_im} = im_names_s(i_im).name(1:end-4);
end

extract_apex_map_maxima( ... % the user's input
    'image_names',          im_names,...
    'data_dir',             [nailfoldroot 'data/fellowship_IP/'],...
    'fov_mask_dir',         'fov_masks',...
    'centre_dir',           'vessel_centres',...
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
    'image_names',          im_names,...
    'data_dir',             [nailfoldroot 'data/fellowship_IP/'],...
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
rf = u_load('C:\isbe\nailfold\models\apex\rescoring\miccai_all\rf.mat');
predict_apex_candidate_rescore(...
    'image_names',          im_names,...
    'apex_class_rf',        rf,...
    'data_dir',             [nailfoldroot 'data/fellowship_IP/'],...
    'candidates_dir',       'apex_maps\set12g_half_296655\island_maxima',...
    'rescore_dir',          'apex_maps\set12g_half_296655\island_maxima\rescores',...
    'hog_dir',              'apex_maps\set12g_half_296655\island_maxima\hogs');
%
compute_apex_candidate_displacements(...
    'image_names', im_names,...
    'data_dir', [nailfoldroot 'data/fellowship_IP/'],...
    'vessel_centre_dir', 'vessel_centres',...
    'displacement_dir', 'apex_maps\set12g_half_296655\island_maxima\displacements',...
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
    'do_plot', 0);
%
load([nailfoldroot,'models/apex/final_MAP/test_class_MAP/class_map.mat']);

%
select_vessels_from_candidates( ...
    'image_names',          im_names,...
    'data_dir', [nailfoldroot 'data/fellowship_IP/'],...
    'class_map',            class_map,...
    'selected_dir',         'apex_maps\set12g_half_296655\island_maxima\selected_apexes',...
    'displacement_dir',     'apex_maps\set12g_half_296655\island_maxima\displacements',...
    'rescore_dir',          'apex_maps\set12g_half_296655\island_maxima\rescores',...
    'strong_vessel_thresh', 0.8,...
    'angle_discard_thresh', 75*pi/180,...
    'do_final_cull',        1,...
    'do_post_merge', 1,...
    'merge_dist_thresh', 60,...
    'merge_connect_thresh', 0.5,...
    'merge_n_pts', 20);
%%
extract_apex_measures_set(...
    'image_names',          im_names,...
    'data_dir',             [nailfoldroot 'data/fellowship_IP/'],...
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
    'do_aam',               1,...
    'overwrite',            0,...
    'plot', 0);

%%
study_dir = 'C:\isbe\nailfold\data\fellowship_IP\';

fig_dir = [study_dir 'figures\'];
results_dir = [study_dir 'results\'];
create_folder(fig_dir);
create_folder(results_dir);

xls_filename = [results_dir 'all_image_auto_measures(1).xls'];

auto_stats = analyse_qseries_apex_measures([],...auto_stats,...
    'image_names',          im_names,...
    'data_dir',             [nailfoldroot 'data/fellowship_IP/'],...
    'vessel_centre_dir',    'vessel_centres\',...
    'selected_dir',         'apex_maps\set12g_half_296655\island_maxima\selected_apexes',...
    'metrics_dir',          'apex_maps\set12g_half_296655\island_maxima\apex_metrics',...
    'do_xls',           1,...
    'do_make_stats',    1,...
    'do_image_plots',   0, ...
    'selected_features', [],... %Do them all for now
    'do_people_plots',  0,...
    'fig_dir', fig_dir,...
    'xls_filename', xls_filename);

   