function contourCell = ActiveContour(startPointFrame, midPointFrame, endPointFrame, stitchedImages, pos_cell)

close all; clc;

% will eventually turn into a function that will receive stitchedimages

% preprocessing factors
bithresh = 0.25;
seDilate = strel('disk', 1,0);
seErode = strel('disk', 2,4);

% active contouring factors
numIterations = 800;
smoothFactor = 5;
contractionBias = -1.2;

% active contour middle frame
image = Preprocess(stitchedImages{midPointFrame}, bithresh, seDilate, seErode);

figure
imshow(image);
rectangle = drawfreehand;
mask = createMask(rectangle);
bw = activecontour(image, mask, numIterations, 'edge', 'SmoothFactor', smoothFactor, 'ContractionBias', -0.8);
midbw = bw;

% find CoM of the active contour
props = regionprops(bw, 'Centroid');
xCOM = props.Centroid(1);
yCOM = props.Centroid(2);

% view resultant contour and COM
figure
imshow(image)
hold on
visboundaries(bw, 'Color', 'r');
plot(xCOM, yCOM, 'r+', 'Markersize', 30, 'Linewidth', 2);

% obtain endpoints for fishing wire
figure
imshow(stitchedImages{startPointFrame})
startPoint = drawpoint;
figure
imshow(stitchedImages{endPointFrame})
endPoint = drawpoint; 

% create 3 3D points - 2 for endpoints, 1 for COM of midpoint
startPoint = [startPoint.Position(1,1), startPoint.Position(1,2), pos_cell{startPointFrame}(1,1)];
midPoint = [xCOM, yCOM, pos_cell{midPointFrame}(1,1)];
endPoint = [endPoint.Position(1,1), endPoint.Position(1,2), pos_cell{endPointFrame}(1,1)];

% initialize contour collection and record the middle contour
contourCell = cell(endPointFrame - startPointFrame - 1, 1);
contour = bwboundaries(bw);
contourCell{6,1} = contour{1,1};

% active contouring for frames between middle and first
for i = midPointFrame-1:-1:startPointFrame+1
    
    % scale down contour and pad with zeros to match bw size
    bwSmall = imresize(bw, 0.7);
    zh = zeros(size(bw,1)-size(bwSmall,1),size(bwSmall,2));
    bwSmall = vertcat(bwSmall, zh);
    zv = zeros(size(bwSmall,1), size(bw,2)-size(bwSmall, 2));
    bwSmall = horzcat(bwSmall, zv);
    
    %find COM of scaled down contour
    props = regionprops(bwSmall, 'Centroid');
    xCOM = props.Centroid(1);
    yCOM = props.Centroid(2);
    
    % update frame, get next points along fishing wire
    % translate COM of refernece contour to new fishing wire location for active contouring
    % (accounts for seroma shift in subsequent frames)
    currentFrame = i;
    [xf, yf] = FishWire(startPoint, midPoint, endPoint, pos_cell, midPointFrame, currentFrame);
    bwTranslated = imtranslate(bwSmall, [xf-xCOM, yf-yCOM]);
     
    % active contour current frame
    image = Preprocess(stitchedImages{currentFrame}, bithresh, seDilate, seErode);
    mask = bwTranslated;
    bw = activecontour(image, mask, numIterations, 'edge', 'SmoothFactor', smoothFactor, 'ContractionBias', contractionBias);

    % contour bw and record
    contour = bwboundaries(bw);
    contourCell{i-1,1} =  contour{1,1};
    
    % show current frame, new active contour, old active contour
    figure
    imshow(image)
    hold on
    visboundaries(bw, 'Color', 'r');
    visboundaries(mask, 'Color', 'b');
end

% reset reference for active contour
bw = midbw;

% active contouring for frames between middle and last - same process
for i = midPointFrame+1:1:endPointFrame-1
        
    bwSmall = imresize(bw, 0.7);
    zh = zeros(size(bw,1)-size(bwSmall,1),size(bwSmall,2));
    bwSmall = vertcat(bwSmall, zh);
    zv = zeros(size(bwSmall,1), size(bw,2)-size(bwSmall, 2));
    bwSmall = horzcat(bwSmall, zv);
    
    props = regionprops(bwSmall, 'Centroid');
    xCOM = props.Centroid(1);
    yCOM = props.Centroid(2);
    
    currentFrame = i;
    [xf, yf] = FishWire(startPoint, midPoint, endPoint, pos_cell, midPointFrame, currentFrame);
    bwTranslated = imtranslate(bwSmall, [xf-xCOM, yf-yCOM]);
    
    image = Preprocess(stitchedImages{currentFrame}, bithresh, seDilate, seErode);
    mask = bwTranslated;
    bw = activecontour(image, mask, numIterations, 'edge', 'SmoothFactor', smoothFactor, 'ContractionBias', contractionBias);

    contour = bwboundaries(bw);
    contourCell{i-1,1} =  contour{1,1};
    
    figure
    imshow(image)
    hold on
    visboundaries(bw, 'Color', 'r');
    visboundaries(mask, 'Color', 'b');
end

% % plot contours - need 3rd dimension
% figure
% hold on
% for i = 1:size(contourCell,1)
%     plot(contourCell{i}(:,2), -contourCell{i}(:,1))
% end

end
