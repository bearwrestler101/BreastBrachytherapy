function [triangles, surfaceCoords] = ShapeInterpolation(contourCell, pos_cell)


%% Constants
%constants
num_points = 100;
epsilon = 0.2; %%%EDIT TO IMPROVE FIT%%%
zValuesRescale = 60;
contourLength = 80;

%% Contour Interpolation
%import images, preprocess, find contours, remove poor contours

contourCellInt = ContourInterpolation2d(contourCell, num_points);

% for interpolation endpoint error prevention
contourCellInt = [contourCellInt(1,1); contourCellInt(1,1); contourCellInt; contourCellInt(end,1); contourCellInt(end,1)];
figure
hold on
for i = 1:size(contourCellInt,1)
    plot(contourCellInt{i}(:,2), -contourCellInt{i}(:,1)); 
end

% additional zValues added for interpolation endpoint error prevention
zValues = zeros(size(contourCellInt,1),1); %z values of slices
for i = 1:size(zValues,1)
    zValues(i,1) = pos_cell{i+13,1}(1,1);
end
zValues = rescale(zValues, 0, zValuesRescale);
zInt = linspace(min(zValues),max(zValues), contourLength); %points to interpolate at

%% Shape Interpolation

s_x = cell(num_points, 1);
s_y = cell(num_points, 1);
f_x = zeros(size(contourCellInt,1),2);

%rbf 3d interpolation as outlined by https://en.wikipedia.org/wiki/Radial_basis_function_interpolation
%interpolating x and y values given known z values
for i = 1:num_points
    for j = 1:size(contourCellInt,1)
        f_x(j,:) = contourCellInt{j}(i,:);
    end
    phi_mat = make_phi_mat(zValues, epsilon);
    w = phi_mat\f_x;
    [s_x{i,1}, s_y{i,1}] = fnc_gen(zInt, zValues, w, epsilon);
end

%cut out the extras added for interpolation error mititgation
for i = 1:size(s_x,1)
    s_x{i} = s_x{i}(zInt>zValues(13,1) & zInt<zValues(3,1));
    s_y{i} = s_y{i}(zInt>zValues(13,1) & zInt<zValues(3,1));
end
zInt = zInt(zInt>zValues(13,1) & zInt<zValues(3,1));

figure
hold on
%plot interpolated 3d curves
for i = 1:length(s_x)
    plot3(zInt, s_x{i,1}, s_y{i,1},'Linewidth', 2)
end
%plot interpolated 2d slices
for i = 3:size(contourCellInt,1)-2 %getting rid of extras
    cnt_int = contourCellInt{i};
    plot3(zValues(i,1)*ones(length(cnt_int),1), cnt_int(:,1), cnt_int(:,2), 'b', 'Linewidth', 3);
end

%create vectors 
s_x_surf = cell2mat(s_x);
s_y_surf = cell2mat(s_y);
zInt_surf = repmat(zInt, 1, length(s_x)).';

triangles = CreateTriangles(num_points, length(zInt));
surfaceCoords = [s_x_surf s_y_surf zInt_surf];

end
