clear; clc; close all;

%based on: https://www.mathworks.com/help/vision/ug/feature-based-panoramic-image-stitching.html

%%% TO DO %%%
% - probably need to turn into a function
% - need to change how images are brought in

currentfolder = 'C:\Users\Admin\Documents\Kirill\Seroma Segmentation\Seroma Segmentation\simpler_tests\image stitch';
seromaDir = fullfile(currentfolder);
seromaImg = imageDatastore(seromaDir);

I = readimage(seromaImg, 1); 
gray_seroma = rgb2gray(I);

points = detectSURFFeatures(gray_seroma);
[features, points] = extractFeatures(gray_seroma, points);

numImages = numel(seromaImg.Files);
tforms(numImages) = projective2d(eye(3));

% find matching features between adjacent images and compute each image's
% cumulative transformation relative to the first one
for n = 2:numImages
    pointsPrevious = points;
    featuresPrevious = features;
    
    I = readimage(seromaImg, n);
    
    gray_seroma = rgb2gray(I);
    
    points = detectSURFFeatures(gray_seroma);
    [features, points] = extractFeatures(gray_seroma, points);
    
    indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
    
    matchedPoints = points(indexPairs(:,1), :);
    matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);
    
    figure;
    showMatchedFeatures(gray_seroma, gray_seroma, matchedPointsPrev, matchedPoints);
    
    tforms(n) = estimateGeometricTransform(matchedPoints, matchedPointsPrev,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);
    tforms(n).T = tforms(n).T * tforms(n-1).T;
end

imageSize = size(gray_seroma);

for i = 1:numel(tforms)           
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(1,2)], [1 imageSize(1,1)]);
end

% Find the minimum and maximum output limits. 
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width 3], 'like', I);

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);


% Create the panorama.
for i = 1:numImages
    
    I = readimage(seromaImg, i);   
   
    % Transform I into the panorama.
    warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);
                  
    % Generate a binary mask.    
    mask = imwarp(true(size(I,1),size(I,2)), tforms(i), 'OutputView', panoramaView);
    
    % Overlay the warpedImage onto the panorama.
    panorama = step(blender, panorama, warpedImage, mask);
end

figure
imshow(panorama)
