a=10; % horizontal radius
b=5; % vertical radius
x0=0; % x0,y0 ellipse centre coordinates
y0=0;
t=linspace(-pi,pi,11);
x=x0+a*cos(t);
y=y0+b*sin(t);
plot(x,y)
axis equal
% Now that we have x, y vals, reparameterize and interp.
% Assuming linear interpolation adequately represents the ellipse
dist = sqrt(diff(x).^2+diff(y).^2);
%Reparameterize
tm = cumsum([0 dist]);
t = linspace(0,tm(end));
xInt = interp1(tm,x,t,"spline");
yInt = interp1(tm,y,t,"spline");
hold on
plot(xInt,yInt)