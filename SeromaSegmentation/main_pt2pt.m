clc; close all;
%% Constants
%constants
bi_thresh = 0.48;
min_contour_length = 400;
se_erode = strel('octagon',6);
se_dilate = strel('octagon',6);
num_points = 100;
epsilon = 1;
z_val = [0; 1; 2]; %seperation distance between slices
z_int = [0:0.05:2]; %points to evaluate interpolation at
num_images = size(image_cell, 1);

%% Contour Interpolation
%import images, preprocess, find contours, remove poor contours
long_path = 36;
us_scans = cell(long_path, 1);
%loads only second scanning path - ideally would be loading stitched image
for i = 27:62
    us_scans{i-26} = image_cell{i};
end

contours_interp_all = cell(num_images,1);
for k = 1:size(us_scans, 1)
    seroma_pre = Preprocess(us_scans{k});
    [seroma_cont, contours] = Contour(seroma_pre, bi_thresh, se_erode, se_dilate);
    contours_good = IsContourGood(contours, min_contour_length);
    
    %interpolate and save interpolated contours
    contours_interp = ContourInterpolation2d(contours_good, num_points);
    contours_interp_all{k,1} = contours_interp{1,1};
end
hold off



contours_interp_all = contours_interp_all(~cellfun('isempty',contours_interp_all));

figure
for i = 1:size(contours_interp_all,1)
    plot(contours_interp_all{i}(:,1), contours_interp_all{i}(:,2)); 
    hold on
end

%% Shape Interpolation

s_x = cell(num_points, 1);
s_y = cell(num_points, 1);
f_x = zeros(length(contours_interp_all),2);

%rbf 3d interpolation as outlined by https://en.wikipedia.org/wiki/Radial_basis_function_interpolation
%interpolating x and y values given known z values
for i = 1:num_points
    for j = 1:length(contours_interp_all)
        f_x(j,:) = contours_interp_all{j}(i,:);
    end
    phi_mat = make_phi_mat(z_val, epsilon);
    w = phi_mat\f_x;
    [s_x{i,1}, s_y{i,1}] = fnc_gen(z_int, z_val, w, epsilon);
end
hold on
%plot interpolated 3d curves
for i = 1:length(s_x)
    plot3(z_int, s_x{i,1}, s_y{i,1},'Linewidth', 2)
end
%plot interpolated 2d slices
for k = 1:length(contours_interp_all)
    cnt_int = contours_interp_all{k};
    plot3(z_val(k,1)*ones(length(cnt_int),1), cnt_int(:,1), cnt_int(:,2), 'b', 'Linewidth', 3);
end

%create vectors 
s_x_surf = cell2mat(s_x);
s_y_surf = cell2mat(s_y);
z_int_surf = repmat(z_int, 1, length(s_x)).';

figure;
hold on
triangles = CreateTriangles(num_points, length(z_int));
trimesh(triangles, z_int_surf, s_x_surf, s_y_surf);
