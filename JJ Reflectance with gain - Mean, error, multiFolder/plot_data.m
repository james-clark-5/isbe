% load in the x_y_4plot.mat file
% run this code

figure;
errorbar(gain_allvals,bright_560_2_allvals,standev_560_2_allvals,'gx');
title(sprintf('Camera 1, 560 nm, saturated'));
xlabel('Gain');
ylabel('Mean brightness value');

figure;
errorbar(gain_allvals,bright_500_2,standev_500_2,'bx');
title(sprintf('Camera 2, 500 nm'));
xlabel('Gain');
ylabel('Mean brightness value');
