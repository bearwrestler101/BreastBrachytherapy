clc; close all; clearvars -except out;

% extracts relevant index/image/pos from raw data
[index_cell, image_cell, pos_cell] = Prep_pt2pt(out);

%%% THE CODE BELOW IS FOR REMOVING DUPLICATES %%%
% should be able to remove when scanning procedure is good - likely can be
% fixed by delaying shutter_fb input from US PC to panda PC

iLog = zeros(size(index_cell,1),1);
for i = 2:size(pos_cell,1)
    if round(pos_cell{i-1}(1,1),3) == round(pos_cell{i}(1,1),3)
        iLog(i,1) = i;
    end
end
iLog = iLog(all(iLog, 2));
for i = 1:size(iLog,1)
    index_cell(iLog(i,1),1) = 0;
    pos_cell{iLog(i,1),1} = [];
    image_cell{iLog(i,1),1} = [];
end

%-------%

% remove empties
index_cell = index_cell(all(index_cell, 2));
pos_cell = pos_cell(~cellfun('isempty',pos_cell));
image_cell = image_cell(~cellfun('isempty',image_cell));

% returns a matrix of indices reorganized to fit scanning path
stitch_indices = ImagesForStitch(index_cell, pos_cell);

% stitches images together
stitchedImages = cell(size(stitch_indices,1)-15,1);
for i = 16:size(stitch_indices,1)
    stitchedImages{i-15} = TemplateMatching(i,stitch_indices, image_cell);
end

% pads stitched images to make same size
yMax = max(cellfun('size', stitchedImages,1));
xMax = max(cellfun('size', stitchedImages,2));
for i = 1:size(stitchedImages)
    stitchedImages{i} = padarray(stitchedImages{i}, [yMax-size(stitchedImages{i},1)...
        xMax-size(stitchedImages{i},2)],'post');
end

% active contouring stitched images - hard coded frames
startPointFrame = 1;
midPointFrame = 7;
endPointFrame = 13;
contourCell = ActiveContour(startPointFrame, midPointFrame, endPointFrame,stitchedImages, pos_cell);

% 2D contour and 3D shape interpolation
[triangles, surfaceCoords] = ShapeInterpolation(contourCell, pos_cell);

figure
hold on
fv = trimesh(triangles, surfaceCoords(:,3), surfaceCoords(:,1), surfaceCoords(:,2));

stlwrite('seroma.stl', fv.Faces, fv.Vertices);


