function [training_data training_labels] = load_mass_training_data(varargin)
%SAMPLE_MAMMO_TRAINING_DATA *Insert a one line summary here*
%   [] = sample_mammo_training_data(varargin)
%
% SAMPLE_MAMMO_TRAINING_DATA uses the U_PACKARGS interface function
% and so arguments to the function may be passed as name-value pairs
% or as a struct with fields with corresponding names. The field names
% are defined as:
%
% Mandatory Arguments:
%
% Optional Arguments:
%
% Outputs:
%
% Example:
%
% Notes:
%
% See also:
%
% Created: 17-Aug-2010
% Author: Michael Berks 
% Email : michael.berks@postgrad.man.ac.uk 
% Phone : +44 (0)161 275 1241 
% Copyright: (C) University of Manchester 

% Unpack the arguments:
args = u_packargs(varargin,... % the user's input
    '0', ... % non-strict mode
    {'num_samples',...
    'abnormal_data',...
    'normal_data',... 
    'image_dir',...
    'save_name',...
    'save_dir'},...
    'fold_id', 1,...
    'num_folds', 10,...
    'view', [],...
    'do_template', 1,...
    'do_scale', 1,...
    'dist_range', [16 32 64 128 256],...
    'sigma_range', [1 2 4 8],...
    'angular_res', 1,...
    'image_type', '.mat',...
    'save_path', []);
clear varargin;

%First find all the abnormal mammograms that match the view type
abnormal_list = dir([args.image_dir args.abnormal_data '/*' args.view '*' args.image_type]);
abnormal_names = get_mammo_info(abnormal_list);

%If there is a meta folder associated with the abnormal dir we must select
%only the mammograms that actually have an abnormality in them, and therefore have meta
%information (as opposed to the contralateral mammogram also stored in the
%abnormal directory)
meta_list = dir([args.image_dir args.abnormal_data '/meta/*' args.view '*.mat']);
if ~isempty(meta_list)
    meta_names = get_mammo_info(meta_list);
    [dummy abnormal_idx] = intersect(abnormal_names, meta_names);
    abnormal_list = abnormal_list(abnormal_idx);
end

%Get list of normal mammograms and masks
normal_list = dir([args.image_dir args.normal_data '/*' args.view '*' args.image_type]);

%Select number of images to use
num_images = min(length(abnormal_list), length(normal_list));

%Workout the number of images to include in ecah fold
fold_size = ceil(num_images / args.num_folds);
start_idx = (args.fold_id-1)*fold_size + 1;
end_idx = min(args.fold_id*fold_size, num_images);

fold_idx = setdiff(1:num_images, start_idx:end_idx);

[abnormal_data] = load_mass_feature_data(...
    'num_samples', args.num_samples,...
    'mammo_idx', fold_idx,...
    'samples_path', [args.save_dir args.abnormal_data '/' args.save_name],...
    'do_template', args.do_template,...
    'do_scale', args.do_scale,...
    'dist_range', args.dist_range,...
    'sigma_range', args.sigma_range,...
    'angular_res', args.angular_res);

[normal_data] = load_mass_feature_data(...
    'num_samples', args.num_samples,...
    'mammo_idx', fold_idx,...
    'samples_path', [args.save_dir args.normal_data '/' args.save_name],...
    'do_template', args.do_template,...
    'do_scale', args.do_scale,...
    'dist_range', args.dist_range,...
    'sigma_range', args.sigma_range,...
    'angular_res', args.angular_res);

training_data = [abnormal_data; normal_data];
training_labels = [true(size(abnormal_data,1),1); false(size(normal_data,1),1)];