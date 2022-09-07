predImglist = natsortfiles(dir("predictions/*.png"));
predImg=cell(1,length(predImglist));

for i=1:length(predImglist)
  predImg{i}=imread("predictions/"+predImglist(i).name);
end

im = predImg{1};
im = imbinarize(im);
S = regionprops(im, 'BoundingBox');

imshow(im)

rectangle(imgca, 'Position',S.BoundingBox, 'EdgeColor','r');