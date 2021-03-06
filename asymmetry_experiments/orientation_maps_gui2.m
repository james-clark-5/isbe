function [] = orientation_maps_gui2()
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
warning('off', 'load_uint8:missing_variables');

%Set constants/variables that persist for all user sessions:
color1 = [1 1 1];
color2 = [212 208 200]/255; %#ok
color3 = [0 0 0];
buff = 5;
screen_size = get(0,'ScreenSize');

%Create empty variables that exist globally and will be filled auxilliary
%functions - this set do not need to be reset for each session
if strcmpi(getenv('UserName'), 'mberks')
    image_dir = 'C:\isbe\asymmetry_project\data\mammograms\2004_screening_processed\mass_roi\';
    ori_dir = 'C:\isbe\asymmetry_project\data\orientation_maps\2004_screening\mass_roi\';
else
    image_dir = 'E:\asymmetry_project\data\mammograms\2004_screening_processed\mass_roi\';
    ori_dir = 'E:\asymmetry_project\data\orientation_maps\2004_screening\mass_roi\';
end


num_images = [];
image_strings = [];
curr_image = [];
curr_smoothing = 0;
image_names = [];
ori_names = [];

ui = [];
axes_pos1 = [];
axes_pos6 = [];
panel_pos = [];

im = [];
im_ori = [];

meta_x = [];
meta_y = [];

num_angles = 36;
ang_res = 180 / num_angles;
arrow_colors = hsv(num_angles);

%main program
create_main_fig
%get_image_information;

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
            'Name', 'Mammogram maps display tool',...
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
        panel_h = 65;
 
        
        figure(ui.main_fig);
        set(ui.main_fig,...
            'Color', color3,...
            'CloseRequestFcn', @quit_Callback);
        
        panel_w = 400;
        axes_h = (y_max - 3*buff);
        axes_w = axes_h;
        
        axes_pos1 = [x_max-panel_w-2*buff-axes_w  buff axes_w axes_h];
        axes_pos6 = [axes_pos1(1)-25 axes_pos1(2) 20 axes_pos1(4)];
        panel_pos = [x_max-panel_w-buff, buff, panel_w, y_max - 2*buff];
        
        ui.panel_main = uicontrol(...
            'Style','frame',...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', panel_pos,...
            'Visible', 'on');
        
        %------------------------------------------------------------------
        pp = 1;
        ui.panel{pp} = uipanel(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', [panel_pos(1)+buff y_max-buff-panel_h panel_w-2*buff panel_h],...
            'Visible', 'on');
        
        ui.image_dir_text = uicontrol(... 
            'Parent', ui.panel{pp},... 
            'Style','text',...
            'BackgroundColor', get(ui.panel_main, 'BackgroundColor'),...
            'FontName', 'Arial',...
            'String', 'Mammogram images folder:',...
            'HorizontalAlignment', 'left',...
            'Position', [0 button_h text_w 25]); 

        ui.image_dir_box = uicontrol(...
            'Style', 'edit',...
            'Position', [buff buff text_w button_h],...
            'BackgroundColor', [1 1 1],...
            'Parent', ui.panel{pp},...
            'String', image_dir);

        ui.image_dir_select = uicontrol(... 
            'Style', 'pushbutton',...
            'Position', [2*buff+text_w buff button_w button_h],...
            'String', 'Select',...
            'Parent', ui.panel{pp},...
            'Callback', @image_dir_select_Callback);
        pp = pp + 1;
        
%         %---------------------------------------------------------------
%         ui.panel{pp} = uipanel(...
%             'Parent', ui.main_fig,...
%             'Units', 'pixels',...
%             'Position', [panel_pos(1)+buff y_max-pp*(buff+panel_h) panel_w-2*buff panel_h],...
%             'Visible', 'on');
%           
%         ui.map_dir_text = uicontrol(... 
%             'Parent', ui.panel{pp},... 
%             'Style','text',...
%             'BackgroundColor', get(ui.panel_main, 'BackgroundColor'),...
%             'FontName', 'Arial',...
%             'String', 'Line maps folder:',...
%             'HorizontalAlignment', 'left',...
%             'Position', [0 button_h text_w 25]); 
% 
%         ui.map_dir_box = uicontrol(...
%             'Style', 'edit',...
%             'Position', [buff buff text_w button_h],...
%             'BackgroundColor', [1 1 1],...
%             'Parent', ui.panel{pp},...
%             'String', map_dir);
% 
%         ui.map_dir_select = uicontrol(... 
%             'Style', 'pushbutton',...
%             'Position', [2*buff+text_w buff button_w button_h],...
%             'String', 'Select',...
%             'Parent', ui.panel{pp},...
%             'Callback', @map_dir_select_Callback);
%          pp = pp + 1;
         
         %---------------------------------------------------------------
        ui.panel{pp} = uipanel(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', [panel_pos(1)+buff y_max-pp*(buff+panel_h) panel_w-2*buff panel_h],...
            'Visible', 'on');
        ui.ori_dir_text = uicontrol(... 
            'Parent', ui.panel{pp},... 
            'Style','text',...
            'BackgroundColor', get(ui.panel_main, 'BackgroundColor'),...
            'FontName', 'Arial',...
            'String', 'Orientation maps folder:',...
            'HorizontalAlignment', 'left',...
            'Position', [0 button_h text_w 25]); 

        ui.ori_dir_box = uicontrol(...
            'Style', 'edit',...
            'Position', [buff buff text_w button_h],...
            'BackgroundColor', [1 1 1],...
            'Parent', ui.panel{pp},...
            'String', ori_dir);

        ui.ori_dir_select = uicontrol(... 
            'Style', 'pushbutton',...
            'Position', [2*buff+text_w buff button_w button_h],...
            'String', 'Select',...
            'Parent', ui.panel{pp},...
            'Callback', @ori_dir_select_Callback);
        pp = pp + 1;
           
        %---------------------------------------------------------------
        ui.panel{pp} = uipanel(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', [panel_pos(1)+buff y_max-pp*(buff+panel_h) panel_w-2*buff panel_h],...
            'Visible', 'on');
           
        ui.update = uicontrol(... 
            'Parent', ui.panel{pp},... 
            'Style','pushbutton',...
            'String','Update data source',...
            'Tag','update',...
            'Callback', @update_Callback,...
            'Position', [buff, panel_h-buff-button_h, text_w, button_h]);
        pp = pp + 1;
        
        %---------------------------------------------------------------
        ui.panel{pp} = uipanel(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', [panel_pos(1)+buff y_max-pp*(buff+panel_h) panel_w-2*buff panel_h],...
            'Visible', 'on');
        
        ui.image_number_text = uicontrol(... 
            'Parent', ui.panel{pp},... 
            'Style','text',...
            'BackgroundColor', get(ui.panel_main, 'BackgroundColor'),...
            'FontName', 'Arial',...
            'String', 'Select imagegram image:',...
            'HorizontalAlignment', 'left',...
            'Position', [0 button_h+buff text_w 25]); 
        
        ui.image_number_selecter = uicontrol(...
            'Parent', ui.panel{pp},...
            'Style', 'popupmenu',...
            'Position', [2*buff+button_w buff text_w-buff-button_w button_h],...
            'String', ' ',...
            'Enable', 'off',...
            'Callback', @image_number_selecter_Callback);
        
        ui.previous_image = uicontrol(...
            'Parent', ui.panel{pp},...
            'Style','pushbutton',...
            'String','Previous',...
            'Callback', @previous_image_Callback,...
            'Position', [buff, buff, button_w, button_h],....
            'Enable', 'off');
        ui.next_image = uicontrol(...
            'Parent', ui.panel{pp},...
            'Style','pushbutton',...
            'String','Next',...
            'Callback', @next_image_Callback,...
            'Position', [2*buff+text_w, buff, button_w, button_h],...
            'BackgroundColor', color2,...
            'Enable', 'off');
        pp = pp + 1;
        
        %---------------------------------------------------------------
        ui.panel{pp} = uipanel(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', [panel_pos(1)+buff y_max-pp*(buff+panel_h) panel_w-2*buff panel_h],...
            'Visible', 'on');
        
        ui.smoothing_slider_text = uicontrol(... 
            'Parent', ui.panel{pp},... 
            'Style','text',...
            'BackgroundColor', get(ui.panel_main, 'BackgroundColor'),...
            'FontName', 'Arial',...
            'String', 'Select map smoothing: sigma = 0' ,...
            'HorizontalAlignment', 'left',...
            'Position', [0 25 text_w 25]); 
        
        ui.smoothing_slider = uicontrol(... 
            'Style', 'slider',...
            'Position', [buff buff text_w+button_w+buff 25],...
            'String', 'Select',...
            'Min', 0,...
            'Max', 6,...
            'Value', 0,...
            'SliderStep', [1/6 1/6],...
            'Parent', ui.panel{pp},...
            'Enable', 'off',...
            'Callback', @smoothing_slider_Callback);
        pp = pp + 1;
%         %---------------------------------------------------------------
%         ui.panel{pp} = uipanel(...
%             'Parent', ui.main_fig,...
%             'Units', 'pixels',...
%             'Position', [panel_pos(1)+buff y_max-pp*(buff+panel_h) panel_w-2*buff panel_h],...
%             'Visible', 'on');
%         
%         ui.thresh_slider_text = uicontrol(... 
%             'Parent', ui.panel{pp},... 
%             'Style','text',...
%             'BackgroundColor', get(ui.panel_main, 'BackgroundColor'),...
%             'FontName', 'Arial',...
%             'String', 'Select orientation display threshold: 0.5' ,...
%             'HorizontalAlignment', 'left',...
%             'Position', [0 25 text_w 25]); 
%         
%         ui.thresh_slider = uicontrol(... 
%             'Style', 'slider',...
%             'Position', [buff buff text_w+button_w+buff 25],...
%             'String', 'Select',...
%             'Min', 0,...
%             'Max', 1,...
%             'Value', 0.5,...
%             'SliderStep', [0.1 0.01],...
%             'Parent', ui.panel{pp},...
%             'Enable', 'off',...
%             'Callback', @thresh_slider_Callback);
%         pp = pp + 1;
        
%         %---------------------------------------------------------------
%         ui.panel{pp} = uipanel(...
%             'Parent', ui.main_fig,...
%             'Units', 'pixels',...
%             'Position', [panel_pos(1)+buff y_max-pp*(buff+panel_h) panel_w-2*buff panel_h],...
%             'Visible', 'on');
%         
%         ui.min_c_slider_text = uicontrol(... 
%             'Parent', ui.panel{pp},... 
%             'Style','text',...
%             'BackgroundColor', get(ui.panel_main, 'BackgroundColor'),...
%             'FontName', 'Arial',...
%             'String', 'Select min/max values of map contrast range: ' ,...
%             'HorizontalAlignment', 'left',...
%             'Position', [0 25 text_w+button_w+buff 25]); 
%         
%         ui.min_c_slider = uicontrol(... 
%             'Style', 'slider',...
%             'Position', [buff buff (text_w+button_w)/2 25],...
%             'String', 'Select',...
%             'Min', 0,...
%             'Max', 1,...
%             'Value', 0,...
%             'SliderStep', [0.01 0.1],...
%             'Parent', ui.panel{pp},...
%             'Enable', 'off',...
%             'Callback', @min_c_slider_Callback);
%         
%         ui.max_c_slider = uicontrol(... 
%             'Style', 'slider',...
%             'Position', [2*buff+(text_w+button_w)/2 buff (text_w+button_w)/2 25],...
%             'String', 'Select',...
%             'Min', 0,...
%             'Max', 1,...
%             'Value', 0,...
%             'SliderStep', [0.01 0.1],...
%             'Parent', ui.panel{pp},...
%             'Enable', 'off',...
%             'Callback', @max_c_slider_Callback);
%         pp = pp + 1;
        
        %---------------------------------------------------------------
        ui.panel{pp} = uipanel(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', [panel_pos(1)+buff y_max-pp*(buff+panel_h) panel_w-2*buff panel_h],...
            'Visible', 'on');
        
        ui.min_m_slider_text = uicontrol(... 
            'Parent', ui.panel{pp},... 
            'Style','text',...
            'BackgroundColor', get(ui.panel_main, 'BackgroundColor'),...
            'FontName', 'Arial',...
            'String', 'Select min/max values of imagegram contrast range: ' ,...
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
            'Parent', ui.panel{pp},...
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
            'Parent', ui.panel{pp},...
            'Enable', 'off',...
            'Callback', @max_m_slider_Callback);
        pp = pp + 1;
        
        %---------------------------------------------------------------
        ui.panel{pp} = uipanel(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', [panel_pos(1)+buff y_max-pp*(buff+panel_h) panel_w-2*buff panel_h],...
            'Visible', 'on');
        
        ui.zoom_on = uicontrol(... 
            'Parent', ui.panel{pp},... 
            'Style','togglebutton',...
            'String','Zoom',...
            'Tag','zoom_on',...
            'Callback', @zoom_Callback,...
            'Position', [buff, buff, button_w, button_h],...
            'Enable', 'off'); 
        
        ui.pan_on = uicontrol(... 
            'Parent', ui.panel{pp},... 
            'Style','togglebutton',...
            'String','Pan',...
            'Tag','zoom_on',...
            'Callback', @pan_Callback,...
            'Position', [2*buff+button_w, buff, button_w, button_h],...
            'Enable', 'off');
        
        ui.meta_on = uicontrol(... 
            'Parent', ui.panel{pp},... 
            'Style','togglebutton',...
            'String','Markers',...
            'Tag','zoom_on',...
            'Callback', @meta_Callback,...
            'Position', [3*buff+2*button_w, buff, button_w, button_h],...
            'Enable', 'off');
        
        pp = pp + 1;
        %---------------------------------------------------------------
        ui.panel{pp} = uipanel(...
            'Parent', ui.main_fig,...
            'Units', 'pixels',...
            'Position', [panel_pos(1)+buff y_max-pp*(buff+panel_h) panel_w-2*buff panel_h],...
            'Visible', 'on');
        
        ui.draw_line = uicontrol(... 
            'Parent', ui.panel{pp},... 
            'Style','pushbutton',...
            'String','Draw new line',...
            'Tag','draw_line',...
            'Callback', @draw_line_Callback,...
            'Position', [buff, buff, button_w, button_h],...
            'Enable', 'off');
         ui.arrows_on = uicontrol(... 
            'Parent', ui.panel{pp},... 
            'Style','togglebutton',...
            'String','Arrows',...
            'Tag','arrows',...
            'Callback', @arrows_Callback,...
            'Position', [2*buff+button_w, buff, button_w, button_h],...
            'Enable', 'off'); 
         ui.lines_on = uicontrol(... 
            'Parent', ui.panel{pp},... 
            'Style','togglebutton',...
            'String','Lines',...
            'Tag','lines',...
            'Callback', @lines_Callback,...
            'Position', [3*buff+2*button_w, buff, button_w, button_h],...
            'Enable', 'off'); 
        %pp = pp + 1;
        %---------------------------------------------------------------
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
        
        ui.axes6 = axes(...
            'Parent', ui.main_fig,...
            'Units', 'pixels');
        ui.region6 = imagesc([]);
        set(ui.axes6,...
            'Xtick', [],...
            'Position', axes_pos6); 
        
        
        set(ui.main_fig,...
             'Colormap', gray(256));
        
        ui.arrows = zeros(num_angles,1);
        ui.lines = 0;
        ui.meta = plot(1, 1,...
            'Parent', ui.axes1,...
            'Visible', 'off',...
            'Marker', '.',...
            'MarkerEdgeColor', 'r',...
            'MarkerSize', 2,...
            'LineStyle', 'none');
        
    end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Auxilliary functions that control data
%
%--------------------------------------------------------------------------

    function get_image_information
        ori_list = dir([ori_dir '\*.mat']);
        image_list = dir([image_dir '\*.mat']);
        
        [ori_names image_names image_strings] =...
            match_generic_names(ori_list, image_list);
    
        num_images = length(ori_names);
        
        if num_images
            curr_image = 1;
            
            %Update uicontrols now we have data
            set(ui.image_number_selecter,...
                'Enable', 'on',...
                'String', image_strings);

            %Load in the images for the first image and update the image
            %selecter
            update_curr_image;
            
            set(ui.zoom_on, 'Enable', 'on');
            set(ui.pan_on, 'Enable', 'on');
            set(ui.meta_on, 'Enable', 'on');
            set(ui.arrows_on, 'Enable', 'on', 'Value', 1);
            set(ui.lines_on, 'Enable', 'on', 'Value', 1);
            set(ui.draw_line, 'Enable', 'on');
            %set(ui.smoothing_slider, 'Enable', 'on');
        else
            warndlg('No images found in this directory');
        end        
    end
%--------------------------------------------------------------------------       
    function load_images
        h = waitbar(0,'Loading images. Please wait...');
        
        %Load the images
        im = load_uint8([image_dir filesep image_names{curr_image}]);
        im_ori = load_uint8([ori_dir filesep ori_names{curr_image}]);
        im_ori = mod(im_ori-1,180)+1;
        
        %Reset the arrows
        if any(ui.arrows);
            delete(ui.arrows);
        end
        for ii = 1:num_angles
            ui.arrows(ii) = quiver(1,1,1,1,...
                'Parent', ui.axes1,...
                'Color', arrow_colors(ii,:),...
                'HitTest', 'off',...
                'ShowArrowHead', 'off',...
                'Autoscale', 'off',...
                'Visible', 'off');
        end
        
        %Reset the lines
        if ui.lines
            delete(ui.lines);
        end
        ui.lines = plot(1, 1,...
            'Parent', ui.axes1,...
            'Visible', 'off');
        
        %Now check for meta data (i.e. abnormality annotations)
        meta_x = [];
        meta_y = [];
        if exist([image_dir '\meta'], 'dir')
            meta_name = dir([image_dir '\meta\*' image_strings{curr_image} '*']);
            if ~isempty(meta_name)
                meta_xy = u_load([image_dir '\meta\' meta_name(1).name]);
                if ~isempty(meta_xy)
                    meta_x = meta_xy(:,1);
                    meta_y = meta_xy(:,2);
                end
            end
        end
        close(h);
        
        update_image_axes_display;
    end
%--------------------------------------------------------------------------
    function update_image_axes_display
        
        %Compute the apsect ratios for these images (they may vary from
        %image to image)
        aspect_ratio = size(im,2) / size(im,1);
        
        %Update the size and position of the axes
        axes_pos1(1) = axes_pos1(1) + axes_pos1(3) - axes_pos1(4)*aspect_ratio;
        axes_pos6(1) = axes_pos1(1) - 25;
        
        set(ui.axes1,...
            'Position', axes_pos1,...
            'Xlim', [0.5 axes_pos1(3)+0.5],...
            'Ylim', [0.5 axes_pos1(4)+0.5]);
        set(ui.axes6,...
            'Position', axes_pos6,...
            'Xlim', [0.5 axes_pos6(3)+0.5],...
            'Ylim', [0.5 axes_pos6(4)+0.5]);
       
        %Compute image limits for color scaling
        max_image = double(max(im(:)));
        min_image = double(min(im(:)));
        image_lim = [min_image max_image];
        
        set(ui.axes1, 'Clim', image_lim);
        set(ui.axes6,...
            'Clim', image_lim,...
            'XColor', 'red',...
            'YColor', 'red',...
            'Xtick', [],...
            'YTickLabel', num2str(linspace(min_image, max_image, length(get(ui.axes6, 'Ytick')))',3));
        
        %Make the imagegrams visible
        set(ui.region1,...
            'Visible', 'on',...
            'CData', im,...
            'XData', [1 axes_pos1(3)],...
            'YData', [1 axes_pos1(4)]);
        set(ui.region6,...
            'Visible', 'on',...
            'CData', linspace(min_image, max_image, 256)',...
            'XData', [1 axes_pos6(3)],...
            'YData', [1 axes_pos6(4)]);
        
        if ~isempty(meta_x)
            set(ui.meta,...
                'XData', axes_pos1(3)*meta_x,...
                'YData', axes_pos1(4)*meta_y);
        end
        
        set(ui.min_m_slider,...
            'Min', min_image,...
            'Max', 0.99*max_image,...
            'Value', min_image,...
            'Enable', 'on')
        set(ui.max_m_slider,...
            'Min', 1.01*min_image,...
            'Max', max_image,...
            'Value', max_image,...
            'Enable', 'on')
        
        im = [];
        
        set(ui.min_m_slider_text,...
            'String', ['Select min/max values of image contrast range: [' num2str(min_image,3) ', ' num2str(max_image,3) ']']);
        
    end
%----------------------------------------------------------------------
    function update_curr_image
        
        set(ui.image_number_text, 'String', ['Select image:' num2str(curr_image) ' of ' num2str(num_images)]);
        set(ui.image_number_selecter, 'Value', curr_image);
        
        if curr_image == num_images
            set(ui.next_image, 'Enable', 'off');
        else
            set(ui.next_image, 'Enable', 'on');
        end
        if curr_image == 1
            set(ui.previous_image, 'Enable', 'off');
        else
            set(ui.previous_image, 'Enable', 'on');
        end

        %Load in the maps and imagegrams and update the display
        load_images;
    end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% UI Callbacks
%
%--------------------------------------------------------------------------
%--------------------------------------------------------------------
    function image_dir_select_Callback(hObject, eventdata) %#ok
    % Callback to...
        set(ui.image_dir_select, 'Enable', 'off');
        temp_dir = ...
            uigetdir(image_dir, 'Select the directory containing the imagegrams');
        if temp_dir
            image_dir = temp_dir;
            set(ui.image_dir_box, 'string', image_dir);
        end
        set(ui.image_dir_select, 'Enable', 'on');
    end

%--------------------------------------------------------------------------
    function ori_dir_select_Callback(hObject, eventdata) %#ok
    % Callback to...
        set(ui.ori_dir_select, 'Enable', 'off');
        temp_dir = ...
            uigetdir(ori_dir, 'Select the directory containing the orientation maps');
        if temp_dir
            ori_dir = temp_dir;
            set(ui.ori_dir_box, 'string', ori_dir);
        end
        set(ui.ori_dir_select, 'Enable', 'on');
    end
%--------------------------------------------------------------------------
    function update_Callback(hObject, eventdata) %#ok
    % Callback to...
        get_image_information;
    end    
% --------------------------------------------------------------------
    function quit_Callback(hObject, eventdata) %#ok
    % Callback executed if the user tries to quit
        
        %Check if they're ok to quit
        delete(ui.main_fig);
    end

% --------------------------------------------------------------------
    function smoothing_slider_Callback(hObject, eventdata) %#ok
    % Callback...
        h = waitbar(0,'Smoothing image. Please wait...');
        curr_smoothing = get(ui.smoothing_slider, 'value');
        set(ui.smoothing_slider_text, 'String', ['Select map smoothing: sigma = ' num2str(curr_smoothing,1)]);
        update_image_axes_display;
        close(h);
    end

% --------------------------------------------------------------------
    function previous_image_Callback(hObject, eventdata) %#ok
    % Callback to the "zoom" button allowing the user to zoom in/out the 
    % imagegram
        curr_image = curr_image - 1;
        update_curr_image;
    end

% --------------------------------------------------------------------
    function next_image_Callback(hObject, eventdata) %#ok
    % Callback to the "pan" button allowing the user to pan around the 
    % imagegram
        curr_image = curr_image + 1;
        update_curr_image;
    end
% --------------------------------------------------------------------
    function image_number_selecter_Callback(hObject, eventdata) %#ok
    % Callback...
        curr_image = get(ui.image_number_selecter, 'value');
        update_curr_image;
    end
% --------------------------------------------------------------------
    function min_m_slider_Callback(hObject, eventdata) %#ok
    % Callback...
        min_slider = get(ui.min_m_slider, 'value');
        max_slider = max(min_slider+0.01, get(ui.max_m_slider, 'value'));
        
        set(ui.max_m_slider, 'value', max_slider);
        
        %Compute image limits for color scaling
        image_lim = [min_slider max_slider];
        
        %Compute image limits for color scaling
        set(ui.axes1, 'Clim', image_lim);
        
        set(ui.axes6,...
            'YTickLabel', num2str(linspace(min_slider, max_slider, length(get(ui.axes6, 'Ytick')))',3));
        
        %
        set(ui.min_m_slider_text,...
            'String', ['Select min/max value of image contrast range: [' num2str(min_slider,3) ', ' num2str(max_slider,3) ']']);
    end
% --------------------------------------------------------------------
    function max_m_slider_Callback(hObject, eventdata) %#ok
    % Callback...
        max_slider = get(ui.max_m_slider, 'value');
        min_slider = min(max_slider-0.01, get(ui.min_m_slider, 'value'));
        
        set(ui.min_m_slider, 'value', min_slider);
        
        %Compute image limits for color scaling
        image_lim = [min_slider max_slider];
        
        %Compute image limits for color scaling
        set(ui.axes1, 'Clim', image_lim);
        
        set(ui.axes6,...
            'YTickLabel', num2str(linspace(min_slider, max_slider, length(get(ui.axes6, 'Ytick')))',3));
        
        %
        set(ui.min_m_slider_text,...
            'String', ['Select min/max value of image contrast range: [' num2str(min_slider,3) ', ' num2str(max_slider,3) ']']);
    end
% --------------------------------------------------------------------
    function zoom_Callback(hObject, eventdata) %#ok
    % Callback to the "Zoom" button on the main control panel, allowing the
    % user to zoom in/out of any of 3 ROI figures (zooming occurs
    % simultaneously in all 3 figures)
        if get(ui.zoom_on, 'Value')
            set(ui.pan_on, 'Value', 0);
            axes(ui.axes1); zoom on;
        else
            axes(ui.axes1); zoom off;
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
          
        else
            axes(ui.axes1); pan off;
        end
    end
% --------------------------------------------------------------------
    function meta_Callback(hObject, eventdata) %#ok
    % Callback to the "Pan" button on the main control panel, allowing the
    % user to pan around any of 3 ROI figures (panning occurs
    % simultaneously in all 3 figures)
        if get(ui.meta_on, 'Value')
            set(ui.meta, 'visible', 'on'); 
        else
            set(ui.meta, 'visible', 'off');
        end
    end
% --------------------------------------------------------------------
    function arrows_Callback(hObject, eventdata) %#ok
    % Callback to the "Pan" button on the main control panel, allowing the
    % user to pan around any of 3 ROI figures (panning occurs
    % simultaneously in all 3 figures)
        if get(ui.arrows_on, 'Value')
            set(ui.arrows, 'visible', 'on'); 
        else
            set(ui.arrows, 'visible', 'off');
        end
    end
% --------------------------------------------------------------------
    function lines_Callback(hObject, eventdata) %#ok
    % Callback to the "Pan" button on the main control panel, allowing the
    % user to pan around any of 3 ROI figures (panning occurs
    % simultaneously in all 3 figures)
        if get(ui.lines_on, 'Value')
            set(ui.lines, 'visible', 'on'); 
        else
            set(ui.lines, 'visible', 'off');
        end
    end
% --------------------------------------------------------------------
    function draw_line_Callback(hObject, eventdata) %#ok
    % Callback to the "Pan" button on the main control panel, allowing the
    % user to pan around any of 3 ROI figures (panning occurs
    % simultaneously in all 3 figures)
    
        axes(ui.axes1);
        if get(ui.zoom_on, 'Value')
            set(ui.zoom_on, 'Value', 0);
            zoom off;
        end
        if get(ui.pan_on, 'Value')
            set(ui.pan_on, 'Value', 0);
            pan off;
        end
        if ~get(ui.arrows_on, 'Value')
            set(ui.arrows_on, 'Value', 1)
            set(ui.arrows, 'visible', 'on');
        end
        if ~get(ui.lines_on, 'Value')
            set(ui.lines_on, 'value', 1);
            set(ui.lines, 'visible', 'on');
        end

        %Draw line on image and get positions of segments
        [xi,yi,P] = impixel; %#ok

        %Rescale positions to size of image (previously in scale of axes)
        [rows cols] = size(im_ori);
        xi_im = cols * xi / axes_pos1(3);
        yi_im = rows * yi / axes_pos1(4);
        
        %Plot the coloured line segments
        for ii = 1:length(xi)-1

            rad = atan((yi_im(ii)-yi_im(ii+1)) / (xi_im(ii+1)-xi_im(ii)));
            deg = mod(180*rad/pi - 1,180) + 1;
            color_idx = ceil(deg * num_angles / 180 );

            ui.lines(end+1,1) = ...
                plot(xi(ii:ii+1), yi(ii:ii+1), '--', 'color', arrow_colors(color_idx,:));

        end
    
        %Get the orientation estimates along the plotted
        [px py ori_estimates] = improfile(im_ori,xi_im,yi_im);
        
        %Only keep every 4th point
        px = px(1:4:end);
        py = py(1:4:end);
        ori_estimates = ori_estimates(1:4:end);
        
        %Workout u/v vectors for arrows
        qx = 8*cos(pi*ori_estimates/180);
        qy = 8*-sin(pi*ori_estimates/180);
        
        %Loop through each angle color plotting the estimated orientation quivers
        for ii = 1:num_angles
            theta = (ii - 0.5)*ang_res;
            
            %Get mask of pixels that have orientation within theta range
            angle_idx = (ori_estimates > theta - 0.5*ang_res) &...
                         (ori_estimates <= theta + 0.5*ang_res);         
                     
            if any(angle_idx)         
                x_old = get(ui.arrows(ii), 'Xdata');
                y_old = get(ui.arrows(ii), 'Ydata');
                u_old = get(ui.arrows(ii), 'Udata');
                v_old = get(ui.arrows(ii), 'Vdata');

                set(ui.arrows(ii),...
                    'Xdata', [x_old; axes_pos1(3) * px(angle_idx) / rows; axes_pos1(3) * px(angle_idx) / rows],...
                    'Ydata', [y_old; axes_pos1(4) * py(angle_idx) / cols; axes_pos1(4) * py(angle_idx) / cols], ...
                    'Udata', [u_old; qx(angle_idx); -qx(angle_idx)],...
                    'Vdata', [v_old; qy(angle_idx); -qy(angle_idx)],...
                    'LineWidth', 1,...
                    'Visible', 'on');
            end
        end
        
    end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%---------------------- END OF FUNCTION -----------------------------------
%--------------------------------------------------------------------------
end