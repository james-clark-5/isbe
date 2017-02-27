% load in the x_y_4plot.mat file
% run this code

figure;
% 560, trial 2, all values
errorbar(gain_allvals,bright_560_2_allvals,standev_560_2_allvals,'rx');
xlabel('Gain');
ylabel('Mean brightness value');
hold;

% 560, trial 1, all values
errorbar(gain_500,bright_560_1,standev_560_1,'bx');

% 530, trial 1, all values
errorbar(gain_500,bright_530_1,standev_530_1,'gx');

% 500, trial 1, all values
errorbar(gain_allvals,bright_500_2,standev_500_2,'mx');

title(sprintf('Comparison of variation of brightness with gain for different wavelengths'));
legend('C1 560nm, trial 1','C1 560nm, trail 2','C2 530nm','C2 500nm')