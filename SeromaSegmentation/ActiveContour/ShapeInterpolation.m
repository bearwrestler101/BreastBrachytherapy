% function [triangles, surfaceCoords] = ShapeInterpolation(contourCell, pos_cell, org_pos_cell)
% function [s] = ShapeInterpolation(contourCell, pos_cell, org_pos_cell)
function [s] = ShapeInterpolation(contourCell, pos_cell, panda_pos_test)



%need to figure out best epislon and rbf function - deprecated
%need to figure out most accurate inter-slice distance - deprecated


%% Constants
%constants
num_points = 100;
epsilon = 0.2; %%%EDIT TO IMPROVE FIT%%%
zValuesRescale = 60; %60 is probably wrong, need some sort of calibration
contourLength = 80;

%% Interslice distances (z-values) - TODO maybe put this in main?
% trunc_pos_cell = cell(11,3); 
% mean_pos_cell= cell(11,1);
% 
% % offsets are hardcoded (see ImagesForStitch.m)
% % obtain pos of scans containing seroma (hardcoded)
% for i = 1:size(trunc_pos_cell,1)
%     trunc_pos_cell(i,:) = [org_pos_cell(i+15,1), org_pos_cell(i+15-8,2), org_pos_cell(i+15-15,3)];
% end
% 
% % take mean in x of scans containing seroma
% for i = 1:11
%     mean_pos_cell{i,1} = mean([trunc_pos_cell{i,1}(1), trunc_pos_cell{i,2}(1), trunc_pos_cell{i,3}(1)]);
% end
% mean_pos_mat = cell2mat(mean_pos_cell);

mean_pos_mat = panda_pos_test;

%% Contour Interpolation
%import images, preprocess, find contours, remove poor contours

genPnts_cell = ContourInterpolation2d(contourCell, num_points, mean_pos_mat);

%%
genPnts = cell2mat(genPnts_cell);
%%

% Input data (replace with your actual data)
originalPoints =genPnts(1:400,1:3); % N x 3 matrix
desiredRadius = 50; % Specify the desired smaller radius
newCentroid = [130 -81 0.0062-0.00125*1]; % Specify the new centroid location
% Compute the centroid of the points
centroid = mean(originalPoints);
% Calculate the distance between each point and the original centroid
distances = vecnorm(originalPoints - centroid, 2, 2);
% Calculate the scaling factor to reduce the radius
scalingFactor = desiredRadius / max(distances);
% Scale the points with respect to the original centroid
scaledPoints = centroid + scalingFactor * (originalPoints - centroid);
% Translate the scaled points to the new centroid location
translatedPoints1 = scaledPoints + (newCentroid - centroid);

% Input data (replace with your actual data)
originalPoints =genPnts(end-399:end,1:3); % N x 3 matrix
desiredRadius = 50; % Specify the desired smaller radius
newCentroid = [95 -93 0.0274+0.00125*1]; % Specify the new centroid location
% Compute the centroid of the points
centroid = mean(originalPoints);
% Calculate the distance between each point and the original centroid
distances = vecnorm(originalPoints - centroid, 2, 2);
% Calculate the scaling factor to reduce the radius
scalingFactor = desiredRadius / max(distances);
% Scale the points with respect to the original centroid
scaledPoints = centroid + scalingFactor * (originalPoints - centroid);
% Translate the scaled points to the new centroid location
translatedPoints2 = scaledPoints + (newCentroid - centroid);

% Input data (replace with your actual data)
originalPoints =genPnts(1:400,1:3); % N x 3 matrix
desiredRadius = 25; % Specify the desired smaller radius
newCentroid = [130 -81 0.0062-0.00125*2]; % Specify the new centroid location
% Compute the centroid of the points
centroid = mean(originalPoints);
% Calculate the distance between each point and the original centroid
distances = vecnorm(originalPoints - centroid, 2, 2);
% Calculate the scaling factor to reduce the radius
scalingFactor = desiredRadius / max(distances);
% Scale the points with respect to the original centroid
scaledPoints = centroid + scalingFactor * (originalPoints - centroid);
% Translate the scaled points to the new centroid location
translatedPoints3 = scaledPoints + (newCentroid - centroid);

% Input data (replace with your actual data)
originalPoints =genPnts(end-399:end,1:3); % N x 3 matrix
desiredRadius = 25; % Specify the desired smaller radius
newCentroid = [95 -93 0.0274+0.00125*2]; % Specify the new centroid location
% Compute the centroid of the points
centroid = mean(originalPoints);
% Calculate the distance between each point and the original centroid
distances = vecnorm(originalPoints - centroid, 2, 2);
% Calculate the scaling factor to reduce the radius
scalingFactor = desiredRadius / max(distances);
% Scale the points with respect to the original centroid
scaledPoints = centroid + scalingFactor * (originalPoints - centroid);
% Translate the scaled points to the new centroid location
translatedPoints4 = scaledPoints + (newCentroid - centroid);

% Assuming your contour points are stored in the variable 'contourPoints' (Nx2 matrix)

% Determine the minimum and maximum coordinates along each axis
minX = min(translatedPoints3(1:100, 1));
maxX = max(translatedPoints3(1:100, 1));
minY = min(translatedPoints3(1:100, 2));
maxY = max(translatedPoints3(1:100, 2));

% Define the spacing between grid points
gridSpacing = 1;  % Adjust the spacing as desired

% Generate a regular grid of points within the contour boundary
[xGrid, yGrid] = meshgrid(minX:gridSpacing:maxX, minY:gridSpacing:maxY);
gridPoints = [xGrid(:), yGrid(:)];

% Check if each grid point is inside the contour using inpolygon function
inContour = inpolygon(gridPoints(:, 1), gridPoints(:, 2), translatedPoints3(1:100, 1), translatedPoints3(1:100, 2));

% Keep only the points that are inside the contour
filledContourPoints1 = gridPoints(inContour, :);



% Determine the minimum and maximum coordinates along each axis
minX = min(translatedPoints4(1:100, 1));
maxX = max(translatedPoints4(1:100, 1));
minY = min(translatedPoints4(1:100, 2));
maxY = max(translatedPoints4(1:100, 2));

% Define the spacing between grid points
% gridSpacing = 1;  % Adjust the spacing as desired

% Generate a regular grid of points within the contour boundary
[xGrid, yGrid] = meshgrid(minX:gridSpacing:maxX, minY:gridSpacing:maxY);
gridPoints = [xGrid(:), yGrid(:)];

% Check if each grid point is inside the contour using inpolygon function
inContour = inpolygon(gridPoints(:, 1), gridPoints(:, 2), translatedPoints4(1:100, 1), translatedPoints4(1:100, 2));

% Keep only the points that are inside the contour
filledContourPoints2 = gridPoints(inContour, :);

filledContourPoints1(:,3) = translatedPoints3(1,3);
filledContourPoints1(:,4) = 0;
filledContourPoints2(:,3) = translatedPoints4(1,3);
filledContourPoints2(:,4) = 0;

% genPnts = [translatedPoints3 genPnts(1:400,4); filledContourPoints1; translatedPoints1 genPnts(1:400,4); genPnts; translatedPoints2 genPnts(end-399:end,4); translatedPoints4 genPnts(end-399:end,4); filledContourPoints2 ];
genPnts = [translatedPoints3 genPnts(1:400,4); translatedPoints1 genPnts(1:400,4); genPnts; translatedPoints2 genPnts(end-399:end,4); translatedPoints4 genPnts(end-399:end,4) ];

%%
%Rescale to real-world size (mm)
%if confused by which one is x and which is y, use plot3() on genPnts to
%visualize
temp = -genPnts(:,2); %has to be neg, otherwise rescales backwards
genPnts(:,2) = rescale(genPnts(:,1), 0, 31.6264); 
genPnts(:,1) = rescale(temp, 0, 26.5439);
genPnts(:,3) = genPnts(:,3).*1000;
mean_pos_mat = mean_pos_mat.*1000;
genPnts(:,3) = rescale(genPnts(:,3), 0 , (max(mean_pos_mat)-min(mean_pos_mat)));

%Testing
% genPnts(:,3) = rescale(genPnts(:,3), 0 , 40);
% genPnts(:,1) = rescale(genPnts(:,1), -40,40);
% genPnts(:,2) = rescale(genPnts(:,2), -40,40);
% genPnts(:,3) = rescale(genPnts(:,3), 0,200);

%Recenter
tenthSliceCentroid = mean(genPnts(3601:3700,1:2));
genPnts(:,1:2) = genPnts(:,1:2) - tenthSliceCentroid;
genPnts(:,3) = genPnts(:,3) - genPnts(3601,3);

%Reorient
temp = genPnts(:,3);
genPnts(:,3) = genPnts(:,2);
genPnts(:,2) = temp;


P = [repelem(1, size(genPnts,1))' genPnts(:,1:3)];
A = squareform(pdist(genPnts(:,1:3)));
Zero_mat = zeros(4,4);
Zero_col = zeros(4,1);
Pnts = [A P; P' Zero_mat];

f = genPnts(:,4);
Vals = [f; Zero_col];

coeffs = Pnts\Vals;
[lambda, c] = deal(coeffs(1:end-4), coeffs(end-3:end));

%volume of points where rbf is evaluated to find surface
testpntsx = min(genPnts(:,1)):0.7:max(genPnts(:,1)); %lowering number of testpnts could potentially be giving isosurface less area to get creative
testpntsy = min(genPnts(:,2)):0.7:max(genPnts(:,2));
testpntsz = min(genPnts(:,3)):0.7:max(genPnts(:,3));

[meshx, meshy, meshz] = meshgrid(testpntsx, testpntsy, testpntsz);
disp(size(meshx))
disp(size(meshx(:),1))

surface = zeros(size(meshx(:),1),1);

for i = 1:size(meshx(:),1)
    summation = 0;
    for j = 1:size(genPnts,1)
        summation = summation + lambda(j)*norm([meshx(i), meshy(i), meshz(i)]-genPnts(j,1:3)); 
    end
    poly = c(1) + c(2)*meshx(i) + c(3)*meshy(i) + c(4)*meshz(i);
    surface(i)=summation+poly;
end
surface = reshape(surface,size(meshx));

% plots the (meshx, meshy, meshz) where surface is 0
s = isosurface(meshx, meshy, meshz, surface, 0);

%%% Extracting surface %%%
% - can use triangulation() with isosurface() [faces, verts] outputs, followed
%by stlwrite() with triangulation output
% - best results with obj_write function
% >> obj_write(s, 'check')


breakpoint = 0;
% TESTING script
% poly = c(1) + c(2)*testpnt(1) + c(3)*testpnt(2) + c(4)*testpnt(3);
% sum = 0;
% for i = 1:size(genPnts,1)
% sum = sum + lambda(i)*norm(testpnt-genPnts(i,1:3));
% end
% sum+poly

%% Deprecated since onSurf/offSurf method

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
    zValues(i,1) = pos_cell{i+13,1}(1,1); %should be 15 but added two fake contours for interpolation error mitigation
end
zValues = rescale(zValues, 0, zValuesRescale);
zInt = linspace(min(zValues),max(zValues), contourLength); %points to interpolate at


%% Shape Interpolation - deprecated since onSurf/offSurf method

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
