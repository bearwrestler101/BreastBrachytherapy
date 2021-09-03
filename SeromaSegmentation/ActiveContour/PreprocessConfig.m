close all

%for quick Preprocess checks%


%preprocess image for contouring

bithresh = 0.25;
seDilate = strel('disk',1,0);
seErode = strel('disk', 2,4);
I = image_cell{endPointFrame-1}; 

I = imsharpen(I);

I = imadjust(I, [0.0 0.45], []); %get rid of specks
% I = imadjust(I, [0.05 0.5], []); %brighten remaining

% I = imbinarize(I, bithresh);
% I = im2uint8(I);
% I = imdilate(I, seDilate );
I = imerode(I, seErode);
I = imadjust(I, [0 0.6],[]);

figure
imshowpair(I, image_cell{endPointFrame-1}, 'montage')
