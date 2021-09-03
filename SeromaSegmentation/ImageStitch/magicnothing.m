canvas1 = uint8(zeros(100));
canvas2 = canvas1;
image1=uint8(magic(30));
canvas1(20:49,20:49)=image1;
image2=uint8(magic(30));
canvas2(30:59,30:59)=image2;
canvas = canvas1 + canvas2;
overlap = canvas1 & canvas2;
canvas(overlap) = canvas(overlap)/2;

close all
figure
imshow(canvas)