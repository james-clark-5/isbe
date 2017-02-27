% Script to remove dirt from all images
% PUT THE DIRT FOLDERS, NAMED "DIRT", INSIDE THE FOLDER WITH IMAGES
% (MAKE A BACKUP FIRST!)

%ignore this dodgy hack
backslash = '\';

fprintf('DID YOU SPECIFY WHICH WAVELENGTH FILES TO LOOK AT? make_dirt_image-function.m\n');
fprintf('DID YOU SPECIFY WHICH WAVELENGTH FILES TO LOOK AT? clean+_dirty_frames.m\n');

%Get folders (ignoring files and the two "." ".." folders
d = dir;
isub = [d(:).isdir];
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
%Get number of folders
numFolders=size(nameFolds, 1);
%Get current main directory, as string
main_directory = cellstr(pwd);
%%%%%%%%%%%%%%%%%%%%%%%%%%
%Loop through all folders containing images
%Initialise iFolders
iFolders = 1;
dirt_subdir='\dirt\';

while iFolders<numFolders+1
    %Get frame directories 
    current_frames_dir = nameFolds(iFolders);
    frames_dir = sprintf('%s%s%s%s',main_directory{1},backslash,current_frames_dir{1},backslash);
    %Get dirt directories
    dirt_frames_dir = sprintf('%s%s%s%s', main_directory{1},backslash,current_frames_dir{1},dirt_subdir);

    %mkdir(frames_dir,'Our Saved Images')

    %% Main loop - send frames&dirts directories to cleaning function
    % output of function is to frames folder, w/ "CLEAN" in name

    %NEED TO ADD THIS
    %jj wavelength of filter for images
    %filter_wavelength = 560; %jj change this when filter changes

    %Make dirt image
    %You want to use the (out-of-focus) frames you captured especially for this
    [dirt_image] = make_dirt_image_function(dirt_frames_dir);

    % use a butchered frame cleaning function
    clean_dirty_frames(frames_dir, ... 
        'time1_ext', '_t0_',...
    ...% % % %     'time2_ext', '_t2_',...
        'image_format', 'bmp',...
        'dirt_image', dirt_image,...
        'theta_range', 0,...
        'offset_lim', 120,...
        'sigma', 8,...
        'corrections_dir', [], ...
        'transforms_dir', [], ...
        'make_videos', false,... %Switch to true if you have ffmpeg installed and included on your system path and want to make videos of vessel flow
        'display_output', 0);

    iFolders = iFolders + 1;
end

prog_end = 'finished running!\n'
