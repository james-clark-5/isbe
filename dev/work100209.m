%--------------------------------------------------------------------------
% Some methods for in-painting the border regions of retinograms
%--------------------------------------------------------------------------

%load in images, ground truth and masks
ret = rgb2gray(imread('C:\isbe\dev\image_data\retina_drive\training\images\21_training.tif'));
mask = logical(imread('C:\isbe\dev\image_data\retina_drive\training\masks\21_training_mask.gif'));
truth = logical(imread('C:\isbe\dev\image_data\retina_drive\training\truth\21_manual1.gif'));


%Get inner mask to avoid bright edge of disk - try varying the number of
%pixels you erode by, currently set at 10
mask_inner = imerode(mask, strel('disk', 5));

%Also, it is helpful to consider only pixels in the outer ring of the inner
%mask, so erode a further mask and take the difference between the two
%Again try varying the amount of erosion, currently using 20 (i.e. to
%create a ring of width 10 pixels);
mask_inner2 = imerode(mask, strel('disk', 7));
mask_ring = mask_inner & ~mask_inner2;

%--------------------------------------------------------------------------
%%
%1) Fill everything with the mean of background pixels from inner mask
mean_val = uint8(mean(ret(mask_inner & ~truth)));
ret_syn1 = ret;
ret_syn1(~mask_inner) = mean_val;
figure; imagesc(ret_syn1); axis image
%--------------------------------------------------------------------------
%%
%2) Fill everything with the mean of background pixels from the inner ring
mean_val = uint8(mean(ret(mask_ring & ~truth)));
ret_syn2 = ret;
ret_syn2(~mask_inner) = mean_val;
figure; imagesc(ret_syn2); axis image
%--------------------------------------------------------------------------
%%
%3) Fill using imdilate - effectively stretches inner image pixel
%intensities to the outside of the image. This doesn't seem to work very
%well though...
ret_dilate = ret;
ret_dilate(~mask_ring) = 0;
dilate_mask = mask_inner;
while any(~dilate_mask(:))
    ret_dilate = imdilate(ret_dilate, strel('disk', 3));
    ret_dilate(mask_inner) = 0;
    dilate_mask = imdilate(dilate_mask, strel('disk', 3));
    %figure; imagesc(ret_dilate); axis image;
end
ret_syn3 = ret;
ret_syn3(~mask_inner) = ret_dilate(~mask_inner);
figure; imagesc(ret_syn3); axis image;
%--------------------------------------------------------------------------
%%
%4) Fill image using nearest neighbour interpolation - each pixel in the
%outside is assigned the value of the pixel it is closed to inside the mask
[y_int x_int] = find(~mask_inner);
[y x] = find(mask_ring);
z = double(ret(mask_ring));
z_int = griddata(x, y, z, x_int, y_int, 'nearest');
ret_syn4 = ret;
ret_syn4(~mask_inner) = z_int;
figure; imagesc(ret_syn4); axis image;
%--------------------------------------------------------------------------
%%
%5) Fill image sector by sector with average of internal sector

%Compute orientation of vector from each pixel to centre of image
[row col] = size(ret);
[x, y] = meshgrid(1:col, 1:row);
x = x - col/2;
y = y - row/2;
tan_yx = atan2(y, x);

%Select how many sectors to use - try varying this number, currently set at
%360
n_sectors = 360;
ori = (linspace(-pi,pi, n_sectors));

ret_syn5 = ret;

%Work through each sector, filling the outside pixels with the mean of
%background pixels from the corresponding sector in the inner ring
for ii = 1:n_sectors-1

    sector = (tan_yx >  ori(ii)) & (tan_yx <=  ori(ii+1));
    mean_val = mean(ret(sector & mask_ring & ~truth));
    
    ret_syn5(sector & ~mask_inner) = mean_val;

end
figure; imagesc(ret_syn5); axis image;
%--------------------------------------------------------------------------
%%
% 6) Fill image sector by sector using randomly selected pixels - as 5,
% but rather than selecting a single mean value for the outside pixels,
% randomly select a value from the pixels in the correpsonding
% sector of the inner ring
[row col] = size(ret);
[x, y] = meshgrid(1:col, 1:row);
x = x - col/2;
y = y - row/2;
tan_yx = atan2(y, x);
n_sectors = 36;
ori = (linspace(-pi,pi, n_sectors));

ret_syn6 = ret;
for ii = 1:n_sectors-1

    sector = (tan_yx >  ori(ii)) & (tan_yx <=  ori(ii+1));
    mask_to_fill = sector & ~mask_inner;
    
    %Can choose from all pixels or only background pixels - un/comment
    %either of the following 2 lines
    %ret_vals = ret(sector & mask_ring & ~truth);
    ret_vals = ret(sector & mask_ring);
    rand_idx = ceil(rand(sum(mask_to_fill(:)),1)*length(ret_vals));
    
    ret_syn6(mask_to_fill) = ret_vals(rand_idx);
    
end
figure; imagesc(ret_syn6); axis image;
%--------------------------------------------------------------------------
%%
% 7) Fill using efros and leung synthesis algorithm - warning this will be
% slow - try varying win_size and see the change in results (always using an odd value). 
% Increasing win_size will increase the time it takes to compute though...
win_size = 3;

%Sample local patches of texture about backgorund pixels in the inner ring
%to act as exemplars in the algorithm
[sample_rows sample_cols] = find(mask_ring & ~truth);
N = length(sample_rows);
args.SampleData = uint8(zeros(N, win_size*win_size));

for ii = 1:length(sample_rows)
     sampled_window = sample_window(ret, win_size, sample_rows(ii), sample_cols(ii));
     args.SampleData(ii,:) = sampled_window(:);
end
% Set up the function arguments and perform the synthesis
args.SeedImage = ret; 
args.FilledImage = mask_inner;
args.WindowSize = win_size;

[ret_syn7] = mb_efros_tex_syn(args);
figure; imagesc(ret_syn7); axis image;
%--------------------------------------------------------------------------
%%
% 8) Fill in image sector by sector using efros and leung - combines
% methods 6) and 7). i.e. we apply Efros/Leung but only use exemplar pixels
% from corresponding sectors

win_size = 3;

%Again generate orientations at each pixel
[row col] = size(ret);
[x, y] = meshgrid(1:col, 1:row);
x = x - col/2;
y = y - row/2;
tan_yx = atan2(y, x);

%select the number of sectors to use
n_sectors = 360;
ori = (linspace(-pi,pi, n_sectors));

%set up the initial arguments of the synthesis function
seed_image = ret;
seed_image(~mask_inner) = NaN;

%Work through each sector
for ii = 1:n_sectors-1

    %Compute pixels in sector
    sector = (tan_yx >  ori(ii)) & (tan_yx <=  ori(ii+1));
    mask_to_fill = sector & ~mask_inner;
    
    %Extract patches about pixels to act as exemplars
    [sample_rows sample_cols] = find(sector & mask_ring & ~truth);
    N = length(sample_rows);
    args.SampleData = uint8(zeros(N, win_size*win_size));
    
    for jj = 1:length(sample_rows)
         sampled_window = sample_window(ret, win_size, sample_rows(jj), sample_cols(jj));
         args.SampleData(jj,:) = sampled_window(:);
    end
    
    %Fill in the outside pixels in this sector
    args.SeedImage = seed_image; 
    args.FilledImage = ~mask_to_fill;
    args.WindowSize = win_size;
    
    [seed_image] = mb_efros_tex_syn(args);
    %figure; imagesc(seed_image); axis image;
end
ret_syn8 = seed_image;
figure; imagesc(ret_syn8); axis image;