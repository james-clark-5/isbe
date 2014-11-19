function mb_build_g_pyr_tsvq(varargin)

%
% MB_KNEAREST_SEARCH Synthesise 
%
% MB_KNEAREST_SEARCH uses the U_PACKARGS interface function
% and so arguments to the function may be passed as name-value pairs
% or as a struct with fields with corresponding names. The field names
% are defined as:
%
% Mandatory Arguments:
%
% Return Value:
%
%   MB_KNEAREST_SEARCH returns ??.
%
% Example Usage:
%
% References:
%
% See also: MB_KNEAREST_BUILD

% Unpack the arguments:

args = u_packargs(varargin, 0, ...
			{'PyramidDir', 'OutputDir'}, ... % Mandatory arguments
			'WindowSize1', 5, ...
			'WindowSize2', 9, ...
            'CutOffLevel', 4 ...
			);

%Make the output directory if it doesn't already exist
if ~isdir(args.OutputDir)
	mkdir(args.OutputDir);
end

% ensure the directory names are filesep-terminated
if ~strcmp(args.OutputDir(end), filesep)
	args.OutputDir = [args.OutputDir filesep];
end

if ~strcmp(args.PyramidDir(end), filesep)
	args.PyramidDir = [args.PyramidDir filesep];
end

% get a listing of the input files
input_list = dir([args.PyramidDir '*pyramid*']);

% loop over each pyramid, building tsvq structures
for i = 1 : length(input_list)
    
    display(['Building tsvq structures for pyramid: ',...
        input_list(i).name]);
    
    pyramid = u_load([args.PyramidDir input_list(i).name]);

    tsvq_dir = [args.OutputDir, input_list(i).name(1:end-4), '_tree'];
    mkdir(tsvq_dir);
    
    tsvq_names = cell(5, 2);
    
    %Build a suitable ROI image from which to sample points - for now we're
    %going to use a 128x128 square in the middle of the image, although
    %obviously more options should be provided
    
    roi_image = logical(zeros(size(pyramid{1}))); %#ok
    row_centre = round(size(pyramid{1}, 1) / 2);
    col_centre = round(size(pyramid{1}, 2) / 2);
    roi_image(row_centre-64:row_centre+63, col_centre-64:col_centre+63) = 1;
    
    [rows cols] = find(roi_image);
    
    for level = args.CutOffLevel:-1:1
        
        %calculate roi subscripts (nb. mask applies to level+1)
        subscripts = ...
            unique([ceil(rows/2^(level)) ceil(cols/2^(level))], 'rows');
        
        
        k_args.Image1 = pyramid{level+1};
        k_args.Image2 = pyramid{level};
        k_args.WindowSize1 = args.WindowSize1;
        k_args.WindowSize2 = args.WindowSize2;
        k_args.ROISubscripts = subscripts;
        k_args.Method = 'tree';
        k_args.BothLevels = false;
            
        display(['Building tsvq for pyramid level = ', num2str(level)]);

        tsvq_tree = mb_knearest_build(k_args); %#ok

        tree_name = [tsvq_dir, '/tsvq_', num2str(level), '_1'];
        save(tree_name, 'tsvq_tree');
        tsvq_names{level, 1} = tree_name;
        clear tsvq_tree;

        k_args.BothLevels = true;
        tsvq_tree = mb_knearest_build(k_args); %#ok
        tree_name = [tsvq_dir, '/tsvq_', num2str(level), '_2'];
        save(tree_name, 'tsvq_tree');
        tsvq_names{level, 2} = tree_name;
        clear k_args tsvq_tree;
    end

    save([tsvq_dir, '/tsvq_names'], 'tsvq_names');
end