function [triangles, surfaceCoords] = ShapeInterpolation(contourCell, pos_cell, org_pos_cell)

%need to figure out best epislon and rbf function
%need to figure out most accurate inter-slice distance


%% Constants
%constants
num_points = 100;
epsilon = 0.2; %%%EDIT TO IMPROVE FIT%%%
zValuesRescale = 60; %60 is probably wrong, need some sort of calibration
contourLength = 80;

%% Interslice distances (z-values) - TODO maybe put this in main?
trunc_pos_cell = cell(11,3); 
mean_pos_cell= cell(11,1);

% offsets are hardcoded (see ImagesForStitch.m)
% obtain pos of scans containing seroma (hardcoded)
for i = 1:size(trunc_pos_cell,1)
    trunc_pos_cell(i,:) = [org_pos_cell(i+15,1), org_pos_cell(i+15-8,2), org_pos_cell(i+15-15,3)];
end

% take mean in x of scans containing seroma
for i = 1:11
    mean_pos_cell{i,1} = mean([trunc_pos_cell{i,1}(1), trunc_pos_cell{i,2}(1), trunc_pos_cell{i,3}(1)]);
end
mean_pos_mat = cell2mat(mean_pos_cell);

%% Contour Interpolation
%import images, preprocess, find contours, remove poor contours

genPnts_cell = ContourInterpolation2d(contourCell, num_points, mean_pos_mat);

%%
genPnts = cell2mat(genPnts_cell);

P = [repelem(1, size(genPnts,1))' genPnts(:,1:3)];
A = squareform(pdist(genPnts(:,1:3)));
Zero_mat = zeros(4,4);
Zero_col = zeros(4,1);
Pnts = [A P; P' Zero_mat];

f = genPnts(:,4);
Vals = [f; Zero_col];

coeffs = Pnts\Vals;
[lambda, c] = deal(coeffs(1:end-4), coeffs(end-3:end));

testpntsx = min(genPnts(:,1)):1:max(genPnts(:,1));
testpntsy = min(genPnts(:,2)):1:max(genPnts(:,2));
testpntsz = min(genPnts(:,3)):0.001:max(genPnts(:,3));

[meshx, meshy, meshz] = meshgrid(testpntsx, testpntsy, testpntsz);

% poly = c(1) + c(2)*meshx + c(3)*meshy + c(4)*meshz;
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

breakpoint = 0;

% TESTING script
% poly = c(1) + c(2)*testpnt(1) + c(3)*testpnt(2) + c(4)*testpnt(3);
% sum = 0;
% for i = 1:size(genPnts,1)
% sum = sum + lambda(i)*norm(testpnt-genPnts(i,1:3));
% end
% sum+poly

%%
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
