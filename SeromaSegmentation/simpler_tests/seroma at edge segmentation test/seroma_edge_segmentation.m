clc; clear; close all;


bi_thresh = 0.23;
se_erode = strel('disk',4,6);
se_dilate = strel('disk',4,4);
min_contour_length = 400;

seroma_edge = imread('seroma_edge.jpg');
seroma_edge = Preprocess(seroma_edge);
[seroma_cont, contours] = Contour(seroma_edge, bi_thresh, se_erode, se_dilate);
contours_good = IsContourGood(contours, min_contour_length);

imshow(seroma_cont);
hold on

plot(contours_good{1}(:,2), contours_good{1}(:,1), 'Linewidth', 3)