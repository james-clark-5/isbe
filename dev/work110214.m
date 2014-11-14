%**************************************************************************
%*********************** ILP example **************************************
%**************************************************************************
bg_dir = {...
    [asymmetryroot '\data\synthetic_backgrounds\smooth512\train\'],...
    [asymmetryroot '\data\synthetic_backgrounds\real512\train\']};
%
for bg_type = 1:2
    rand('twister', 1);
    randn('state', 1);
    [Xi yi] = generate_line_training_data(...
        'num_samples', 1e4,...
        'bg_dir', bg_dir{bg_type},... % the mandatory arguments
        'decomp_type', 'dt',...
        'num_bgs', 200,...
        'bg_stem', 'bg',...
        'bg_zeros', 5,...
        'detection_type', 'orientation',...
        'pts_per_image', 50,...
        'bg_ratio', 1,...
        'width_range', [6 6],...
        'orientation_range', [0 360],...
        'contrast_range', [8 8],...
        'decay_rate', 4,...
        'line_type', 'ellipse',...
        'normalise', 0,...
        'num_levels', 5,...
        'feature_shape', 'rect',...
        'feature_type', 'ilp',...
        'do_max', 0,...
        'rotate', 0,...
        'win_size', 1);
    %
    rand('twister', 1);
    randn('state', 1);
    [Xc yc] = generate_line_training_data(...
        'num_samples', 1e4,...
        'bg_dir', bg_dir{bg_type},... % the mandatory arguments
        'decomp_type', 'dt',...
        'num_bgs', 200,...
        'bg_stem', 'bg',...
        'bg_zeros', 5,...
        'detection_type', 'orientation',...
        'pts_per_image', 50,...
        'bg_ratio', 1,...
        'width_range', [6 6],...
        'orientation_range', [0 360],...
        'contrast_range', [8 8],...
        'decay_rate', 4,...
        'line_type', 'ellipse',...
        'normalise', 0,...
        'num_levels', 5,...
        'feature_shape', 'rect',...
        'feature_type', 'all',...
        'do_max', 0,...
        'rotate', 0,...
        'win_size', 1);
    %
    %sanity check that yi and yc are equivalent:
    max(abs(yi - yc));
    
    %Now plot the phase vs magnitude
    cmap = hsv(180);
    y_deg = mod(floor(90*angle(yi)/pi),180)+1;
    dim = 30; %num_levels * num_subbbands
    for lev = 3:5
        for ori = 1:6
            col = 6*(lev-1) + ori;

            figure;  
            subplot(1,2,1); hold on;
            for deg = 1:180
                idx = y_deg == deg;
                plot(Xi(idx, col+dim), Xi(idx, col), '.', 'markerfacecolor', cmap(deg,:),'markeredgecolor', cmap(deg,:));
            end
            set(gca, 'xlim', [-pi pi]);
            title(['ILP: Level ' num2str(lev-1) '-' num2str(lev) ', band ', num2str(ori)]);
            xlabel('Phase');
            ylabel('Mag');
            subplot(1,2,2); hold on;

            for deg = 1:180
                idx = y_deg == deg;
                plot(Xc(idx, col+dim), Xc(idx, col), '.', 'markerfacecolor', cmap(deg,:),'markeredgecolor', cmap(deg,:));
            end
            set(gca, 'xlim', [-pi pi]);
            title(['Original DT: Level ' num2str(lev) ', band ', num2str(ori)]);
            xlabel('Phase');
            ylabel('Mag');
        end
    end
end
%% ------------------------------------------------------------------------
%**************************************************************************
%*********************** ICP example **************************************
%**************************************************************************
bg_dir = {...
    [asymmetryroot 'data\synthetic_backgrounds\smooth512\train\'],...
    [asymmetryroot 'data\synthetic_backgrounds\real512\train\']};

rand('twister', 1);
randn('state', 1);
[Xs ys] = generate_line_training_data(...
    'num_samples', 1e4,...
    'bg_dir', bg_dir{1},... % the mandatory arguments
    'decomp_type', 'dt',...
    'num_bgs', 200,...
    'bg_stem', 'bg',...
    'bg_zeros', 5,...
    'detection_type', 'orientation',...
    'pts_per_image', 50,...
    'bg_ratio', 1,...
    'width_range', [6 6],...
    'orientation_range', [0 360],...
    'contrast_range', [8 8],...
    'decay_rate', 4,...
    'line_type', 'ellipse',...
    'normalise', 0,...
    'num_levels', 4,...
    'feature_shape', 'rect',...
    'feature_type', 'icp',...
    'do_max', 0,...
    'rotate', 0,...
    'win_size', 3,...
    'use_nag', 0);
rand('twister', 1);
randn('state', 1);
[Xr yr] = generate_line_training_data(...
    'num_samples', 1e4,...
    'bg_dir', bg_dir{2},... % the mandatory arguments
    'decomp_type', 'dt',...
    'num_bgs', 200,...
    'bg_stem', 'bg',...
    'bg_zeros', 5,...
    'detection_type', 'orientation',...
    'pts_per_image', 50,...
    'bg_ratio', 1,...
    'width_range', [6 6],...
    'orientation_range', [0 360],...
    'contrast_range', [8 8],...
    'decay_rate', 4,...
    'line_type', 'ellipse',...
    'normalise', 0,...
    'num_levels', 4,...
    'feature_shape', 'rect',...
    'feature_type', 'icp',...
    'do_max', 0,...
    'rotate', 0,...
    'win_size', 3,...
    'use_nag', 0);

save Z:\data\misc\icp_example_data Xr yr Xs ys
%
cmap = hsv(180);
y_deg = mod(floor(90*angle(yr)/pi),180)+1;
dim = 216; %num_levels * num_subbbands
positions = {...
    'Upper left',...
    'Upper centre',...
    'Upper right',...
    'Centre left',...
    'Centre',...
    'Centre right',...
    'Lower left',...
    'Lower centre',...
    'Lower right'};
for lev = 4
    for ori = 1:6
        for pos = 1:9
            col = 54*(lev-1) + 9*(ori-1) + pos;

            figure; 
            subplot(1,2,1); hold on;
            for deg = 1:180
                idx = y_deg == deg;
                plot(Xs(idx, col+dim), Xs(idx, col), '.', 'markerfacecolor', cmap(deg,:),'markeredgecolor', cmap(deg,:));
            end
            set(gca, 'xlim', [-pi pi]);
            title(['ICP: ' positions{pos} ' pixel, band ', num2str(ori) '(Synthetic BGs)']);
            xlabel('Phase');
            ylabel('Mag');
            
            subplot(1,2,2); hold on;
            for deg = 1:180
                idx = y_deg == deg;
                plot(Xr(idx, col+dim), Xr(idx, col), '.', 'markerfacecolor', cmap(deg,:),'markeredgecolor', cmap(deg,:));
            end
            set(gca, 'xlim', [-pi pi]);
            title(['ICP: ' positions{pos} ' pixel, band ', num2str(ori) '(Real BGs)']);
            xlabel('Phase');
            ylabel('Mag');

        end
    end
end
%%
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%%
oe_rf_old = u_load('C:\isbe\asymmetry_project\data\misc\ori_errors_213209.mat');
oe_rf_new = u_load('C:\isbe\asymmetry_project\data\misc\ori_errors_243311.mat')*2;
oe_rf_g2d = u_load('C:\isbe\asymmetry_project\data\misc\ori_errors_g2.mat')*2;
%%
figure; surf(2:16, 5*(1:36), oe_rf_old); a1 = gca;
caxis([0 45]);
set(gca, 'zlim', [0 45]);
xlabel('Contrast'); ylabel('Line orientation (degrees)'); zlabel('Mean Absolute error');
title('Errors for varying contrast and line orientation - old RF');

figure; surf(2:2:16, 5*(1:36),oe_rf_new); a2 = gca;
caxis([0 45]);
set(gca, 'zlim', [0 45]);
xlabel('Contrast'); ylabel('Line orientation (degrees)'); zlabel('Mean Absolute error');
title('Errors for varying contrast and line orientation - new RF');

figure; surf(2:2:16, 5*(1:36), oe_rf_g2d); a3 = gca;
caxis([0 45]);
set(gca, 'zlim', [0 45]);
xlabel('Contrast'); ylabel('Line orientation (degrees)'); zlabel('Mean Absolute error');
title('Errors for varying contrast and line orientation - Gaussian 2nd Derivative');

linkaxes([a1 a2 a3]);
%%
print_pdf('C:\isbe\asymmetry_project\data\misc\ori_errors_213209_fig.pdf', gcf);
print_pdf('C:\isbe\asymmetry_project\data\misc\ori_errors_243311_fig.pdf', gcf);
print_pdf('C:\isbe\asymmetry_project\data\misc\ori_errors_g2d_fig.pdf', gcf);
%%
rf_mag = u_load('C:\isbe\asymmetry_project\data\line_orientation_rfs\243629\random_forest.mat');
rf_phase = u_load('C:\isbe\asymmetry_project\data\line_orientation_rfs\243630\random_forest.mat');
rf_all = u_load('C:\isbe\asymmetry_project\data\line_orientation_rfs\243311\random_forest.mat');
rf_or = u_load('C:\isbe\asymmetry_project\data\line_orientation_rfs\286712\random_forest.mat');
%%
leaves_mag = forest_leaf_output(rf_mag, 0);
leaves_phase = forest_leaf_output(rf_phase, 0);
leaves_all = forest_leaf_output(rf_all, 0);
leaves_or = forest_leaf_output(rf_or, 0);
%%
f1 = figure; 
subplot(2,1,1); hold on;
plot(0:180, leaves_mag / sum(leaves_mag), 'r', 'linewidth', 2);
plot(0:180, leaves_phase / sum(leaves_phase), 'g', 'linewidth', 2);
y_lim = get(gca, 'ylim');
plot([15 15], y_lim, 'k:');
legend({'Magnitude only', 'Phase only', 'sub-band orientations'}, 'location', 'southeast');
for bb = 45:30:165
    plot([bb bb], y_lim, 'k:');
end
title('Histogram of forest leaf outputs by orientation')
ylabel('Percentage of total leaves');
xlabel('Leaf output (degrees)');

subplot(2,1,2); hold on;
plot(0:180, leaves_mag / sum(leaves_mag), 'r:');
plot(0:180, leaves_phase / sum(leaves_phase), 'g:');
plot(0:180, leaves_all / sum(leaves_all), 'b', 'linewidth', 2);
y_lim = get(gca, 'ylim');
plot([15 15], y_lim, 'k:');
legend({'Magnitude only', 'Phase only', 'Phase and magnitude (conjugate representation', 'sub-band orientations'},...
    'location', 'southeast');
for bb = 45:30:165
    plot([bb bb], y_lim, 'k:');
end
plot(0:180, leaves_or / sum(leaves_or), 'm--', 'linewidth', 2);
title('Histogram of forest leaf outputs by orientation')
ylabel('Percentage of total leaves');
xlabel('Leaf output (degrees)');

print_pdf('Z:\data\misc\rf_leaf_outputs_pm.pdf', f1);
%%
cooc_nrows = dt_dims_cooc ./ repmat(sum(dt_dims_cooc,2), 1, 48);
cooc_ncols = dt_dims_cooc ./ repmat(sum(dt_dims_cooc,1), 48, 1);

cooc_nrowscols = cooc_nrows ./ repmat(sum(cooc_nrows,1), 48, 1);
cooc_ncolsrows = cooc_ncols ./ repmat(sum(cooc_ncols,2), 1, 48);

cooc_nij = dt_dims_cooc ./ (dt_dims_counts * dt_dims_counts');
cooc_nrc = (dt_dims_cooc ./ repmat(sum(dt_dims_cooc,2), 1, 48)) ./ repmat(sum(dt_dims_cooc,1), 48, 1);

figure; imagesc(dt_dims_cooc); axis image; title('Original cooccurrences')
figure; imagesc(cooc_nrows); axis image; title('Cooccurrences - rows normalised')
figure; imagesc(cooc_ncols); axis image; title('Cooccurrences - cols normalised')
figure; imagesc(cooc_nrowscols); axis image; title('Cooccurrences - rows then cols normalised')
figure; imagesc(cooc_ncolsrows); axis image; title('Cooccurrences - cols then rows normalised')
figure; imagesc(cooc_nrc); axis image; title('Cooccurrences - normalised by rows and cols')
figure; imagesc(cooc_nij); axis image; title('Cooccurrences - normalised by p(I&J)')
%%
cooc_nrc = (dt_dims_cooc ./ repmat(sum(dt_dims_cooc,2), 1, 432)) ./ repmat(sum(dt_dims_cooc,1), 432, 1);
figure; imagesc(cooc_nrc); axis image; title('Cooccurrences - normalised by rows and cols');

