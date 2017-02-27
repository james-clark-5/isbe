% Script to find the mean of mean brightness values, and variance

% jj Want to use cleaned frames?
% NEED TO CLEAN FRAMES BEFOREHAND - USE "dirt_remover_main.m" file
% so that you have some cleaned frames to load into frames_dir

fprintf('Did you remove dirt from images? If so, use the corrections subfolder! ~ line34\n');
fprintf('DID YOU SPECIFY WHICH WAVELENGTH FILES TO LOOK AT? ~line 38\n');

%ignore this dodgy lazy hack
backslash = '\';

%Get folders (ignoring files and the two "." ".." folders
d = dir;
isub = [d(:).isdir];
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
%Get number of folders
numFolders=size(nameFolds, 1);
%Get current main directory, as string
main_directory = cellstr(pwd);
corrected_subdir = '\corrections\';
%%%%%%%%%%%%%%%%%%%%%%%%%%
%Loop through all folders containing images
%Initialise iFolders
iFolders = 1;
%Prepare array to store mean of means and s.d.
meanMean_sd_array = zeros(numFolders,2);
while iFolders<numFolders+1
    current_frames_dir = nameFolds(iFolders);
    % WANT TO ANALYSE DIRTY FRAMES? HAVE "BACKSLASH" AS LAST STRING
    % WANT TO ANALYSE CLEANED FRAMES? HAVE "corrected_subdir" AS LAST
    % STRING
    frames_dir = sprintf('%s%s%s%s', main_directory{1},backslash, current_frames_dir{1},corrected_subdir);
    %Create array to store 
        
        %%Get number of frames
        frames_list = dir([frames_dir '*_C_500_*' '*.bmp']);
        num_frames = length(frames_list);

        %Get brightnesses of all frames, save to array
        for i_frame = 1:num_frames
            frame = double(imread([frames_dir frames_list(i_frame).name]));

            %jj get mean brightness of a frame
            single_frame_mean = mean(mean(frame));
            %jj save mean brightness of a frame to an array
            meanBrightnesses(i_frame) = single_frame_mean; %#ok<SAGROW>
        end
        
        %Now get mean of means, and variance
        mean_of_means = mean(meanBrightnesses);
        for i_frame = 1:num_frames
        numerator_var_parts(i_frame) = (meanBrightnesses(i_frame) - mean_of_means)^2; %#ok<SAGROW>
        end
        variance = (sum(numerator_var_parts))/(num_frames-1);
        std_dev = variance.^0.5;

        %Save mean of means & s.d. to array (one pair of values for each folder of images)

        meanMean_sd_array(iFolders,1)=mean_of_means;
        meanMean_sd_array(iFolders,2)=std_dev;     
        
        iFolders = iFolders + 1;
end

prog_end = 'all your means are mean now! y''know what I mean bor?\n'