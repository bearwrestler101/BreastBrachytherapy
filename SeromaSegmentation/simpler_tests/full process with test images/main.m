clear; clc; close all;
%% Constants

bi_thresh = 0.23;
min_contour_length = 400;
se_erode = strel('disk',4,6);
se_dilate = strel('disk',4,4); %should try octagon
num_points = 100;
epsilon = 1;
z_val = [0; 1; 2]; %this is seperation distance between slices
z_int = [0:0.05:2]; %points to evaluate interpolation at

%% Contour Interpolation - TEST IMAGES

%import images, preprocess, find contours, remove poor contours
seroma = imread('seroma.jpg');
seroma2 = imread('seroma2.jpg');
seroma3 = imread('seroma3.jpg');

seromas = {seroma; seroma2; seroma3};
contours_interp_all = cell(3,1); %!need to be able to take more than three contours
hold on
for k = 1:length(seromas)
    srma = seromas{k};
    seroma_pre = Preprocess(srma);
    [seroma_cont, contours] = Contour(seroma_pre, bi_thresh, se_erode, se_dilate);
    contours_good = IsContourGood(contours, min_contour_length);
    
    %interpolate and save interpolated contours
    contours_interp = ContourInterpolation2d(contours_good, num_points);
    contours_interp_all{k} = contours_interp{1};
end
hold off

%% Shape Interpolation

s_x = cell(num_points, 1);
s_y = cell(num_points, 1);
%rbf 3d interpolation as outlined by https://en.wikipedia.org/wiki/Radial_basis_function_interpolation
%interpolating x and y values given known z values
for i = 1:num_points
    f_x = [contours_interp_all{1}(i,:); contours_interp_all{2}(i,:); contours_interp_all{3}(i,:)];
    phi_mat = make_phi_mat(z_val, epsilon);
    w = phi_mat\f_x;
    [s_x{i,1}, s_y{i,1}] = fnc_gen(z_int, z_val, w, epsilon);
end
hold on
%plot interpolated 3d curves
for i = 1:length(s_x)
    plot3(z_int, s_x{i,1},s_y{i,1},'Linewidth', 2)
end
%plot interpolated 2d slices
for k = 1:length(contours_interp_all)
    cnt_int = contours_interp_all{k};
    plot3(z_val(k,1)*ones(length(cnt_int),1), cnt_int(:,1), cnt_int(:,2), 'b', 'Linewidth', 3);
end

%create vectors from cells
s_x_surf = cell2mat(s_x);
s_y_surf = cell2mat(s_y);
z_int_surf = repmat(z_int, 1, length(s_x)).';

figure;
hold on
tri_check = CreateTriangles(num_points, length(z_int));
%z multiplied by 100 so stl has normal appearance
fv = trimesh(tri_check, z_int_surf.*100, s_x_surf, s_y_surf);

stlwrite('seroma.stl', fv.Faces, fv.Vertices);

%% Shape Interpolation Graveyard
% %Various shape creation methods

% %ALPHASHAPE
% test = [100.*z_int_surf, s_x_surf, s_y_surf];
% figure;
% plot3(test(:,1), test(:,2), test(:,3), '.');
% axis equal
% grid on
% shp = alphaShape(test(:,1), test(:,2), test(:,3), 100);
% plot(shp)
% axis equal
% %minimum alphas
%a = criticalAlpha(shp,'all-points')
%a = criticalAlpha(shp,'one-region')

% %CONVHUL
% %creates a rigid shape without any indents
% [k1, av1] = convhull(100.*z_int_surf, s_x_surf, s_y_surf);
% figure;
% trisurf(k1, 100.*z_int_surf, s_x_surf, s_y_surf, 'FaceColor','cyan');
% axis equal

% %FILL3
% %had to reverse every second curve because otherwise it was filling from end of first to start of second
% %so i thought it would work if i basically gave it rectangles to fill but still didn't really work
% [x, y, z] = fill3_prep(s_x, s_y, z_int);
% figure;
% fill3(z, x, y, 'r')

%BOUNDARY
%creates a rigid shape without any indents
% figure;
% bound = boundary(z_int_surf, s_x_surf, s_y_surf);
% trisurf(bound, z_int_surf, s_x_surf, s_y_surf, 'Facecolor','red', 'FaceAlpha', 0.3);


