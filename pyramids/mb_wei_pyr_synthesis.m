function [synthesised_image, target_pyramid] = mb_wei_pyr_synthesis(varargin)
%
% MB_WEI_PYR_SYNTHESIS Synthesise 
%
% MB_WEI_PYR_SYNTHESIS uses the U_PACKARGS interface function
% and so arguments to the function may be passed as name-value pairs
% or as a struct with fields with corresponding names. The field names
% are defined as:
%
% Mandatory Arguments:
%
% Return Value:
%
%   MB_WEI_PYR_SYNTHESIS returns SYNTHESISED_IMAGE, a synthetic texture.
%
% Example Usage:
%
% References:
%
% See also:

% Unpack the arguments:
args = u_packargs(varargin, '0', ... % strict mode
		  {...  % The mandatory arguments
          'FilledImage',...
          },... % The optional arguments
          'TargetImage', [],...
          'TargetPyramid', [],...
          'SampleImage', [],...
          'SamplePyramid', [],...
          'SampleData', [],...
          'SynthesisMode', 'simple', ...
		  'SaveFile', [],...
          'PyrLevels', 5,...
          'PyrOrientations', 5,...
          'CutOffLevel', 5,...
          'K_method', 'standard',...
          'WindowSize1', 5,...
          'WindowSize2', 5,...
          'Plot', 0);

clear varargin;

display(args);

% Use a proxy for the 'SynthesisMode' parameter, to avoid doing
% expensive string comparisons during run-time.
switch args.SynthesisMode
 case 'simple'
  
 case 'advanced'
  
 otherwise
  error(['The ' args.SynthesisMode ' mode is not supported.']);
end

if ~isempty(args.TargetImage)
    % convert TargetImage to doubles, maintain the pixel value ranges (0-255)
    args.TargetImage = double(args.TargetImage); % TargetImage is now a double
    
    % Calculate the pyramid for the image to be synthesised
    [target_pyramid p_sizes] = buildSFpyr(args.TargetImage, args.PyrLevels, args.PyrOrientations-1); %
    
    % Convert pyramid into Rose form
    target_pyramid = mb_change_pyramid_form(target_pyramid, p_sizes);

elseif ~isempty(args.TargetPyramid)
    target_pyramid = args.TargetPyramid;
    args = rmfield(args, 'TargetPyramid');
else
    error('Either a target image or target pyramid must be supplied');
end

if ~isempty(args.SampleImage)
    % convert SampleImage to doubles, maintain the pixel value ranges (0-255)
    args.SampleImage = double(args.SampleImage); % SampleImage is now a double
    
    % Calculate the pyramid for the image to be synthesised
    [sample_pyramid p_sizes] = buildSFpyr(args.SampleImage, args.PyrLevels, args.PyrOrientations-1); %
    
    % Convert pyramid into Rose form
    sample_pyramid = mb_change_pyramid_form(sample_pyramid, p_sizes);

elseif ~isempty(args.SamplePyramid)
    sample_pyramid = args.SamplePyramid;
    args = rmfield(args, 'SamplePyramid');
elseif isempty(args.SampleData)
    error('Either a sample image, pyramid or data must be supplied');
end

% get row/col subscripts of unfilled pixels
[p_rows p_cols] = find(~args.FilledImage);
%p_idx = sub2ind(size(args.TargetImage), p_rows, p_cols);

tic; % Start a record of when we start actually working on the synthesis

syn_args.K_method = args.K_method;
syn_args.WindowSize1 = args.WindowSize1;
syn_args.WindowSize2 = args.WindowSize2;


for level = args.CutOffLevel:-1:2
    
    if level > 1
        % Calculate indices for that level and make unique
        new_rows = ceil(p_rows/2^(level-2));
        new_cols = ceil(p_cols/2^(level-2));
        new_idx = sub2ind(size(target_pyramid{level,1}), new_rows, new_cols);

        %Don't need to do unique now
        %[new_idx orig_idx something_else] = unique(new_idx);
        %new_subs is 2-column matrix of unique indices, new_idx is column
        %vector specifying the original indices of the new subs

        %make filled image from new_idx
        filled_image = ones(size(target_pyramid{level,1}));
        filled_image(new_idx) = 0;
    else
        filled_image = args.FilledImage;
    end
    
    syn_args.PixelOrder = mb_compute_pixel_order(filled_image);
    
    for ori = 1:args.PyrOrientations
        
        %Now synthesise the new texture for the band and save back to
        %pyramid
        if isempty(args.SampleData)
            syn_args.SampleImage1 = sample_pyramid{level+1, ori};
            syn_args.SampleImage2 = sample_pyramid{level, ori};
        else
            syn_args.SampleData = ...
                u_load(args.SampleData{level, ori, 1});
        end
        
        syn_args.TargetImage1 = target_pyramid{level+1, ori};
        
        % 1) First-pass: synthesis using just lower level
        syn_args.TargetImage2 = target_pyramid{level, ori};
        syn_args.BothLevels = false;
        target_pyramid{level, ori} = mb_wei_tex_synthesis(syn_args);
        
        %display new texture if required
        if args.Plot
            figure; imagesc(target_pyramid{level, ori});...
                axis image; colormap(jet(256));
        end
        
        % 2) Correction-pass: synthesis using lower and current level
        if ~isempty(args.SampleData)
            syn_args.SampleData = ...
                u_load(args.SampleData{level, ori, 2});
        end
        
        syn_args.TargetImage2 = target_pyramid{level, ori};
        syn_args.BothLevels = true;
        temp = mb_wei_tex_synthesis(syn_args);
        
        display(['Correction pass diff = ' num2str(sum(abs(target_pyramid{level, ori}(:) - temp(:))))]);
        
        target_pyramid{level, ori} = temp;
        
        clear temp;
        %display new texture if required
        if args.Plot
            figure; imagesc(target_pyramid{level, ori});...
                axis image; colormap(jet(256));
        end
            
        if level == 1
            break;
        end
        
    end

end

% put pyrimad back into Simonecelli form
[target_pyramid p_sizes] = mb_change_pyramid_form(target_pyramid);

% reconstruct image from pyramid...
synthesised_image = uint8(reconSFpyr(target_pyramid, p_sizes));

%...but actually we prefer Rose's form to save it in!
target_pyramid = mb_change_pyramid_form(target_pyramid, p_sizes);

% save final image
if ~isempty(args.SaveFile)
    save(args.SaveFile, 'synthesised_image', 'target_pyramid');
end

% Report the generation of the synthetic image
disp('Progress: 100 percent complete.');
disp('A modified mamogram region has been synthesised!');

%
%main function end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pixel_order = compute_pixel_order(filled_image)

%pre-allocate pxiel_order
pixels_to_fill = sum(~filled_image(:));
pixel_order = zeros(pixels_to_fill, 1);
start_pix = 1;

while start_pix <= pixels_to_fill;
    
    unfilled_list = get_unfilled_perimeter_pixels(filled_image);    
    end_pix = start_pix + length(unfilled_list) - 1;
    pixel_order(start_pix:end_pix) = unfilled_list;
    filled_image(unfilled_list) = 1;
    start_pix = end_pix + 1;
end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [unfilled_list] = get_unfilled_perimeter_pixels(filled_image)
%
% Get a list of unfilled pixels neighbouring the pixels already filled.
% This is returned as a list of indices -- use ind2sub to get the image
% locations back.

unfilled_image = imdilate(filled_image, strel('disk', 1));
unfilled_image = double(unfilled_image) - double(filled_image);
unfilled_list = find(unfilled_image==1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%