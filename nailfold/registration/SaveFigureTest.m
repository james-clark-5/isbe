clear all; 

x = [0 1 2];
y = [10 20 30];


testFileDirectory = 'C:\Users\James\Desktop\';
%fileNameNoRegister = 'Unregistered image';
fullfile = fullfile(testFileDirectory, 'Unregistered image');
fig = plot(x,y);
saveas(fig, fullfile, 'bmp'); %bmp
saveas(fig, fullfile, 'meta'); %emf 
saveas(fig, fullfile, 'fig'); %fig