extract_apex_measures_set(...
        'data_dir', 'C:\isbe\nailfold\data\rsa_study\test_half\',...
        'num_jobs', 1, 'task_id', 1,...
        'prob_dir',             'rf_classification/296655/',...
        'ori_dir',              'rf_regression/296621/',...
        'width_dir',            'rf_regression/297037/',...
        'candidates_dir',       'apex_maps\set12g_half_296655\mixed_maxima',...
        'metrics_dir',          'apex_metrics\all',...
        'fov_mask_dir',         'fov_masks/',...
        'prob_sigma',           1,...
        'ori_sigma',            0,...
        'width_sigma',          1,...
        'all',                  1,...
        'plot', 0);
    
%%
DATA_ROOT="scratch/nailfold/models/" MODEL_ROOT="vessel/detection/rf_classification" MODEL_PATH="304666" MAKE_SAMPLED_MAPS=1 qsub -V -l short matlab_code/trunk/hydra/cuc/combine_hydra_rfs.sh
DATA_ROOT="scratch/nailfold/" MODEL_ROOT="models/vessel/detection/rf_classification" MODEL_PATH="304666" NUM_JOBS=601 IMAGE_ROOT="data/rsa_study/test_half" USE_SAMPLED_MAPS=0 OVERWRITE=0 qsub -l twoday -V -t 1-10 -hold_jid 305284 matlab_code/trunk/hydra/cuc/predict_image_set.sh
%%
for i_tk = 86
    extract_apex_measures_set(...
        'data_dir', 'C:\isbe\nailfold\data\rsa_study\test_half\',...
        'num_jobs', 601, 'task_id', i_tk,...
        'prob_dir',             'rf_classification/296655/',...
        'ori_dir',              'rf_regression/296621/',...
        'width_dir',            'rf_regression/297037/',...
        'fov_mask_dir',         'fov_masks/',...
        'candidates_dir',        'apex_maps\set12g_half_296655\mixed_maxima',...
        'prob_sigma',           1,...
        'ori_sigma',            0,...
        'width_sigma',          1,...
        'plot', 1);
end
%%
vessel_prob = u_load('C:\isbe\nailfold\data\rsa_study\test_half\predictions\detection\rf_classification\296655\10598c_pred.mat');
vessel_ori = u_load('C:\isbe\nailfold\data\rsa_study\test_half\predictions\orientation\rf_regression/296621\10598c_pred.mat');
vessel_width = u_load('C:\isbe\nailfold\data\rsa_study\test_half\predictions\width\rf_regression/297037\10598c_pred.mat');

[vessel_centre] = extract_vessel_centres(vessel_prob, vessel_ori, vessel_width, ... % non-strict mode
    'prob_sigma',           1,...
    'ori_sigma',            1,...
    'width_sigma',            1,...
    'strong_vessel_thresh', 0.25,...
    'weak_vessel_thresh',   0);


