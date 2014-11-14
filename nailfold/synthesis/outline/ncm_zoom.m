imgroot = 'U:\projects\nailfold\synthesis\showcase\ncm_outline';

imgpath = fullfile(imgroot, 'input');
filename = sprintf('frame_0001.png');

img = imread(fullfile(imgpath,filename));
img = mean(img,3);

imsz = size(img);
imh = imsz(1);
imw = imsz(2);

x0  = [535;  535;  495;  495;  imw/2];
y0  = [90;   90;   95;   95;   imh/2];
scl = [0.15; 0.15; 0.25; 0.25; 1.00];
n   = [0;    50;   100;  50;   100];

x = [];
y = [];
s = [];

for c = 2:length(x0)
    x = [x linspace(x0(c-1), x0(c), n(c))];
    y = [y linspace(y0(c-1), y0(c), n(c))];
%     s = [s linspace(scl(c-1), scl(c), n(c))];
    s = [s exp(linspace(log(scl(c-1)), log(scl(c)), n(c)))];
end
    
% Smooth them
z = linspace(-3,3,101);
f = exp(-0.5*z.*z);
f = f / sum(f(:));
x = conv2(x, f, 'valid');
y = conv2(y, f, 'valid');
s = conv2(s, f, 'valid');

w = imw*s;
h = imh*s;
    
outpath = fullfile(imgroot, 'output');
delete(fullfile(outpath,'*.png'));

timebar('closeall');
tb = timebar('title','Rendering','limit',length(x));
for i = 1:length(x)
    if 1
        filename = sprintf('frame_%04d.png', i);
        img = imread(fullfile(imgpath, filename));
        img = mean(img,3);

        [xx,yy] = meshgrid(linspace(x(i)-w(i)/2, x(i)+w(i)/2, imw), ...
                           linspace(y(i)-h(i)/2, y(i)+h(i)/2, imh));
        newim = interp2(img, xx, yy, '*linear');
        imwrite(uint8(newim), fullfile(outpath,filename));
    else
        figure(1); clf; colormap(gray(256));
            image(img);
            axis('image');
            rectangle('position', [x(i)-w(i)/2, y(i)-h(i)/2, w(i), h(i)]);

        pause(1/30);
    end
    
    timebar(tb, 'advance');
end
timebar(tb,'close');