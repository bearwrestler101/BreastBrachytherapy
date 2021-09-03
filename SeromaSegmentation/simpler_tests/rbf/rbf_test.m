close all; clear;
x1 = [6 4 5];
x2 = [3 6 1];
D = [norm(x2(1)-x1(1)) norm(x2(2)-x1(2)) norm(x2(3)-x1(3))];
sigma = 3;
rbf = exp(-D.^2/(2*sigma^2));
hold on
plot3(x1(1), x1(2), x1(3), 'o')
plot3(x2(1), x2(2), x2(3), 'o')
hold off
figure;
%plot3(rbf(1), rbf(2), rbf(3),'+')
x = [-10:0.1:10];
fnc = exp(-(x).^2/(2*3^2));
plot(x,fnc)