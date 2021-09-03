function pd = ShapeInterpolation_linear(contours)
%Basic linear interpolation formula betwaeen each point
%only interpolates between first two contours

%https://math.stackexchange.com/questions/105400/linear-interpolation-in-3-dimensions

%place known slices at arbitrary heights
depth_val = [100; 250; 400];
%desired height of slice above bottom slice
d = 80;

%create sets of points to be operated on 
p0 = [contours{1}(:,2) contours{1}(:,1) depth_val(1)*ones(length(contours{1}),1)];
p1 = [contours{2}(:,2) contours{2}(:,1) depth_val(2)*ones(length(contours{1}),1)];

%difference between sets of points to create vectos
v = p1 - p0;

%distances between points
v_norm = zeros(length(contours{1}),1);
for k = 1:length(contours{1})
   v_norm(k,1) = sqrt(v(k,1).^2+v(k,2).^2+v(k,3).^2);
end

%linear interpolation
pd = p0+d*(v./v_norm);
%remove decimals from z-axis
pd = [pd(:,1) pd(:,2) fix(pd(:,3))];

end



