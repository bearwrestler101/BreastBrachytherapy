% function panorama = ImageStitch (image_cell, stitch_indices)
% close all;
%based on: https://www.mathworks.com/help/vision/ug/feature-based-panoramic-image-stitching.html

%%% TO DO %%%
% - adjust stitch_indices to accomodate for frame lineups

frame = 28;
seromaImg = {image_cell{stitch_indices(frame, 1),1}(:,420:end); 
    image_cell{stitch_indices(frame-8, 2)}(:,1:190);
    image_cell{stitch_indices(frame-15, 3) ,1}};
figure
montage({Preprocess(seromaImg{1}), Preprocess(seromaImg{2}), Preprocess(seromaImg{3})})

seroma = seromaImg{1}; 
seroma = Preprocess(seroma);

% gray_seroma = imcomplement(gray_seroma);

points = detectSURFFeatures(seroma);
[features, points] = extractFeatures(seroma, points);

numImages = size(seromaImg,1);
tforms(numImages) = projective2d(eye(3));

% find matching features between adjacent images and compute each image's
% cumulative transformation relative to the first one
for n = 2:numImages
    pointsPrevious = points;
    featuresPrevious = features;
    seroma_prev = seroma;
    seroma = seromaImg{n};
    seroma = Preprocess(seroma);

    points = detectSURFFeatures(seroma);
    [features, points] = extractFeatures(seroma, points);
    
    indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
    
    matchedPoints = points(indexPairs(:,1), :);
    matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);
    
    figure;
    showMatchedFeatures(seroma_prev, seroma, matchedPointsPrev, matchedPoints);
    
    tforms(n) = estimateGeometricTransform(matchedPoints, matchedPointsPrev,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);
    tforms(n).T = tforms(n).T * tforms(n-1).T;
end

imageSize = size(seroma);

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
seroma = uint8(seroma);
panorama = zeros([height width 3], 'like', seroma);

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.
for i = 1:numImages
    
    I = seromaImg{i};   
    I = cat(3, I, I, I);
    % Transform I into the panorama.
    warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);
                  
    % Generate a binary mask.    
    mask = imwarp(true(size(I,1),size(I,2)), tforms(i), 'OutputView', panoramaView);
    
    % Overlay the warpedImage onto the panorama.
    panorama = step(blender, panorama, warpedImage, mask);
end

% figure
% imshow(panorama)

% end
