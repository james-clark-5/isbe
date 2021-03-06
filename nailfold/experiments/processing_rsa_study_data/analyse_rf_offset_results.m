%function analyse_aam_results
%% 1) First run through all the apex off set maps and extract the local maxima
im_list = dir('C:\isbe\nailfold\data\rsa_study\test\images\*.mat');

apex_map_dir = 'C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\';
fov_mask_dir = 'C:\isbe\nailfold\data\rsa_study\test\fov_masks\';
vessel_centres_dir = 'C:\isbe\nailfold\data\rsa_study\test\vessel_centres\';
create_folder([apex_map_dir 'local_maxima']);

exclsuion_zone = 40;
apex_class_thresh = 0.5;
base_width = 20;

for i_im = 1:length(im_list);
    im_name = im_list(i_im).name(1:6);
    
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
    
    save([apex_map_dir 'local_maxima\' im_name '_maxima'],...
        'candidate_xy', 'candidate_scores');
end
%% 2) Now we can run through all the images, work which apices were detected
% We also analyse:
%   - What measure detected each apex
%   - What % of detections were true
%   - For apices we missed, why were they discarded
make_detection_results_struc(...
    'results_name', 'rf_offsets_', ...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\local_maxima\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test/results/'],...
    'prob_dir', [nailfoldroot 'data/rsa_study/test/predictions/detection/rf_classification/257273/'],...
    'selected_gt', [],...
    'selected_candidates', []);

%% 3) Start doing some analysis
%rf_offsets_20131106T111616
analyse_detection_results(...
    'results_name', 'rf_offsets_20131121T180614',...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\local_maxima\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test/results/'],...
    'selected_images', [],...
    'use_only_gradeable', 1,...
    'min_num_markers', 2,...
    'max_missing_markers', inf,...
    'overall_summary', 1,...
    'summary_by_grade', 1,...
    'summary_by_shape', 0,...
    'summary_by_size', 0,...
    'compute_rocs', 1,...
    'analysis_by_width', 0,...
    'fixed_counting', 0,...
    'pct_counting', 0,...
    'perfect_counting', 0);
%%
%% 1) Try this again, but try and select a distal row
im_list = dir('C:\isbe\nailfold\data\rsa_study\test\images\*.mat');

apex_map_dir = 'C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\';
fov_mask_dir = 'C:\isbe\nailfold\data\rsa_study\test\fov_masks\';
vessel_centres_dir = 'C:\isbe\nailfold\data\rsa_study\test\vessel_centres\';
create_folder([apex_map_dir 'distal_maxima']);

exclsuion_zone = 40;
apex_class_thresh = 0.5;
base_width = 20;

stage1_max = 5;
stage2_max = 20;
%
for i_im = 1:length(im_list);
    im_name = im_list(i_im).name(1:6);
    
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
    
    num_candidates = size(candidate_xy,1);
    
    confirmed_xy = [];
    confirmed_scores = [];
    potential_xy = [];
    potential_scores = [];
    secondary_xy = [];
    secondary_scores = [];
    
    if num_candidates > stage1_max
        
        max_candidates = min(num_candidates, 20);
        [distal_idx] = select_distal_candidates(candidate_xy(1:max_candidates,:), 10, [], 0);
        
        confirmed_xy = candidate_xy(distal_idx,:);
        confirmed_scores = candidate_scores(distal_idx,:);
        
        potential_xy = candidate_xy(stage2_max+1:end,:);
        potential_scores = candidate_scores(stage2_max+1:end,:);
        
        
        if num_candidates > stage2_max                       
            [distal_idx] = evaluate_distal_candidates(confirmed_xy, potential_xy);   
            
            %plot(potential_xy(distal_idx,1), potential_xy(distal_idx,2), 'bx');
            %plot(potential_xy(~distal_idx,1), potential_xy(~distal_idx,2), 'mv');
            
            secondary_xy = potential_xy(distal_idx,:);
            secondary_scores = potential_scores(distal_idx,:);
            
            
        end
        
        candidate_xy = [confirmed_xy; secondary_xy];
        candidate_scores = [confirmed_scores; secondary_scores];
        
        [distal_idx] = select_distal_candidates(candidate_xy, 10, [], 0);
        
        candidate_xy = candidate_xy(distal_idx,:);
        candidate_scores = candidate_scores(distal_idx,:);
        
        %plot(candidate_xy(:,1), candidate_xy(:,2), 'go');
    end   
    
    save([apex_map_dir 'distal_maxima\' im_name '_maxima'],...
        '*_xy', '*_scores');
end
%% 2) Now we can run through all the images, work which apices were detected
% We also analyse:
%   - What measure detected each apex
%   - What % of detections were true
%   - For apices we missed, why were they discarded
make_detection_results_struc(...
    'results_name', 'rf_offsets_', ...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\distal_maxima\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test/results/'],...
    'selected_gt', [],...
    'selected_candidates', []);

%% 3) Start doing some analysis
analyse_detection_results(...
    'results_name', 'rf_offsets_20131113T095859',...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\distal_maxima\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test/results/'],...
    'selected_images', [],...
    'use_only_gradeable', 1,...
    'min_num_markers', 2,...
    'max_missing_markers', inf,...
    'overall_summary', 1,...
    'summary_by_grade', 1,...
    'summary_by_shape', 0,...
    'summary_by_size', 0,...
    'compute_rocs', 1,...
    'analysis_by_width', 0,...
    'fixed_counting', 1,...
    'pct_counting', 1,...
    'perfect_counting', 1);

%%
%% 1) First run through all the apex off set maps and extract the local maxima
im_list = dir('C:\isbe\nailfold\data\rsa_study\test\images\*.mat');

apex_map_dir = 'C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\';
fov_mask_dir = 'C:\isbe\nailfold\data\rsa_study\test\fov_masks\';
vessel_centres_dir = 'C:\isbe\nailfold\data\rsa_study\test\vessel_centres\';
create_folder([apex_map_dir 'local_maxima2']);

exclsuion_zone = 40;
apex_class_thresh = 0.5;
base_width = 20;

for i_im = 1:length(im_list);
    im_name = im_list(i_im).name(1:6);
    
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
    
    save([apex_map_dir 'local_maxima2\' im_name '_candidates'],...
        'candidate_xy', 'candidate_scores');
end
%% 1a
select_vessels_from_candidates_set('start_i', 1, 'end_i', [],...
    'do_fill_gaps', 0, 'do_distal_sub', 0, 'do_save', 1, 'do_plot', 0,...
    'data_dir', 'C:\isbe\nailfold\data\rsa_study\test\',...
    'candidates_dir', 'apex_maps\frog\local_maxima2\');
%% 2) Now we can run through all the images, work which apices were detected
% We also analyse:
%   - What measure detected each apex
%   - What % of detections were true
%   - For apices we missed, why were they discarded
make_detection_results_struc(...
    'results_name', 'rf_offsets_', ...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\local_maxima2\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test/results/'],...
    'prob_dir', [nailfoldroot 'data/rsa_study/test/predictions/detection/rf_classification/257273/'],...
    'selected_gt', [],...
    'selected_candidates', []);

%% 3) Start doing some analysis
%rf_offsets_20131114T102114
im_by_im_counts = analyse_detection_results(...
    'results_name', 'rf_offsets_20131121T181011',...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\local_maxima2\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test/results/'],...
    'selected_images', 1:100,...
    'use_only_gradeable', 1,...
    'min_num_markers', 2,...
    'max_missing_markers', inf,...
    'overall_summary', 0,...
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
%% 4) For this try post merging the candidates if they seem to lie on the same vessel
im_list = dir('C:\isbe\nailfold\data\rsa_study\test\images\*.mat');

prob_dir = 'C:\isbe\nailfold\data\rsa_study\test\predictions\detection\rf_classification\257273\';
apex_map_dir = 'C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\';
create_folder([apex_map_dir 'post_merged']);

dist_thresh = 120;
connect_thresh = 0.5;
n_connect_pts = 20;

g = gaussian_filters_1d(2);
g = g / sum(g);

for i_im = 1:length(im_list);

    im_name = im_list(i_im).name(1:6);
    display(['Processing image :' num2str(i_im)]);

    load([apex_map_dir 'local_maxima2\' im_name '_candidates'],...
        'candidate_xy', 'candidate_scores');

    vessel_prob = u_load([prob_dir im_name '_pred.mat']);
    vessel_prob = conv2(g', g, vessel_prob, 'same');
    [candidate_xy, candidate_scores] = post_merge_candidates(candidate_xy, candidate_scores, ...
        vessel_prob, dist_thresh, connect_thresh, n_connect_pts, 0);

    save([apex_map_dir 'post_merged\' im_name '_candidates'],...
        'candidate_xy', 'candidate_scores');
end
%%
make_detection_results_struc(...
    'results_name', 'post_merged_smooth_', ...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\post_merged\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test/results/'],...
    'prob_dir', [nailfoldroot 'data/rsa_study/test/predictions/detection/rf_classification/257273/'],...
    'selected_gt', [],...
    'selected_candidates', [], ...
    'do_plot', 0);
%%
%rf_offsets_20131118T120345 %rf_offsets_20131121T175639
im_by_im_counts = analyse_detection_results(...
    'results_name', 'post_merged_smooth_20131122T162713',...
    'candidates_dir',    'C:\isbe\nailfold\data\rsa_study\test\apex_maps\frog\post_merged\',... %mandatory arguments
    'apex_gt_dir', [nailfoldroot 'data/rsa_study/test/apex_gt/'],...
    'results_dir', [nailfoldroot 'data/rsa_study/test/results/'],...
    'selected_images', [],...
    'use_only_gradeable', 1,...
    'min_num_markers', 2,...
    'max_missing_markers', inf,...
    'overall_summary', 0,...
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