function O = Preprocess(I)

%preprocess image - grayscale, sharpen, equalize histogram
I = rgb2gray(I);
I = imsharpen(I);
I = histeq(I);
O = I;

end