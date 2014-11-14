function [] = classification_maps_gui()
%OBSERVER_STUDY_GUI *Insert a one line summary here*
%   [] = observer_study_gui()
%
% Inputs:
%
% Outputs:
%
% Example:
%
% Notes:
%
% See also:
%
% Created: 14-May-2009
% Author: Michael Berks 
% Email : michael.berks@postgrad.man.ac.uk 
% Phone : +44 (0)161 275 1241 
% Copyright: (C) University of Manchester

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Program code that runs
%
%--------------------------------------------------------------------------
%Must have window style set to normal
orig_window_style = get(0,'DefaultFigureWindowStyle');
if ~strcmp(orig_window_style, 'normal')
    display('Warning: changing window style to normal for function');
    set(0,'DefaultFigureWindowStyle','normal');
end

%Set constants/variables that persist for all user sessions:
color1 = [1 1 1];
color2 = [212 208 200]/255; %#ok
color3 = [0 0 0];
buff = 5;
screen_size = get(0,'ScreenSize');

%Create empty variables that exist globally and will be filled auxilliary
%functions - this set do not need to be reset for each session
mammo_dir = 'C:\isbe\asymmetry_project\data\mammograms\2004_screening\abnormals\mat\';
map_dir = 'C:\isbe\asymmetry_project\data\contralateral_rfs\2004_screening\abnormals\';

num_pairs = [];
pair_strings = [];
pair_num = [];
pair_view = [];
curr_pair = [];
map_names_r = [];
map_names_l = [];

ui = [];
axes_pos1 = [];
axes_pos2 = [];
axes_pos3 = [];
axes_pos4 = [];
axes_pos5 = [];
axes_pos6 = [];
panel_pos = [];

im1 = [];
im2 = [];
im3 = [];
im4 = [];
meta_lx = [];
meta_rx = [];
meta_ly = [];
meta_ry = [];

%main program
create_main_fig
%get_pair_information;

%Reset window style
set(0,'DefaultFigureWindowStyle',orig_window_style);

%End of function

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Auxilliary functions so set up main UI figure (axes, buttons etc)
%
%--------------------------------------------------------------------------
    function create_main_fig
        %Generate main figure if it doens't already exist

        ui.main_fig = figure(...
            'Position', [0 30 screen_size(3), screen_size(4)-50],...
            'Visible','on',...
            'Name', 'Classification maps display tool',...
            'NumberTitle', 'off',...
            'MenuBar', 'none',...
            'WindowStyle', 'normal',...
            'Color', color1,...
            'CloseRequestFcn', @quit_Callback);
        
        
        x_max = screen_size(3);
        y_max = screen_size(4)-50;
        button_h = 40;
        button_w = 100;
        text_w = 250;
        panel_h = 80;
 
        
        figure(ui.main_fig);
        set(ui.main_fig,...
            'Color', color3,...
            'CloseRequestFcn', @quit_Callback);
        
        panel_w = 400;
        axes_cx = (x_max - panel_w)/2;
        axes_h = (y_max - 3*buff) / 2;
        axes_w = 0.8*axes_h;
        
        axes_pos1 = [axes_cx-0.5*buff-axes_w  2*buff+axes_h axes_w axes_h];
        axes_pos2 = [axes_cx+0.5*buff         2*buff+axes_h axes_w axes_h];
        axes_pos3 = [axes_cx-0.5*buff-axes_w  buff          axes_w axes_h];
        axes_pos4 = [axes_cx+0.5*buff         buff          axes_w axes_h];
        axes_pos5 = [axes_pos3(1)-25 axes_pos3(2) 20 axes_pos3(4)];
        axes_pos6 = [axes_pos1(1)-25 axes_pos1(2) 20 axes_pos1(4)];
        panel_pos = [x_max - panel_w - buff, buff, panel_w, y_max - 2*buff];
        
        ui.panel = uicontrol(...
            'Style','frame',...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', panel_pos,...
            'Visible', 'on');
        
        %------------------------------------------------------------------
        ui.panel1 = uipanel(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', [panel_pos(1)+buff y_max-buff-panel_h panel_w-2*buff panel_h],...
            'Visible', 'on');
           
        ui.mammo_dir_text = uicontrol(... 
            'Parent', ui.panel1,... 
            'Style','text',...
            'BackgroundColor', get(ui.panel, 'BackgroundColor'),...
            'FontName', 'Arial',...
            'String', 'Mammogram pairs folder:',...
            'HorizontalAlignment', 'left',...
            'Position', [0 button_h text_w 25]); 

        ui.mammo_dir_box = uicontrol(...
            'Style', 'edit',...
            'Position', [buff buff text_w button_h],...
            'BackgroundColor', [1 1 1],...
            'Parent', ui.panel1,...
            'String', mammo_dir);

        ui.mammo_dir_select = uicontrol(... 
            'Style', 'pushbutton',...
            'Position', [2*buff+text_w buff button_w button_h],...
            'String', 'Select',...
            'Parent', ui.panel1,...
            'Callback', @mammo_dir_select_Callback);
        %---------------------------------------------------------------
        ui.panel2 = uipanel(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', [panel_pos(1)+buff y_max-2*(buff+panel_h) panel_w-2*buff panel_h],...
            'Visible', 'on');
           
        ui.map_dir_text = uicontrol(... 
            'Parent', ui.panel2,... 
            'Style','text',...
            'BackgroundColor', get(ui.panel, 'BackgroundColor'),...
            'FontName', 'Arial',...
            'String', 'Organisation maps folder:',...
            'HorizontalAlignment', 'left',...
            'Position', [0 button_h text_w 25]); 

        ui.map_dir_box = uicontrol(...
            'Style', 'edit',...
            'Position', [buff buff text_w button_h],...
            'BackgroundColor', [1 1 1],...
            'Parent', ui.panel2,...
            'String', map_dir);

        ui.map_dir_select = uicontrol(... 
            'Style', 'pushbutton',...
            'Position', [2*buff+text_w buff button_w button_h],...
            'String', 'Select',...
            'Parent', ui.panel2,...
            'Callback', @map_dir_select_Callback);
        %---------------------------------------------------------------
        ui.panel3 = uipanel(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', [panel_pos(1)+buff y_max-3*(buff+panel_h) panel_w-2*buff panel_h],...
            'Visible', 'on');
           
        ui.update = uicontrol(... 
            'Parent', ui.panel3,... 
            'Style','pushbutton',...
            'String','Update data source',...
            'Tag','update',...
            'Callback', @update_Callback,...
            'Position', [buff, panel_h-buff-button_h, text_w, button_h]);
        %---------------------------------------------------------------
        ui.panel4 = uipanel(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', [panel_pos(1)+buff y_max-4*(buff+panel_h) panel_w-2*buff panel_h],...
            'Visible', 'on');
        
        ui.pair_number_text = uicontrol(... 
            'Parent', ui.panel4,... 
            'Style','text',...
            'BackgroundColor', get(ui.panel, 'BackgroundColor'),...
            'FontName', 'Arial',...
            'String', 'Select mammogram pair:',...
            'HorizontalAlignment', 'left',...
            'Position', [0 button_h+buff text_w 25]); 
        
        ui.pair_number_selecter = uicontrol(...
            'Parent', ui.panel4,...
            'Style', 'popupmenu',...
            'Position', [2*buff+button_w buff text_w-buff-button_w button_h],...
            'String', ' ',...
            'Enable', 'off',...
            'Callback', @pair_number_selecter_Callback);
        
        ui.previous_pair = uicontrol(...
            'Parent', ui.panel4,...
            'Style','pushbutton',...
            'String','Previous',...
            'Callback', @previous_pair_Callback,...
            'Position', [buff, buff, button_w, button_h],....
            'Enable', 'off');
        ui.next_pair = uicontrol(...
            'Parent', ui.panel4,...
            'Style','pushbutton',...
            'String','Next',...
            'Callback', @next_pair_Callback,...
            'Position', [2*buff+text_w, buff, button_w, button_h],...
            'BackgroundColor', color2,...
            'Enable', 'off');
        %---------------------------------------------------------------
        ui.panel5 = uipanel(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', [panel_pos(1)+buff y_max-5*(buff+panel_h) panel_w-2*buff panel_h],...
            'Visible', 'on');
        
        ui.min_c_slider_text = uicontrol(... 
            'Parent', ui.panel5,... 
            'Style','text',...
            'BackgroundColor', get(ui.panel, 'BackgroundColor'),...
            'FontName', 'Arial',...
            'String', 'Select min/max values of map contrast range: ' ,...
            'HorizontalAlignment', 'left',...
            'Position', [0 25 text_w+button_w+buff 25]); 
        
        ui.min_c_slider = uicontrol(... 
            'Style', 'slider',...
            'Position', [buff buff (text_w+button_w)/2 25],...
            'String', 'Select',...
            'Min', 0,...
            'Max', 1,...
            'Value', 0,...
            'SliderStep', [0.01 0.1],...
            'Parent', ui.panel5,...
            'Enable', 'off',...
            'Callback', @min_c_slider_Callback);
        
        ui.max_c_slider = uicontrol(... 
            'Style', 'slider',...
            'Position', [2*buff+(text_w+button_w)/2 buff (text_w+button_w)/2 25],...
            'String', 'Select',...
            'Min', 0,...
            'Max', 1,...
            'Value', 0,...
            'SliderStep', [0.01 0.1],...
            'Parent', ui.panel5,...
            'Enable', 'off',...
            'Callback', @max_c_slider_Callback);
        %---------------------------------------------------------------
        ui.panel6 = uipanel(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', [panel_pos(1)+buff y_max-6*(buff+panel_h) panel_w-2*buff panel_h],...
            'Visible', 'on');
        
        ui.min_m_slider_text = uicontrol(... 
            'Parent', ui.panel6,... 
            'Style','text',...
            'BackgroundColor', get(ui.panel, 'BackgroundColor'),...
            'FontName', 'Arial',...
            'String', 'Select min/max values of mammogram contrast range: ' ,...
            'HorizontalAlignment', 'left',...
            'Position', [0 25 text_w+button_w+buff 25]); 
        
        ui.min_m_slider = uicontrol(... 
            'Style', 'slider',...
            'Position', [buff buff (text_w+button_w)/2 25],...
            'String', 'Select',...
            'Min', 0,...
            'Max', 1,...
            'Value', 0,...
            'SliderStep', [0.01 0.1],...
            'Parent', ui.panel6,...
            'Enable', 'off',...
            'Callback', @min_m_slider_Callback);
        
        ui.max_m_slider = uicontrol(... 
            'Style', 'slider',...
            'Position', [2*buff+(text_w+button_w)/2 buff (text_w+button_w)/2 25],...
            'String', 'Select',...
            'Min', 0,...
            'Max', 1,...
            'Value', 0,...
            'SliderStep', [0.01 0.1],...
            'Parent', ui.panel6,...
            'Enable', 'off',...
            'Callback', @max_m_slider_Callback);
        %---------------------------------------------------------------
        ui.panel7 = uipanel(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', [panel_pos(1)+buff y_max-7*(buff+panel_h) panel_w-2*buff panel_h],...
            'Visible', 'on');
        
        ui.zoom_on = uicontrol(... 
            'Parent', ui.panel7,... 
            'Style','togglebutton',...
            'String','Zoom',...
            'Tag','zoom_on',...
            'Callback', @zoom_Callback,...
            'Position', [buff, buff, button_w, button_h],...
            'Enable', 'off'); 
        
        ui.pan_on = uicontrol(... 
            'Parent', ui.panel7,... 
            'Style','togglebutton',...
            'String','Pan',...
            'Tag','zoom_on',...
            'Callback', @pan_Callback,...
            'Position', [2*buff+button_w, buff, button_w, button_h],...
            'Enable', 'off');
        
        ui.meta_on = uicontrol(... 
            'Parent', ui.panel7,... 
            'Style','togglebutton',...
            'String','Markers',...
            'Tag','zoom_on',...
            'Callback', @meta_Callback,...
            'Position', [3*buff+2*button_w, buff, button_w, button_h],...
            'Enable', 'off'); 
        %---------------------------------------------------------------                    
        ui.axes1 = axes(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Visible', 'off');
        ui.region1 = imagesc([]);
        set(ui.axes1,...
            'Position', axes_pos1,...
            'Xtick', [],...
            'Ytick', [],...
            'YDir','reverse',...
            'NextPlot', 'add');
        
        ui.axes2 = axes(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Visible', 'off');
        ui.region2 = imagesc([]);
        set(ui.axes2,...
            'Position', axes_pos2,...
            'Xtick', [],...
            'Ytick', [],...
            'YDir','reverse',...
            'NextPlot', 'add');
        
        ui.axes3 = axes(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Visible', 'off');
        ui.region3 = imagesc([]);
        set(ui.axes3,...
            'Position', axes_pos3,...
            'Xtick', [],...
            'Ytick', [],...
            'YDir','reverse',...
            'NextPlot', 'add');
        
        ui.axes4 = axes(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Visible', 'off');
        ui.region4 = imagesc([]);
        set(ui.axes4,...
            'Position', axes_pos4,...
            'Xtick', [],...
            'Ytick', [],...
            'YDir','reverse',...
            'NextPlot', 'add');
        
        linkaxes([ui.axes1 ui.axes3]);
        linkaxes([ui.axes2 ui.axes4]);
        
        ui.axes5 = axes(...
            'Parent', ui.main_fig,...
            'Units', 'pixels');
        ui.region5 = imagesc([]);
        set(ui.axes5,...
            'Xtick', [],...
            'Position', axes_pos5); 
        
        ui.axes6 = axes(...
            'Parent', ui.main_fig,...
            'Units', 'pixels');
        ui.region6 = imagesc([]);
        set(ui.axes6,...
            'Xtick', [],...
            'Position', axes_pos6); 
        
        
        set(ui.main_fig,...
             'Colormap', [jet(128); gray(128)]);
        
        ui.meta1 = plot(1, 1,...
            'Parent', ui.axes1,...
            'Visible', 'off',...
            'Marker', '.',...
            'MarkerEdgeColor', 'r',...
            'MarkerSize', 2,...
            'LineStyle', 'none');
        ui.meta2 = plot(1, 1,...
            'Parent', ui.axes2,...
            'Visible', 'off',...
            'Marker', '.',...
            'MarkerEdgeColor', 'r',...
            'MarkerSize', 2,...
            'LineStyle', 'none');
        ui.meta3 = plot(1, 1,...
            'Parent', ui.axes3,...
            'Visible', 'off',...
            'Marker', '.',...
            'MarkerEdgeColor', 'k',...
            'MarkerSize', 2,...
            'LineStyle', 'none');
        ui.meta4 = plot(1, 1,...
            'Parent', ui.axes4,...
            'Visible', 'off',...
            'Marker', '.',...
            'MarkerEdgeColor', 'k',...
            'MarkerSize', 2,...
            'LineStyle', 'none');
        
        
    end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Auxilliary functions that control data
%
%--------------------------------------------------------------------------

    function get_pair_information
        pair_list = [dir([map_dir '\*RCC*.mat']); dir([map_dir '\*RML*.mat'])];
        num_pairs = length(pair_list);
        if num_pairs
            curr_pair = 1;
            pair_strings = cell(num_pairs, 1);
            
            for ii = 1:num_pairs
                pair_strings{ii} = [pair_list(ii).name(1:3) ' ' pair_list(ii).name(5:6)];
            end
            pair_strings = sort(pair_strings);
            
            %Update uicontrols now we have data
            set(ui.pair_number_selecter,...
                'Enable', 'on',...
                'String', pair_strings);

            %Load in the images for the first pair and upfate the pair
            %selecter
            update_curr_pair;
            
            set(ui.zoom_on, 'Enable', 'on');
            set(ui.pan_on, 'Enable', 'on');
            set(ui.meta_on, 'Enable', 'on');
        else
            warndlg('No classification maps found in this directory');
        end
    end
%--------------------------------------------------------------------------       
    function load_mammograms
        h = waitbar(0,'Loading mammograms. Please wait...');
        
        %Work out the names of the associated mammograms
        mammo_name_l = dir([mammo_dir '\*' pair_num 'L' pair_view '*']);
        mammo_name_r = dir([mammo_dir '\*' pair_num 'R' pair_view '*']);
        mammo_name_l = [mammo_dir '\' mammo_name_l(1).name];
        mammo_name_r = [mammo_dir '\' mammo_name_r(1).name];
       
        %Load in the mammograms
        if strcmpi(mammo_name_r(end-3:end), '.mat')
            im1 = u_load(mammo_name_r);
        else
            im1 = imread(mammo_name_r);
        end
        if strcmpi(mammo_name_l(end-3:end), '.mat')
            im2 = u_load(mammo_name_l);
        else
            im2 = imread(mammo_name_l);
        end       
        
        %Now check for meta data (i.e. abnormality annotations)
        meta_lx = [];
        meta_rx = [];
        meta_ly = [];
        meta_ry = [];
        if exist([mammo_dir '\meta'], 'dir')
            meta_name_l = dir([mammo_dir '\meta\*' pair_num 'L' pair_view '*']);
            if ~isempty(meta_name_l)
                meta_l = u_load([mammo_dir '\meta\' meta_name_l(1).name]);
                if ~isempty(meta_l)
                    meta_lx = meta_l(:,1);
                    meta_ly = meta_l(:,2);
                end
            end
            meta_name_r = dir([mammo_dir '\meta\*' pair_num 'R' pair_view '*']);
            if ~isempty(meta_name_r)
                meta_r = u_load([mammo_dir '\meta\' meta_name_r(1).name]);
                if ~isempty(meta_r)
                    meta_rx = meta_r(:,1);
                    meta_ry = meta_r(:,2);
                end
            end    
        end
        close(h);
        
        update_mammo_axes_display;
    end
%--------------------------------------------------------------------------
    function load_maps
        
        h = waitbar(0,'Loading maps. Please wait...');

        map_name_r = [map_dir '\' map_names_r(1).name];
        map_name_l = [map_dir '\' map_names_l(1).name];
        
        %load in maps
        im3 = u_load(map_name_r);
        im4 = u_load(map_name_l);
        
        update_map_axes_display;
        
        close(h);
    end
%--------------------------------------------------------------------------
    function update_map_axes_display
        
        %Compute map limits for color scaling
        max_map = max([max(im3(:)) max(im4(:))]);
        map_lim = [0 2*max_map];
        
        set(ui.axes3, 'Clim', map_lim);
        set(ui.axes4, 'Clim', map_lim);
        set(ui.axes5,...
            'Clim', map_lim,...
            'XColor', 'red',...
            'YColor', 'red',...
            'Xtick', [],...
            'YTickLabel', num2str(linspace(0, max_map, length(get(ui.axes5, 'Ytick')))',3));
        
        %Make the maps visible
        set(ui.region3,...
            'Visible', 'on',...
            'CData', im3,...
            'XData', [1 axes_pos3(3)],...
            'YData', [1 axes_pos3(4)]);
        set(ui.region4,...
            'Visible', 'on',...
            'CData', im4,...
            'XData', [1 axes_pos4(3)],...
            'YData', [1 axes_pos4(4)]);
        set(ui.region5,...
            'Visible', 'on',...
            'CData', linspace(0, max_map, 128)',...
            'XData', [1 axes_pos5(3)],...
            'YData', [1 axes_pos5(4)]);
        
        set(ui.meta3,...
            'XData', axes_pos3(3)*meta_rx,...
            'YData', axes_pos3(4)*meta_ry);
        set(ui.meta4,...
            'XData', axes_pos4(3)*meta_lx,...
            'YData', axes_pos4(4)*meta_ly);
        
        set(ui.min_c_slider,...
            'Min', 0,...
            'Max', 0.99*max_map,...
            'Value', 0,...
            'Enable', 'on')
        set(ui.max_c_slider,...
            'Min', 0.01,...
            'Max', max_map,...
            'Value', max_map,...
            'Enable', 'on')
        
        set(ui.min_c_slider_text,...
            'String', ['Select min/max values of map contrast range: [0, ' num2str(max_map,3) ']']);
        
    end

    function update_mammo_axes_display
       
         %Compute the apsect ratios for these images (they may vary from
        %pair to pair)
        aspect_ratio_r = size(im1,2) / size(im1,1);
        aspect_ratio_l = size(im2,2) / size(im2,1);
        
        %Update the size and position of the axes
        axes_pos1(1) = axes_pos1(1) + axes_pos1(3) - axes_pos1(4)*aspect_ratio_r;
        axes_pos3(1) = axes_pos3(1) + axes_pos3(3) - axes_pos3(4)*aspect_ratio_r;
        axes_pos5(1) = axes_pos3(1) - 25;
        axes_pos6(1) = axes_pos1(1) - 25;
        
        axes_pos1(3) = axes_pos1(4)*aspect_ratio_r;
        axes_pos2(3) = axes_pos2(4)*aspect_ratio_l;
        axes_pos3(3) = axes_pos3(4)*aspect_ratio_r;
        axes_pos4(3) = axes_pos4(4)*aspect_ratio_l;
        
        
        set(ui.axes1,...
            'Position', axes_pos1,...
            'Xlim', [0.5 axes_pos1(3)+0.5],...
            'Ylim', [0.5 axes_pos1(4)+0.5]);
        set(ui.axes2,...
            'Position', axes_pos2,...
            'Xlim', [0.5 axes_pos2(3)+0.5],...
            'Ylim', [0.5 axes_pos2(4)+0.5]);
        set(ui.axes3,...
            'Position', axes_pos3,...
            'Xlim', [0.5 axes_pos3(3)+0.5],...
            'Ylim', [0.5 axes_pos3(4)+0.5]);
        set(ui.axes4,...
            'Position', axes_pos4,...
            'Xlim', [0.5 axes_pos4(3)+0.5],...
            'Ylim', [0.5 axes_pos4(4)+0.5]);
        set(ui.axes5,...
            'Position', axes_pos5,...
            'Xlim', [0.5 axes_pos5(3)+0.5],...
            'Ylim', [0.5 axes_pos5(4)+0.5]);
        set(ui.axes6,...
            'Position', axes_pos6,...
            'Xlim', [0.5 axes_pos6(3)+0.5],...
            'Ylim', [0.5 axes_pos6(4)+0.5]);
       
        %Compute mammo limits for color scaling
        max_mammo = double(max([max(im1(:)) max(im2(:))]));
        min_mammo = double(min([min(im1(:)) min(im2(:))]));
        mammo_lim = [2*min_mammo - max_mammo max_mammo];
        
        set(ui.axes1, 'Clim', mammo_lim);
        set(ui.axes2, 'Clim', mammo_lim);
        set(ui.axes6,...
            'Clim', mammo_lim,...
            'XColor', 'red',...
            'YColor', 'red',...
            'Xtick', [],...
            'YTickLabel', num2str(linspace(min_mammo, max_mammo, length(get(ui.axes6, 'Ytick')))',3));
        
        %Make the mammograms visible
        set(ui.region1,...
            'Visible', 'on',...
            'CData', im1,...
            'XData', [1 axes_pos1(3)],...
            'YData', [1 axes_pos1(4)]);
        set(ui.region2,...
            'Visible', 'on',...
            'CData', im2,...
            'XData', [1 axes_pos2(3)],...
            'YData', [1 axes_pos2(4)]);
        set(ui.region6,...
            'Visible', 'on',...
            'CData', linspace(min_mammo, max_mammo, 128)',...
            'XData', [1 axes_pos6(3)],...
            'YData', [1 axes_pos6(4)]);
        
        set(ui.meta1,...
            'XData', axes_pos1(3)*meta_rx,...
            'YData', axes_pos1(4)*meta_ry);
        set(ui.meta2,...
            'XData', axes_pos2(3)*meta_lx,...
            'YData', axes_pos2(4)*meta_ly);
        
        set(ui.min_m_slider,...
            'Min', 0,...
            'Max', 0.99*max_mammo,...
            'Value', 0,...
            'Enable', 'on')
        set(ui.max_m_slider,...
            'Min', 0.01,...
            'Max', max_mammo,...
            'Value', max_mammo,...
            'Enable', 'on')
        
        set(ui.min_m_slider_text,...
            'String', ['Select min/max values of mammo contrast range: [' num2str(min_mammo,3) ', ' num2str(max_mammo,3) ']']);
        
    end
%----------------------------------------------------------------------
    function update_curr_pair
        
        set(ui.pair_number_text, 'String', ['Select mammogram pair:' num2str(curr_pair) ' of ' num2str(num_pairs)]);
        set(ui.pair_number_selecter, 'Value', curr_pair);
        
        if curr_pair == num_pairs
            set(ui.next_pair, 'Enable', 'off');
        else
            set(ui.next_pair, 'Enable', 'on');
        end
        if curr_pair == 1
            set(ui.previous_pair, 'Enable', 'off');
        else
            set(ui.previous_pair, 'Enable', 'on');
        end

        %Work out the case number and view type for this pair of maps
        pair_num = pair_strings{curr_pair}(1:3);
        pair_view = pair_strings{curr_pair}(5:6);
        
        %Work out number of maps for this pair
        map_names_r = dir([map_dir '\*' pair_num 'R' pair_view '*.mat']);
        map_names_l = dir([map_dir '\*' pair_num 'L' pair_view '*.mat']);

        %Load in the maps and mammograms and update the display
        load_mammograms;
        load_maps;
    end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% UI Callbacks
%
%--------------------------------------------------------------------------
% --------------------------------------------------------------------
    function mammo_dir_select_Callback(hObject, eventdata) %#ok
    % Callback to...
        set(ui.mammo_dir_select, 'Enable', 'off');
        temp_dir = ...
            uigetdir(mammo_dir, 'Select the directory containing the mammograms');
        if temp_dir
            mammo_dir = temp_dir;
            set(ui.mammo_dir_box, 'string', mammo_dir);
        end
        set(ui.mammo_dir_select, 'Enable', 'on');
    end
%--------------------------------------------------------------------------
    function map_dir_select_Callback(hObject, eventdata) %#ok
    % Callback to...
        set(ui.map_dir_select, 'Enable', 'off');
        temp_dir = ...
            uigetdir(map_dir, 'Select the directory containing the organisation maps');
        if temp_dir
            map_dir = temp_dir;
            set(ui.map_dir_box, 'string', map_dir);
        end
        set(ui.map_dir_select, 'Enable', 'on');
    end
%--------------------------------------------------------------------------
    function update_Callback(hObject, eventdata) %#ok
    % Callback to...
        get_pair_information;
    end    
% --------------------------------------------------------------------
    function quit_Callback(hObject, eventdata) %#ok
    % Callback executed if the user tries to quit
        
        %Check if they're ok to quit
        delete(ui.main_fig);
    end

% --------------------------------------------------------------------
    function previous_pair_Callback(hObject, eventdata) %#ok
    % Callback to the "zoom" button allowing the user to zoom in/out the 
    % mammogram
        curr_pair = curr_pair - 1;
        update_curr_pair;
    end

% --------------------------------------------------------------------
    function next_pair_Callback(hObject, eventdata) %#ok
    % Callback to the "pan" button allowing the user to pan around the 
    % mammogram
        curr_pair = curr_pair + 1;
        update_curr_pair;
    end
% --------------------------------------------------------------------
    function pair_number_selecter_Callback(hObject, eventdata) %#ok
    % Callback...
        curr_pair = get(ui.pair_number_selecter, 'value');
        update_curr_pair;
    end
% --------------------------------------------------------------------
    function min_c_slider_Callback(hObject, eventdata) %#ok
    % Callback...
        min_slider = get(ui.min_c_slider, 'value');
        max_slider = max(min_slider+0.01, get(ui.max_c_slider, 'value'));
        
        set(ui.max_c_slider, 'value', max_slider);
        
        new_max_c = 2*max_slider - min_slider;
        new_min_c = min_slider;
        
        %Compute map limits for color scaling
        map_lim = [new_min_c new_max_c];
        
        %Compute mammo limits for color scaling
        set(ui.axes3, 'Clim', map_lim);
        set(ui.axes4, 'Clim', map_lim);
        
        set(ui.axes5,...
            'YTickLabel', num2str(linspace(min_slider, max_slider, length(get(ui.axes5, 'Ytick')))',3));
        %
        set(ui.min_c_slider_text,...
            'String', ['Select min/max value of map contrast range: [' num2str(min_slider,3) ', ' num2str(max_slider,3) ']']);
    end
% --------------------------------------------------------------------
    function max_c_slider_Callback(hObject, eventdata) %#ok
    % Callback...
        max_slider = get(ui.max_c_slider, 'value');
        min_slider = min(max_slider-0.01, get(ui.min_c_slider, 'value'));
        
        set(ui.min_c_slider, 'value', min_slider);
        
        new_max_c = 2*max_slider - min_slider;
        new_min_c = min_slider;
        
        %Compute map limits for color scaling
        map_lim = [new_min_c new_max_c];
        
        %Compute mammo limits for color scaling
        set(ui.axes3, 'Clim', map_lim);
        set(ui.axes4, 'Clim', map_lim);
        
        set(ui.axes5,...
            'YTickLabel', num2str(linspace(min_slider, max_slider, length(get(ui.axes5, 'Ytick')))',3));
        %
        set(ui.min_c_slider_text,...
            'String', ['Select min/max value of map contrast range: [' num2str(min_slider,3) ', ' num2str(max_slider,3) ']']);
    end
% --------------------------------------------------------------------
    function min_m_slider_Callback(hObject, eventdata) %#ok
    % Callback...
        min_slider = get(ui.min_m_slider, 'value');
        max_slider = max(min_slider+0.01, get(ui.max_m_slider, 'value'));
        
        set(ui.max_m_slider, 'value', max_slider);
        
        new_max_m = max_slider;
        new_min_m = 2*min_slider - max_slider;
        
        %Compute mammo limits for color scaling
        mammo_lim = [new_min_m new_max_m];
        
        %Compute mammo limits for color scaling
        set(ui.axes1, 'Clim', mammo_lim);
        set(ui.axes2, 'Clim', mammo_lim);
        
        set(ui.axes6,...
            'YTickLabel', num2str(linspace(min_slider, max_slider, length(get(ui.axes6, 'Ytick')))',3));
        
        %
        set(ui.min_m_slider_text,...
            'String', ['Select min/max value of mammogram contrast range: [' num2str(min_slider,3) ', ' num2str(max_slider,3) ']']);
    end
% --------------------------------------------------------------------
    function max_m_slider_Callback(hObject, eventdata) %#ok
    % Callback...
        max_slider = get(ui.max_m_slider, 'value');
        min_slider = min(max_slider-0.01, get(ui.min_m_slider, 'value'));
        
        set(ui.min_m_slider, 'value', min_slider);
        
        new_max_m = max_slider;
        new_min_m = 2*min_slider - max_slider;
        
        %Compute mammo limits for color scaling
        mammo_lim = [new_min_m new_max_m];
        
        %Compute mammo limits for color scaling
        set(ui.axes1, 'Clim', mammo_lim);
        set(ui.axes2, 'Clim', mammo_lim);
        
        set(ui.axes6,...
            'YTickLabel', num2str(linspace(min_slider, max_slider, length(get(ui.axes6, 'Ytick')))',3));
        
        %
        set(ui.min_m_slider_text,...
            'String', ['Select min/max value of mammogram contrast range: [' num2str(min_slider,3) ', ' num2str(max_slider,3) ']']);
    end
% --------------------------------------------------------------------
    function zoom_Callback(hObject, eventdata) %#ok
    % Callback to the "Zoom" button on the main control panel, allowing the
    % user to zoom in/out of any of 3 ROI figures (zooming occurs
    % simultaneously in all 3 figures)
        if get(ui.zoom_on, 'Value')
            set(ui.pan_on, 'Value', 0);
            axes(ui.axes1); zoom on;
            axes(ui.axes2); zoom on;
            axes(ui.axes3); zoom on;
            axes(ui.axes4); zoom on;
          
        else
            axes(ui.axes1); zoom off;
            axes(ui.axes2); zoom off;
            axes(ui.axes3); zoom off;
            axes(ui.axes4); zoom off;
        end
    end

    % --------------------------------------------------------------------
    function pan_Callback(hObject, eventdata) %#ok
    % Callback to the "Pan" button on the main control panel, allowing the
    % user to pan around any of 3 ROI figures (panning occurs
    % simultaneously in all 3 figures)
        if get(ui.pan_on, 'Value')
            set(ui.zoom_on, 'Value', 0);
            axes(ui.axes1); pan on;
            axes(ui.axes2); pan on;
            axes(ui.axes3); pan on;
            axes(ui.axes4); pan on;
          
        else
            axes(ui.axes1); pan off;
            axes(ui.axes2); pan off;
            axes(ui.axes3); pan off;
            axes(ui.axes4); pan off;
        end
    end
% --------------------------------------------------------------------
    function meta_Callback(hObject, eventdata) %#ok
    % Callback to the "Pan" button on the main control panel, allowing the
    % user to pan around any of 3 ROI figures (panning occurs
    % simultaneously in all 3 figures)
        if get(ui.meta_on, 'Value')
            set(ui.meta1, 'visible', 'on');
            set(ui.meta2, 'visible', 'on');
            set(ui.meta3, 'visible', 'on');
            set(ui.meta4, 'visible', 'on');
          
        else
            set(ui.meta1, 'visible', 'off');
            set(ui.meta2, 'visible', 'off');
            set(ui.meta3, 'visible', 'off');
            set(ui.meta4, 'visible', 'off');
        end
    end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%---------------------- END OF FUNCTION -----------------------------------
%--------------------------------------------------------------------------
end