function stitch_indices = ImagesForStitch(index_cell, pos_cell)

%Organizes image and position indexes by paths

% determine when path switches direction based on y value change
path_switch = zeros(size(index_cell ,1), 2);
for i = 1:size(pos_cell,1)-1
   if round(pos_cell{i}(2),3) ~= round(pos_cell{i+1}(2),3)
       path_switch(i,2) =  i;
   end
end
% remove 0's
path_switch = path_switch(path_switch~=0);

% remove all entries of long path that are outside the short paths
% based on x position
indexCorrection=size(pos_cell,1);
for i = 1:size(pos_cell)
    if round(pos_cell{i}(1,1),3)<round(pos_cell{path_switch(1,1)}(1,1),3) ||...
            round(pos_cell{i}(1,1),3)>round(pos_cell{path_switch(2,1)+1}(1,1),3)
        continue
    end
    indexCorrection(i) = i;
end
% remove 0's
indexCorrection = indexCorrection(indexCorrection~=0);


%create index array that is ready for stitching
stitch_indices = zeros(path_switch(1,1), 3);
fillMatrix = 0;
for j = 1:size(stitch_indices,2)
    for i = 1:path_switch(1,1)
        fillMatrix = fillMatrix+1;
        stitch_indices(i,j) = indexCorrection(fillMatrix);
    end
end
% flip middle path
stitch_indices = [stitch_indices(:,1) flipud(stitch_indices(:,2)) stitch_indices(:,3)];
end

% 
% %For trial and error to figure out which images to stitch together
% close all
% figure('units','normalized','outerposition',[0 0 1 1])
% frame = 36;
% montage({image_cell{stitch_indices(frame,1),1}
%     image_cell{stitch_indices(frame-6,2),1}
%     image_cell{stitch_indices(frame-7,2),1}
%     image_cell{stitch_indices(frame-8,2),1}
%     image_cell{stitch_indices(frame-9,2),1}}, 'Size', [1 5])
% 


