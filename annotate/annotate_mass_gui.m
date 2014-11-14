function varargout = annotate_mass_gui(varargin)

handles = {};
mass = {};

initialise_gui;
initialise_figs;

    function initialise_gui
        handles.gui_fig = figure('Visible','off',...
                                'Name', 'Annotate Masses',...
                                'NumberTitle', 'off',...
                                'MenuBar', 'none', ...
                                'WindowStyle', 'normal');
        %top row of GUI                    
        handles.file_text = uicontrol(...
                                'Style','edit',...
                                'String','No file opened',...
                                'Tag','file_open',...
                                'Position', [10,60, 350, 30]);
                            
        handles.file_open = uicontrol(...
                                'Style','pushbutton',...
                                'String','Open',...
                                'Tag','file_open',...
                                'Callback', @file_open_Callback,...
                                'Position', [370,55, 80, 40]);
        handles.save = uicontrol(...
                                'Style','pushbutton',...
                                'String','Save',...
                                'Tag','save',...
                                'Callback', @file_save_Callback,...
                                'Position', [460,55, 80, 40],...
                                'Enable', 'off');
                            
        handles.close = uicontrol(...
                                'Style','pushbutton',...
                                'String','Close File',...
                                'Tag','close',...
                                'Callback', @close_Callback,...
                                'Position', [550,55, 80, 40],...
                                'Enable', 'off');
                            
        %bottom row of GUI
        handles.create_roi = uicontrol(...
                                'Style','pushbutton',...
                                'String','Create ROI',...
                                'Tag','create_ROI',...
                                'Callback', @create_ROI_Callback,...
                                'Position', [10,10, 80, 40],...
                                'Enable', 'off');
        
        handles.show_outline = uicontrol(...
                                'Style','pushbutton',...
                                'String','Show outline',...
                                'Tag','show_outline',...
                                'Callback', @show_outline_Callback,...
                                'Position', [100,10, 80, 40],...
                                'Enable', 'off');
        
        handles.hide_outline = uicontrol(...
                                'Style','pushbutton',...
                                'String','Hide outline',...
                                'Tag','hide_outline',...
                                'Callback', @hide_outline_Callback,...
                                'Position', [190,10, 80, 40],...
                                'Enable', 'off');
        handles.zoom_on = uicontrol(...
                                'Style','togglebutton',...
                                'String','Zoom',...
                                'Tag','zoom_on',...
                                'Callback', @zoom_Callback,...
                                'Position', [280,10, 80, 40],...
                                'Enable', 'off');
        handles.pan_on = uicontrol(...
                                'Style','togglebutton',...
                                'String','Pan',...
                                'Tag','pan_on',...
                                'Callback', @pan_Callback,...
                                'Position', [370,10, 80, 40],...
                                'Enable', 'off');
        handles.delete = uicontrol(...
                                'Style','pushbutton',...
                                'String','Delete point',...
                                'Tag','delete',...
                                'Callback', @delete_Callback,...
                                'Position', [460,10, 80, 40],...
                                'Enable', 'off');
        handles.delete_all = uicontrol(...
                                'Style','pushbutton',...
                                'String','Delete all',...
                                'Tag','delete_all',...
                                'Callback', @delete_all_Callback,...
                                'Position', [550,10, 80, 40],...
                                'Enable', 'off');
        handles.not_saved = 0;
        
        set(handles.gui_fig,'Position',[100,50,640,100],'Visible','on');
    end
    
    function initialise_figs
        handles.fig1 = figure(  'Position',[100,160,600,850],...
                                'Visible','off',...
                                'Name', 'Original mammogram',...
                                'NumberTitle', 'off',...
                                'MenuBar', 'none',...
                                'CloseRequestFcn',@close_fig_Warning, ...
                                'WindowStyle', 'normal');
        handles.zoom_main = uicontrol(...
                                'Style','togglebutton',...
                                'String','Zoom',...
                                'Tag','zoom_main',...
                                'Callback', @zoom_main_Callback,...
                                'Position', [215,10, 80, 40],...
                                'Enable', 'on');
        handles.pan_main = uicontrol(...
                                'Style','togglebutton',...
                                'String','Pan',...
                                'Tag','pan_main',...
                                'Callback', @pan_main_Callback,...
                                'Position', [305,10, 80, 40],...
                                'Enable', 'on');
        handles.axes1 = axes;
        set(handles.fig1,'CurrentAxes', handles.axes1)
        
        handles.fig2 = figure(  'Visible','off',...
                                'Name', 'Mass ROI - grayscale',...
                                'NumberTitle', 'off',...
                                'MenuBar', 'none',...
                                'CloseRequestFcn',@close_fig_Warning, ...
                                'WindowStyle', 'normal');
        handles.axes2 = axes;
        set(handles.fig2,'CurrentAxes', handles.axes2)
        
        handles.fig3 = figure(  'Visible','off',...
                                'Name', 'Mass ROI - color',...
                                'NumberTitle', 'off',...
                                'MenuBar', 'none',...
                                'CloseRequestFcn',@close_fig_Warning, ...
                                'WindowStyle', 'normal');
        handles.axes3 = axes;                    
        set(handles.fig3,'CurrentAxes', handles.axes3)
        
        handles.fig4 = figure(  'Visible','off',...
                                'Name', 'Mass ROI - phase',...
                                'NumberTitle', 'off',...
                                'MenuBar', 'none',...
                                'CloseRequestFcn',@close_fig_Warning, ...
                                'WindowStyle', 'normal');
        handles.axes4 = axes;                    
        set(handles.fig4,'CurrentAxes', handles.axes4)
        
        mass.border = [];
        
    end

    % --------------------------------------------------------------------
    function file_open_Callback(hObject, eventdata)
    % hObject    handle to menu_file_open_orig (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
        
        [filename pathname] = uigetfile('*.bmp','File Selector');
        cd(pathname);
        handles.file_orig_text = strcat(pathname, filename);
        set(handles.file_text, 'String', handles.file_orig_text);
        
        im_orig = imread(handles.file_orig_text);

        set(handles.fig1,   'Visible', 'on',...
                            'WindowButtonDownFcn', @get_R1C1,...
                            'WindowButtonUpFcn', @get_R2C2);
        colormap('gray');
        axes(handles.axes1)
        handles.im1 = imagesc(im_orig); axis image; hold on;

        set(handles.close, 'Enable', 'on');
        set(handles.zoom_on, 'Enable', 'on');
        set(handles.pan_on, 'Enable', 'on');
        handles.rec = 0;
        
        clear im_orig;
    end

    % --------------------------------------------------------------------
    function file_save_Callback(hObject, eventdata)
    % hObject    handle to menu_file_open_orig (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
        if ~isempty(mass.border)
            im_orig = imread(handles.file_orig_text);
            [rows cols] = size(im_orig);
            mass_border = mass.border;

            r1 = max(1, round(min(mass_border(:,2)) - 101 + handles.r1));
            r2 = min(rows, round(max(mass_border(:,2)) + 99 + handles.r1));
            c1 = max(1, round(min(mass_border(:,1)) - 101 + handles.c1));
            c2 = min(cols, round(max(mass_border(:,1)) + 99 + handles.c1));
            mass_ROI = im_orig(r1:r2, c1:c2); clear im_orig;

            mass_outline(:,1) = mass_border(:,1) - c1 + handles.c1; %off set coordinates to
            mass_outline(:,2) = mass_border(:,2) - r1 + handles.r1; %match ROI

            [filename pathname] = uiputfile('*.mat','File Selector');        
            save(strcat(pathname, filename), 'mass_outline', 'mass_ROI');
            cd(pathname);
            handles.not_saved = 0;
        end
    end

    % --------------------------------------------------------------------
    function close_Callback(hObject, eventdata)
    % hObject    handle to menu_file_open_orig (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
        if handles.not_saved
            selection = questdlg('The mass outline has changed since you last saved. Do you still wish to close?',...
                             'Save not up to date',...
                             'Yes','No','Yes');
            switch selection,
                case 'Yes',
                    delete(handles.fig1);
                    delete(handles.fig2);
                    delete(handles.fig3);
                    delete(handles.fig4);
                    delete(handles.gui_fig);
                    handles = {};
                    initialise_gui;
                    initialise_figs;
                case 'No'
                    return
            end
        else
            delete(handles.fig1);
            delete(handles.fig2);
            delete(handles.fig3);
            delete(handles.fig4);
            delete(handles.gui_fig);
            handles = {};
            initialise_gui;
            initialise_figs;
        end
    end

    % --------------------------------------------------------------------
    function create_ROI_Callback(hObject, eventdata)
    % hObject    handle to menu_file_open_orig (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
        
        im_orig = imread(handles.file_orig_text);
        handles.roi = im_orig(handles.r1:handles.r2, handles.c1:handles.c2); 
        clear im_orig; 
        
        %compute monogenic signal and local amplitude, phase and orientation
        handles.local_phase = monogenic(handles.roi, 3, 4, 4, 0.41, 1);

        set(handles.show_outline, 'Enable', 'on');
        set(handles.hide_outline, 'Enable', 'on');
        set(handles.delete_all, 'Enable', 'on');
        set(handles.save, 'Enable', 'on');
        
        set(handles.fig2, 'Position',[100,200,360,480], 'Visible', 'on');
        colormap('gray');
        axes(handles.axes2)
        handles.im2 = imagesc(handles.roi); axis image; hold on;
        set(handles.im2, 'ButtonDownFcn', @plot_point_Callback2);
        
        set(handles.fig3, 'Position',[500,200,360,480], 'Visible', 'on');
        colormap('jet');
        axes(handles.axes3)
        handles.im3 = imagesc(handles.roi); axis image; hold on;
        set(handles.im3, 'ButtonDownFcn', @plot_point_Callback3);
        
        set(handles.fig4, 'Position',[900,200,360,480], 'Visible', 'on');
        colormap('jet');
        axes(handles.axes4)
        handles.im4 = imagesc(handles.local_phase{3}); axis image; hold on;
        set(handles.im4, 'ButtonDownFcn', @plot_point_Callback4);
        
        linkaxes([handles.axes2, handles.axes3, handles.axes4]);
        if ~isempty(mass.border)
            plot_points
        end
     end

    % --------------------------------------------------------------------
    function show_outline_Callback(hObject, eventdata)
    % hObject    handle to plot_point_Callback (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
        set(handles.line2, 'Visible', 'on');
        set(handles.line3, 'Visible', 'on');
        set(handles.line4, 'Visible', 'on');
    end 

    function hide_outline_Callback(hObject, eventdata)
    % hObject    handle to plot_point_Callback (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
        set(handles.line2, 'Visible', 'off');
        set(handles.line3, 'Visible', 'off');
        set(handles.line4, 'Visible', 'off');
    end

    % --------------------------------------------------------------------
    function zoom_Callback(hObject, eventdata)
    % hObject    handle to zoom_Callback (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
        if get(handles.zoom_on, 'Value')
            set(handles.pan_on, 'Value', 0);
            
            if strcmp(get(handles.fig2, 'Visible'), 'on')
                axes(handles.axes2);
                zoom on

                axes(handles.axes3);
                zoom on

                axes(handles.axes4);
                zoom on
            end
        else
            
            if strcmp(get(handles.fig2, 'Visible'), 'on')
                axes(handles.axes2);
                zoom off

                axes(handles.axes3);
                zoom off

                axes(handles.axes4);
                zoom off
            end
        end
    end

    % --------------------------------------------------------------------
    function pan_Callback(hObject, eventdata)
    % hObject    handle to pan_Callback (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
        if get(handles.pan_on, 'Value')
            set(handles.zoom_on, 'Value', 0);
          
            if strcmp(get(handles.fig2, 'Visible'), 'on')
                axes(handles.axes2);
                pan on

                axes(handles.axes3);
                pan on

                axes(handles.axes4);
                pan on
            end
        else
            
            if strcmp(get(handles.fig2, 'Visible'), 'on')
                axes(handles.axes2);
                pan off

                axes(handles.axes3);
                pan off

                axes(handles.axes4);
                pan off
            end
        end
    end

    % --------------------------------------------------------------------
    function delete_Callback(hObject, eventdata)
    % hObject    handle to zoom_Callback (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
        mass.border = mass.border(1:end-1,:);
        handles.curr_point = mass.border(end,:);
        refresh_points
    end

    function delete_all_Callback(hObject, eventdata)
    % hObject    handle to plot_point_Callback (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
        selection = questdlg('Delete all points?',...
                         'Delete all points',...
                         'Yes','No','No');
        switch selection,
            case 'Yes',
                mass.border = [];
                
                delete(handles.pts2);
                delete(handles.pts3);
                delete(handles.pts4);
                
                delete(handles.line2);
                delete(handles.line3);
                delete(handles.line4);
                
                refresh_points;
            case 'No',
                return
        end
    end 

    % --------------------------------------------------------------------
    function get_R1C1(hObject, eventdata)
    % hObject    handle to plot_point_Callback (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
        XYZ = get(handles.axes1, 'CurrentPoint');
        handles.r1 = round(XYZ(1,2));
        handles.c1 = round(XYZ(1,1));
    end

     % --------------------------------------------------------------------
    function get_R2C2(hObject, eventdata)
    % hObject    handle to plot_point_Callback (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
        XYZ = get(handles.axes1, 'CurrentPoint');
        handles.r2 = round(XYZ(1,2));
        handles.c2 = round(XYZ(1,1));
        
        if handles.rec
            refreshdata(handles.axes1, 'caller');
        else
            handles.rec = ...
            plot([handles.c1 handles.c2 handles.c2 handles.c1 handles.c1],...
            [handles.r1 handles.r1 handles.r2 handles.r2 handles.r1],...
            'XDataSource', '[handles.c1 handles.c2 handles.c2 handles.c1 handles.c1]',...
            'YDataSource', '[handles.r1 handles.r1 handles.r2 handles.r2 handles.r1]',...
            'HitTest', 'off');
            set(handles.create_roi, 'Enable', 'on');
        end
    end

     % --------------------------------------------------------------------
    function zoom_main_Callback(hObject, eventdata)
    % hObject    handle to zoom_Callback (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
        if get(handles.zoom_main, 'Value')
            set(handles.pan_main, 'Value', 0);
            axes(handles.axes1);
            zoom on
        else
            axes(handles.axes1);
            zoom off
        end
    end

    % --------------------------------------------------------------------
    function pan_main_Callback(hObject, eventdata)
    % hObject    handle to pan_Callback (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
        if get(handles.pan_main, 'Value')
            set(handles.zoom_main, 'Value', 0);
            axes(handles.axes1);
            pan on
        else
            axes(handles.axes1);
            pan off
        end
    end

    % --------------------------------------------------------------------
    function plot_point_Callback2(hObject, eventdata)
    % hObject    handle to plot_point_Callback (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
        l_or_r = get(handles.fig2, 'SelectionType');
        XYZ = get(handles.axes2, 'CurrentPoint');
        switch l_or_r,
            case 'normal',
                plot_point(XYZ(1,1), XYZ(1,2));
            case 'alt'
                highlight_point(XYZ(1,1), XYZ(1,2));
            case 'extend'
                move_point(XYZ(1,1), XYZ(1,2));
            otherwise
        end
    end

    % --------------------------------------------------------------------
    function plot_point_Callback3(hObject, eventdata)
    % hObject    handle to plot_point_Callback (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
        l_or_r = get(handles.fig3, 'SelectionType');
        XYZ = get(handles.axes3, 'CurrentPoint');
        switch l_or_r,
            case 'normal',
                plot_point(XYZ(1,1), XYZ(1,2));               
            case 'alt'
                highlight_point(XYZ(1,1), XYZ(1,2));
            case 'extend'
                move_point(XYZ(1,1), XYZ(1,2));
            otherwise
        end
    end

    % --------------------------------------------------------------------
    function plot_point_Callback4(hObject, eventdata)
    % hObject    handle to plot_point_Callback (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
        l_or_r = get(handles.fig4, 'SelectionType');
        XYZ = get(handles.axes4, 'CurrentPoint');
        switch l_or_r,
            case 'normal',
                plot_point(XYZ(1,1), XYZ(1,2));
            case 'alt'
                highlight_point(XYZ(1,1), XYZ(1,2));
            case 'extend'
                move_point(XYZ(1,1), XYZ(1,2));
            otherwise
        end
    end

    % --------------------------------------------------------------------
    function plot_point(x, y)
        handles.not_saved = 1;
        handles.curr_point = [x y];
        if isempty(mass.border)
            mass.border = [mass.border; [x,y]];
            set(handles.delete, 'Enable', 'on');
            plot_points
        else
            mass.border = [mass.border; [x,y]];
            refresh_points
        end
        
    end

    function highlight_point(x, y)
    %
        d = (mass.border(:,1) - x).^2 + (mass.border(:,2) - y).^2;
        idx = find(d == min(d));
        
        if length(mass.border(:,1)) - idx
            mass.border =...
            [mass.border(idx+1:end,:); mass.border(1:idx,:)];
            handles.curr_point = mass.border(end, :);
        end
        
        refresh_points
    end
    
    % --------------------------------------------------------------------
    function move_point(x, y)
        mass.border(end, :) = [x y];
        handles.curr_point = [x y];
        refresh_points;
    end

    % --------------------------------------------------------------------
    function plot_points
        %axes2
        axes(handles.axes2);
        handles.pts2 =...
            plot(mass.border(:,1),...
            mass.border(:,2), 'mx',...
            'XDataSource', 'mass.border(:,1)',...
            'YDataSource', 'mass.border(:,2)',...
            'HitTest', 'off');
        
        handles.line2 =...
        plot([mass.border(:,1); mass.border(1,1)],...
            [mass.border(:,2); mass.border(1,2)],...
            'g', 'LineWidth', 1.5,...
            'XDataSource', '[mass.border(:,1); mass.border(1,1)]',...
            'YDataSource', '[mass.border(:,2); mass.border(1,2)]',...
            'HitTest', 'off');
        plot(handles.curr_point(1), handles.curr_point(2), 'mo',...
            'XDataSource', 'handles.curr_point(1)',...
            'YDataSource', 'handles.curr_point(2)',...
            'HitTest', 'off');
        
        %axes3
        axes(handles.axes3);
        handles.pts3 =...
        plot(mass.border(:,1), mass.border(:,2), 'kx',...
            'XDataSource', 'mass.border(:,1)',...
            'YDataSource', 'mass.border(:,2)',...
            'HitTest', 'off');
        
        handles.line3 = ...
        plot([mass.border(:,1); mass.border(1,1)],...
            [mass.border(:,2); mass.border(1,2)],...
            'k', 'LineWidth', 1.5,...
            'XDataSource', '[mass.border(:,1); mass.border(1,1)]',...
            'YDataSource', '[mass.border(:,2); mass.border(1,2)]',...
            'HitTest', 'off');
        plot(handles.curr_point(1), handles.curr_point(2), 'ko',...
            'XDataSource', 'handles.curr_point(1)',...
            'YDataSource', 'handles.curr_point(2)',...
            'HitTest', 'off');
        
        %axes 4
        axes(handles.axes4);
        handles.pts4 =...
        plot(mass.border(:,1), mass.border(:,2), 'kx',...
            'XDataSource', 'mass.border(:,1)',...
            'YDataSource', 'mass.border(:,2)',...
            'HitTest', 'off');        
        handles.line4 =...
        plot([mass.border(:,1); mass.border(1,1)],...
            [mass.border(:,2); mass.border(1,2)],...
            'k', 'LineWidth', 1.5,...
            'XDataSource', '[mass.border(:,1); mass.border(1,1)]',...
            'YDataSource', '[mass.border(:,2); mass.border(1,2)]',...
            'HitTest', 'off');
        plot(handles.curr_point(1), handles.curr_point(2), 'ko',...
            'XDataSource', 'handles.curr_point(1)',...
            'YDataSource', 'handles.curr_point(2)',...
            'HitTest', 'off');
        
        set(handles.line2, 'Visible', 'off');
        set(handles.line3, 'Visible', 'off');
        set(handles.line4, 'Visible', 'off');
    end

    function refresh_points
        refreshdata(handles.axes2, 'caller');
        refreshdata(handles.axes3, 'caller');
        refreshdata(handles.axes4, 'caller');
    end

    % --------------------------------------------------------------------
    function close_fig_Warning(hObject, eventData)
    % my_closereq 
    % User-defined close request function
    % to display a question dialog box
        warndlg('Individual figures may not be closed. If you would like to close this file, please use the button on the control bar',...
        'Cannot close window')
    end

end

%if ~isempty(mass.border)
        %    x2 = mass.border(end, 1);
        %    y2 = mass.border(end, 2);
        %    d = (x1 - x2)^2 + (y1 - y2)^2;
        %    new_x = ([1:40:d]*(x1-x2)/d)+x2;
        %    new_y = ([1:40:d]*(y1-y2)/d)+y2;
        %    mass.border = [mass.border; [new_x; new_y]'];
        %else
        %    mass.border = [mass.border; [x1,y1]];
        %end

