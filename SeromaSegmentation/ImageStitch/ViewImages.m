% script to watch all images from the recorded paths

%run Prep.m first

y = 1;
% short_path = 26;
% long_path = 36;
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
