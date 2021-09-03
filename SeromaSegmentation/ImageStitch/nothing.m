
%For trial and error to figure out which images to stitch together
close all
figure('units','normalized','outerposition',[0 0 1 1])
frame = 20;
montage({image_cell{stitch_indices(frame,1),1}
    image_cell{stitch_indices(frame-8,2),1}
    image_cell{stitch_indices(frame-15,3),1}}, 'Size', [1 3])

% figure
% subplot(1,3,1)
% imshow(image_cell{stitch_indices(frame,1),1})
% subplot(1,3,2)
% imshow(image_cell{stitch_indices(frame-8,2),1})
% subplot(1,3,3)
% imshow(image_cell{stitch_indices(frame-15,3),1})
