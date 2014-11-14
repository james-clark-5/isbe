%Detecting vessels in synthetic frames
rf_vessel = u_load('C:\isbe\nailfold\models\vessel\detection\rf_classification\222836\predictor.mat');
rf_vessel.tree_root = 'C:\isbe\nailfold\models\vessel\detection\rf_classification\';
rf_job_args_vessel = u_load('C:\isbe\nailfold\models\vessel\detection\rf_classification\222836\job_args.mat');

rf_ori = u_load('C:\isbe\nailfold\models\vessel\orientation\rf_regression\222835\predictor.mat');
rf_ori.tree_root = 'C:\isbe\nailfold\models\vessel\orientation\rf_regression/';
rf_job_args_ori = u_load('C:\isbe\nailfold\models\vessel\orientation\rf_regression\222835\job_args.mat');

 
frame_dir = 'N:\Nailfold Capillaroscopy\Wellcome\fromPhil\simulated_frames\unregistered\';
vessel_dir = [frame_dir 'predictions\vessel\'];
ori_dir = [frame_dir '\predictions\orientation\'];
mkdir(vessel_dir);
mkdir(ori_dir);

for i_frame = 1:10
    
    frame = imread([frame_dir 'frame_' zerostr(i_frame,4) '.png']);
    frame = rot90(frame, 2);
    
    [frame_vessel_prediction] = predict_image(...
        'image_in', frame,...
        'decomposition_args', job_args.decomposition_args,...
        'predictor', rf_vessel, ...
        'prediction_type', 'rf_classification',...
        'output_type', 'classification',...
        'use_probs', 0,...
        'mask', [],...
        'tree_mask', [], ...
        'num_trees', [], ...
        'max_size', 128,...
        'incremental_results', 0);
    
    [frame_ori_prediction] = predict_image(...
        'image_in', frame,...
        'decomposition_args', rf_job_args_ori.decomposition_args,...
        'predictor', rf_ori, ...
        'prediction_type', 'rf_regression',...
        'output_type', 'orientation',...
        'use_probs', 0,...
        'mask', [],...
        'tree_mask', [], ...
        'num_trees', [], ...
        'max_size', 128,...
        'incremental_results', 0);
    
    if i_frame <= 10
        figure; 
        subplot(1,2,1); imgray(complex2rgb(frame_ori_prediction));
        subplot(1,2,2); imgray(frame_vessel_prediction);
    end
    
    frame_vessel_prediction = rot90(frame_vessel_prediction,2);
    frame_ori_prediction = rot90(frame_ori_prediction,2);
    
    save([vessel_dir 'frame_' zerostr(i_frame,4) '_vessel_pred.mat'], 'frame_vessel_prediction');
    save([vessel_dir 'frame_' zerostr(i_frame,4) '_ori_pred.mat'], 'frame_ori_prediction');
end
%%
[dual_frame_vessel_prediction] = predict_image(...
    'image_in', frame1,...
    'decomposition_args', job_args.decomposition_args,...
    'predictor', rf_vessel, ...
    'prediction_type', 'rf_classification',...
    'output_type', 'classification',...
    'use_probs', 0,...
    'mask', [],...
    'tree_mask', [], ...
    'num_trees', [], ...
    'max_size', 128,...
    'incremental_results', 0);

[dual_frame_ori_prediction] = predict_image(...
        'image_in', frame1,...
        'decomposition_args', rf_job_args_ori.decomposition_args,...
        'predictor', rf_ori, ...
        'prediction_type', 'rf_regression',...
        'output_type', 'orientation',...
        'use_probs', 0,...
        'mask', [],...
        'tree_mask', [], ...
        'num_trees', [], ...
        'max_size', 128,...
        'incremental_results', 0);
