% Load data load �mnist_train.mat�
load C:\isbe\misc\mnist\mnist_train.mat
ind = randperm(size(train_X, 1));
train_X = train_X(ind(1:5000),:);

train_labels = train_labels(ind(1:5000));
clear ind; pack;
%%
% Set parameters 
no_dims = 2;
initial_dims = 50;
perplexity = 30;

%Run t-sne
mappedX = tsne(train_X, [], no_dims, initial_dims, perplexity);

gscatter(mappedX(:,1), mappedX(:,2), train_labels);
%%
load('C:\isbe\nailfold\data\rsa_study\data_lists\image_id_data.mat');
load('C:\isbe\nailfold\data\rsa_study\data_lists\miccai_lists.mat', 'miccai_selection');
im_names = image_id_data.im_names(miccai_selection.validation);
train_hog_apex_rescorer(... % the user's input
    'image_names',          im_names,...
    'data_path',            [],...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'model_id',             'tsne',...
    'model_root',           [unixenv('DATA_ROOT',[]) unixenv('MODEL_ROOT',[nailfoldroot,'models/apex'])], ...
    'model_name',           'rf',...
    'num_trees',            unixenv('NUM_TREES',100), ...
    'labels_dir',           'apex_maps\set12g_half_296655\miccai_maxima\labels',...
    'hog_dir',              'apex_maps\set12g_half_296655\miccai_maxima\hogs_corrected',...
    'save_data',            1);
%%
load C:\isbe\nailfold\models\apex\training_data\tsne\data.mat;
%ind = randperm(size(train_X, 1));
%train_X = train_X(ind(1:5000),:);

%train_c = train_c(ind(1:5000));
%clear ind; pack;
%%
%Run t-sne
no_dims = 3;
initial_dims = 50;
perplexity = 30;
theta = 0.5;
mappedX = fast_tsne(train_X, no_dims, initial_dims, perplexity, theta);

figure; hold all;
plot3(mappedX(train_c,1), mappedX(train_c,2), mappedX(train_c,3), 'r.');
plot3(mappedX(~train_c,1), mappedX(~train_c,2), mappedX(~train_c,3), 'b.');
%%
mappedX2 = fast_tsne(train_X, 2, initial_dims, perplexity, theta);
save('C:\isbe\nailfold\models\apex\training_data\tsne\tsne_2d.mat', 'mappedX2');
figure; hold all;
plot(mappedX2(~train_c,1), mappedX2(~train_c,2), 'b.');
plot(mappedX2(train_c,1), mappedX2(train_c,2), 'r.');
%%
% Load data load �mnist_train.mat�
load C:\isbe\misc\mnist\mnist_train.mat
no_dims = 2;
initial_dims = 50;
perplexity = 30;

%Run t-sne
mappedX = fast_tsne(train_X, no_dims, initial_dims, perplexity);

gscatter(mappedX(:,1), mappedX(:,2), train_labels);
%%
mappedX2a = mappedX2;
mappedX2a(:,1) = mappedX2a(:,1) - min(mappedX2a(:,1));
mappedX2a(:,2) = mappedX2a(:,2) - min(mappedX2a(:,2));
figure; imgray(blank_im);
plot(mappedX2a(train_c,1), mappedX2a(train_c,2), 'r.');
plot(mappedX2a(~train_c,1), mappedX2a(~train_c,2), 'b.');
help roipoly
mappedX2_idx = sub2ind(size(blank_im), ceil(mappedX2a(:,2)+.01), ceil(mappedX2a(:,1)+.01));
%%
selected_cans_idx = selected_cans(mappedX2_idx);
%%
selected_train_idx = train_idx(selected_cans_idx,:);
selected_labels = train_c(selected_cans_idx,:);
for i_im = 1:20
    %im_idx = selected_train_idx(:,1)==i_im;
    %p_idx = selected_train_idx(im_idx & selected_labels,2);
    %n_idx = selected_train_idx(im_idx & ~selected_labels,2);   
    
    im_idx = train_idx(:,1)==i_im;
    p_idx = train_idx(im_idx & train_c,2);
    n_idx = train_idx(im_idx & ~train_c,2);   

    if ~isempty(n_idx)
        
        im = load(['C:\isbe\nailfold\data\rsa_study\master_set\images\' im_names{i_im} '.mat']);
        cans = load(['C:\isbe\nailfold\data\rsa_study\master_set\apex_maps\set12g_half_296655\miccai_maxima\'...
            im_names{i_im} '_candidates.mat']);
        
        figure; imgray(im.nailfold);
        plot(cans.candidate_xy(p_idx,1), cans.candidate_xy(p_idx,2), 'gx');
        plot(cans.candidate_xy(n_idx,1), cans.candidate_xy(n_idx,2), 'rx');
    end
end
%%
controls_xls = xlsread('C:\isbe\density\assure\conTROLS_SPREADSHEET_PROCASALL_Tex3.xls');
cancers_xls = xlsread('C:\isbe\density\assure\canCERS_SPREADSHEET_PROCASALL_With_Flag_Tex3.xls');

nn = size(controls_xls,1) - 1;
np = size(cancers_xls,1) - 1;
n = nn+np;
train_c = true(n,1);
train_c(1:nn) = 0;

cols_con = [3 5 6 7 8 9 16 17];
cols_can = [3 5 6 7 8 9 17 18];

train_X = [cell2mat(controls_xls(2:end, cols_con)); cell2mat(cancers_xls(2:end, cols_can))];
train_X = bsxfun(@rdivide, train_X, max(train_X));
%%
no_dims = 2;
initial_dims = 8;
perplexity = 30;
theta = 0.5;

%Run t-sne
mappedX = fast_tsne(train_X, no_dims, initial_dims, perplexity, theta);
figure; hold all;
plot(mappedX(train_c,1), mappedX(train_c,2), 'r.');
plot(mappedX(~train_c,1), mappedX(~train_c,2), 'b.');
%%
% im_list = dir('C:\isbe\nailfold\data\rsa_study\master_set\images_png\*.png');
% im_names = cell(100,1);
% for i_im = 1:100; 
%     im_names{i_im} = im_list(i_im).name(1:6); 
% end

load('C:\isbe\nailfold\data\rsa_study\data_lists\miccai_lists.mat', 'miccai_selection');
load('C:\isbe\nailfold\data\rsa_study\data_lists\image_id_data.mat');
im_names = sort(image_id_data.im_names(miccai_selection.validation));
%%
[co_occurrence_mat] = miccai_results_cooc_fun(...
    'image_names',          im_names,...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'prob_dir',             'rf_classification/296655',...
    'cluster_dir',          'apex_clusters_merged',...
    'candidates_dir',       'apex_maps\set12g_half_296655\miccai_maxima\rescores',...
    'selected_dir',         'apex_maps\set12g_half_296655\miccai_maxima\selected_apexes',...
    'metrics_dir',          [],...'apex_maps\set12g_half_296655\miccai_maxima\apex_metrics',...
    'do_distal',            1,...
    'do_nondistal',         1,...
    'plot', 0);
%%
[co_occurrence_cxx] = cxx_results_cooc_fun(...
    'image_names',          im_names,...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'prob_dir',             'rf_classification/296655',...
    'cluster_dir',          'apex_clusters_merged',...
    'candidates_dir',       'vessel_hogs',...
    'metrics_dir',          [],...
    'do_distal',            1,...
    'do_nondistal',         1,...
    'plot', 0);
%%
load([nailfoldroot,'models/apex/final_MAP/miccai_class_MAP_corrected/class_map.mat']);
select_vessels_from_candidates( ...
    'image_names',          image_id_data.im_names(miccai_selection.validation),...
    'class_map',            class_map,...
    'selected_dir',         'apex_maps\set12g_half_296655\miccai_maxima\selected_apexes_corrected',...
    'displacement_dir',     'apex_maps\set12g_half_296655\miccai_maxima\displacements_corrected',...
    'rescore_dir',          'apex_maps\set12g_half_296655\miccai_maxima\rescores_corrected',...
    'strong_vessel_thresh', 0.8,...
    'angle_discard_thresh', 75*pi/180,...
    'do_final_cull',        1);
%
extract_apex_measures_set(...
    'image_names',          image_id_data.im_names(miccai_selection.validation),...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'image_dir',            'images',...
    'prob_dir',             'rf_classification/296655',...
    'ori_dir',              'rf_regression/296621',...
    'width_dir',            'rf_regression/297037',...
    'candidates_dir',       'apex_maps\set12g_half_296655\miccai_maxima\rescores_corrected',...
    'displacements_dir',    'apex_maps\set12g_half_296655\miccai_maxima\displacements_corrected',...
    'selected_dir',         'apex_maps\set12g_half_296655\miccai_maxima\selected_apexes_corrected',...
    'metrics_dir',          'apex_maps\set12g_half_296655\miccai_maxima\apex_metrics_corrected',...
    'width_predictor',      [],...[nailfoldroot 'models/apex/width/rf.mat'],...
    'prob_sigma',           2,...
    'ori_sigma',            0,...
    'width_sigma',          2,...
    'all',                  0,...
    'plot', 0);
%%
[co_occurrence_matc] = miccai_results_cooc_fun(...
    'image_names',          im_names,...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'prob_dir',             'rf_classification/296655',...
    'cluster_dir',          'apex_clusters_merged',...
    'candidates_dir',       'apex_maps\set12g_half_296655\miccai_maxima\rescores_corrected',...
    'selected_dir',         'apex_maps\set12g_half_296655\miccai_maxima\selected_apexes_corrected',...
    'metrics_dir',          [],...'apex_maps\set12g_half_296655\miccai_maxima\apex_metrics',...
    'do_distal',            1,...
    'do_nondistal',         1,...
    'plot', 0);
%%
v_dir = 'C:\isbe\nailfold\data\rsa_study\master_set\vessel_hogs\';
for i_im = 1:length(im_names); 
    if ~exist([v_dir im_names{i_im} '_apex_candidates.txt'], 'file')
        display(['image_filenames_.push_back("' im_names{i_im} '");']); 
    end
end
%%
im_name = '10598c';
base_dir = 'C:\isbe\nailfold\data\rsa_study\master_set\';
vh = load([base_dir 'vessel_hogs\' im_name '_apex_candidates.txt']);
apex_can = load([base_dir 'apex_maps\set12g_half_296655\miccai_maxima\' im_name '_candidates.mat']);
apex_res = load([base_dir 'apex_maps\set12g_half_296655\miccai_maxima\rescores\' im_name '_candidates.mat']);
apex_rec = load([base_dir 'apex_maps\set12g_half_296655\miccai_maxima\rescores_corrected\' im_name '_candidates.mat']);

num_cans = size(apex_can.candidate_xy,1);
for i_can = 1:num_cans
    
    x0 = apex_can.candidate_xy(i_can,1)-1;
    y0 = apex_can.candidate_xy(i_can,2)-1;
    s = apex_can.candidate_scores(i_can);
    rs1 = apex_res.candidate_rescores(i_can);
    rs2 = apex_rec.candidate_rescores(i_can);
    
    dists = (vh(:,1)-x0).^2 + (vh(:,2)-y0).^2;
    [min_dist, min_i] = min(dists);
    
    if min_dist < 100
        
        display([...
            'x = ' num2str(x0) ', ' num2str(vh(min_i,1)) ', '...
            'y = ' num2str(y0) ', ' num2str(vh(min_i,2)) ', '...
            'score = ' num2str(s) ', ' num2str(vh(min_i,3)) ','...
            'rescore = ' num2str(rs1) ', ' num2str(vh(min_i,4)) ',' num2str(rs2)]);
    else
        display([...
            'x = ' num2str(x0) ',  y = ' num2str(y0) ' not matched']);
    end
end
%%
args.feature_sigma = 0;
args.ori_sigma = 0;
args.width_sigma = 2;
args.num_cells = 8;
args.cell_sz = 8; %Size of HoG cells in blocks
args.block_sz = [2 2];%Size of blocks in cells
args.num_ori_bins = 12; %Number of bins in orientation histograms
args.norm_method = 'l1-sqrt'; %Method for local normalisation
args.block_spacing = 8; %Separation between blocks in pixels - controls level of overlap
args.gradient_operator = [-1 0 1];
args.spatial_sigma = 0;
args.angle_wrap = 1;
args.base_width = 20;
args.overwrite = 0;
args.debug = 0;

%Get HoG args from main args
hog_args.cell_sz = [cell_sz cell_sz];
hog_args.block_sz = block_sz;
hog_args.num_ori_bins = num_ori_bins;
hog_args.norm_method = norm_method;
hog_args.block_spacing = block_spacing;
hog_args.gradient_operator = gradient_operator;
hog_args.spatial_sigma = spatial_sigma;
hog_args.angle_wrap = angle_wrap;

%Get patch size and form template x,y coordinates for the patch
patch_sz = args.num_cells*args.cell_sz;
patch_sz = patch_sz + 2; %Account for padding
patch_sz2 = (patch_sz - 1)/2;
hog_sz = args.num_cells*args.num_cells*args.num_ori_bins;

%Set up x,y coordinates for template patch
x = repmat(-patch_sz2:patch_sz2, patch_sz, 1);
y = x';
xy = [x(:) y(:)];

if args.feature_sigma
    g_feat = gaussian_filters_1d(args.feature_sigma);
    g_feat = g_feat / sum(g_feat);    
end
if args.ori_sigma
    g_ori = gaussian_filters_1d(args.ori_sigma);
    g_ori = g_ori / sum(g_ori);
end 
if args.width_sigma
    g_width = gaussian_filters_1d(args.width_sigma);
    g_width = g_width / sum(g_width);
end   
    
%Load in images and vessel markup
vessel_feature_im = double(u_load('C:\isbe\nailfold\data\rsa_study\master_set\images\10598c.mat'));
vessel_ori = u_load('C:\isbe\nailfold\data\rsa_study\master_set\predictions\orientation\rf_regression\296621\10598c_pred.mat');
vessel_width = u_load('C:\isbe\nailfold\data\rsa_study\master_set\predictions\width\rf_regression\297037\10598c_pred.mat');
load([candidates_dir im_name '_candidates'], 'candidate_xy');
        
    if isempty(candidate_xy) %#ok
        candidates_hogs = []; %#ok
        candidate_oris = []; %#ok
        candidate_widths = []; %#ok
    else
    
        if args.feature_sigma
            vessel_feature_im = conv2(g_feat', g_feat, vessel_feature_im, 'same');
        end
        if args.ori_sigma
            vessel_ori = conv2(g_ori', g_ori, vessel_ori, 'same');
        end 
        if args.width_sigma
            vessel_width = conv2(g_width', g_width, vessel_width, 'same');
        end
        candidate_oris = interp2(vessel_ori, candidate_xy(:,1), candidate_xy(:,2));
        candidate_widths = interp2(vessel_width, candidate_xy(:,1), candidate_xy(:,2));
        clear vessel_ori vessel_width;

        candidate_oris = angle(candidate_oris) / 2; 

        num_candidates = size(candidate_xy,1);
        candidates_hogs = zeros(num_candidates, hog_sz);

        for i_can = 1:num_candidates

            %EXtract patch and compute HoG
            ori_c = candidate_oris(i_can);
            width_c = candidate_widths(i_can);

            %Get scale relative to base width a make rotation matrix
            rot = [cos(ori_c) -sin(ori_c); sin(ori_c) cos(ori_c)];
            scale = width_c / args.base_width;

            %Transform points given scale and angle and translate to
            %candidate position
            xya = xy * rot * scale;
            xa = reshape(xya(:,1) + candidate_xy(i_can,1), patch_sz, patch_sz);
            ya = reshape(xya(:,2) + candidate_xy(i_can,2), patch_sz, patch_sz);

            %Sample vessel prob patch
            vessel_feature_patch = interp2(vessel_feature_im, xa, ya, '*linear', 0);
            [hog] = compute_HoG(vessel_feature_patch, hog_args);       
            candidates_hogs(i_can,:) = hog(:)';
            
            if args.debug && i_can == 1 && i_im <= 20
                plot_hog(vessel_feature_patch, hog, args.num_cells, args.angle_wrap);
            end
        end
    end
    save([hog_dir im_name '_hog.mat'], 'candidates_hogs', 'candidate_oris', 'candidate_widths');
%%
compute_apex_candidate_hogs(...
    'image_names',          {'10598c'},...   ...
    'data_dir',             [nailfoldroot 'data/rsa_study/master_set/'],...
    'feature_im_dir',       'images',...
    'ori_dir',              'rf_regression/296621/',...
    'width_dir',            'rf_regression/297037/',...
    'candidates_dir',       'apex_maps/set12g_half_296655/miccai_maxima',...
    'hog_dir',              'bob',...
    'feature_sigma',        0,...
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
    'overwrite',            1,...
    'debug',                1);

-i C:/isbe/nailfold/models/vessel/orientation/rf_regression/675752/trees/bfs_orig/tree_list.txt -o C:/isbe/nailfold/models/vessel/orientation/rf_regression/675752/trees/bfs_orig/rf.bfs
    
