% Test work for new method of finding markers

%Set up some constants from the main stepwedge program
C_mag = [4475.2, 4472.2, 4477.7, 4479.5; 5515.3, 5517.5, 5522.6, 5527.5];
M_mag = [8.10, 8.35, 8.35, 8.36; 10.32, 10.33, 10.41, 10.42];
mam_list = dir('C:\isbe\density\mammograms\*.tif');

%Make sure we're in the write directory for the private code
cd C:\isbe\matlab_code\trunk\density\stepwedge\private

%%
n = 13;
mam = imread(['C:\isbe\density\mammograms\', mam_list(n).name]);
if ~isempty(strfind(mam_list(n).name, '1824'))
    filmsizes = 1;
    max_pairs = 3;
else
    filmsizes = 2;
    max_pairs = 4;
end

if filmsizes == 1
    % this is only needed for the 1824 film sizes
    mam = rot90(mam);
end

%mam = medfilt2(mam);

markerdetect(mam, filmsizes, M_mag, C_mag, max_pairs, 0);
%%
figure(...
    'WindowStyle', 'normal',...
    'Position', [200 200 190 200],...
    'Color', [1 1 1]);

ui.marker_l1 = uicontrol(...
    'Style', 'Radio',...
    'Units', 'pixels',...
    'Position', [10 0 50 50],...
    'Callback',@feedback_Callback,...
    'BackgroundColor', [1 1 1]);
ui.marker_l2 = uicontrol(...
    'Style', 'Radio',...
    'Units', 'pixels',...
    'Position', [60 0 50 50],...
    'Callback',@feedback_Callback,...
    'BackgroundColor', [1 1 1]);
ui.marker_l3 = uicontrol(...
    'Style', 'Radio',...
    'Units', 'pixels',...
    'Position', [110 0 50 50],...
    'Callback',@feedback_Callback,...
    'BackgroundColor', [1 1 1]);
ui.marker_l4 = uicontrol(...
    'Style', 'Radio',...
    'Units', 'pixels',...
    'Position', [160 0 30 50],...
    'Callback',@feedback_Callback,...
    'BackgroundColor', [1 1 1]);
ui.marker_u1 = uicontrol(...
    'Style', 'Radio',...
    'Units', 'pixels',...
    'Position', [10 150 50 50],...
    'Callback',@feedback_Callback,...
    'BackgroundColor', [1 1 1]);
ui.marker_u2 = uicontrol(...
    'Style', 'Radio',...
    'Units', 'pixels',...
    'Position', [60 150 50 50],...
    'Callback',@feedback_Callback,...
    'BackgroundColor', [1 1 1]);
ui.marker_u3 = uicontrol(...
    'Style', 'Radio',...
    'Units', 'pixels',...
    'Position', [110 150 50 50],...
    'Callback',@feedback_Callback,...
    'BackgroundColor', [1 1 1]);
ui.marker_u4 = uicontrol(...
    'Style', 'Radio',...
    'Units', 'pixels',...
    'Position', [160 150 30 50],...
    'Callback',@feedback_Callback,...
    'BackgroundColor', [1 1 1]);