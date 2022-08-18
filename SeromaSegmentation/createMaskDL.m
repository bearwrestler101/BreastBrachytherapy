imsize = 256;

% for i = 1:length(stitchedImages)
for i = 1:13

    img = stitchedImages{i};
    imshow(img)
    h = drawfreehand;
    bw = createMask(h);
    mask = bw(1:690, 1:690);
    mask = imresize(mask, [imsize, imsize]);
    imwrite(mask, "collected_masks/mask_"+i+".png")

    img = imadjust(img(1:690,1:690),[],[],0.4);
    img = medfilt2(img, [4 4]);
    img = imresize(img, [imsize, imsize]);
    imwrite(img,"collected_images/img_"+i+".png")
    close all;
end
%%
img = stitchedImages{2};
img = imadjust(img(1:imsize,1:imsize),[],[],0.5);
imgMedFilt = medfilt2(img, [4 4]);
imwrite(imgMedFilt, "wtf.png")

%%
imsize = 256; % pay attention to how image sizes are changed
snpNoise = zeros(round(imsize*1), round(imsize*0.3));
rng('shuffle');
row = randi([1 size(snpNoise,1)],1,200);
column = randi([1 size(snpNoise,2)],1,200);
for i=1:size(row,2)
    snpNoise(row(i),column(i)) = 1;
    
    if row(i)>3 && row(i) <=size(snpNoise,1)-3 && column(i)>3 && column(i)<=size(snpNoise,2)-3 && rand > 0.6
        rowExtra = randi([-3 3], [3 1]);
        columnExtra = randi([-3 3], [3 1]);
        for j = 1:size(rowExtra,1)
            snpNoise(row(i)+rowExtra(j),column(i)+columnExtra(j)) = 1;
        end
    end


end
snpNoise = imresize(snpNoise,[imsize, imsize]);
snpNoise = uint8(255 * mat2gray(snpNoise,[0 1]));
snpNoise = imgaussfilt(snpNoise,1);
imshow(snpNoise);

