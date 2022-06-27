for i = 1:length(stitchedImages)
    imshow(stitchedImages{i})
    h = drawfreehand;
    bw = createMask(h);
    imwrite(bw, "Masks/mask_"+i+".png")
    imwrite(stitchedImages{i},"Images/img_"+i+".png")

img = imread("testimg.png");
h = drawfreehand;

bw = createMask(h);
imwrite(bw, "testimgMask.png")

blk = img - im2uint8(bw);
imwrite(blk, "testimgBlk.png")

imgMedFilt = medfilt2(img, [4 4]);
imwrite(imgMedFilt, "testimgMed.png")
%% 