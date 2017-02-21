% load in the x_y_4plot.mat file
% run this code

figure;
errorbar(gain_c1,brightness_c1,noise_c1,'gx');
title(sprintf('C1 w/ 530nm filter w/ dust'));
xlabel('Gain');
ylabel('Mean brightness value');

figure;
errorbar(gain_c2,brightness_c2,noise_c2,'bx');
title(sprintf('C2 w/ 560nm filter w/ dust'));
xlabel('Gain');
ylabel('Mean brightness value');
