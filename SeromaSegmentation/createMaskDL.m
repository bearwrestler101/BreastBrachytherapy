for i = 1:length(stitchedImages)
    img = stitchedImages{i};
    imshow(img)
    h = drawfreehand;
    bw = createMask(h);
    mask = bw(1:690, 1:690);
    imwrite(mask, "Masks/mask_"+i+".png")

    img = imadjust(img(1:690,1:690),[],[],0.4);
    imgMedFilt = medfilt2(img, [4 4]);
    imwrite(imgMedFilt,"Images/img_"+i+".png")
    close all;
end
%%
img = stitchedImages{2};
img = imadjust(img(1:690,1:690),[],[],0.5);
imgMedFilt = medfilt2(img, [4 4]);
imwrite(imgMedFilt, "wtf.png")

%%

img = imread("dataset_histograms\benign (20).png");
imwrite(img, "wtf.png")
figure
imhist(img)


