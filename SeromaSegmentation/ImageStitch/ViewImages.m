%% Watch all images from the recorded paths - hard coded frames

y = 1;
while y==1
    x = input('which video\n');
    close all;
    if x == 1
        for i = 1:41    
            imshow(image_cell{i})
        end
    elseif x == 2
        for i = 42:98
            imshow(image_cell{i})
        end
    elseif x == 3
        for i = 98:139
            imshow(image_cell{i})
        end    
    end
    y = input('do you want to keep watching - 1/0\n');
end


%% For trial and error to figure out which images to stitch together
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

