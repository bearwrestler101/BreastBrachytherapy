function O = Preprocess(I)
%%% OUTDATED %%%

%preprocess image for contouring

%I = rgb2gray(I); %uncomment for non-greyscaled images
I = imsharpen(I);

%two imadjust() to first highlight more sections then to get rid of excess
I = imadjust(I, [0.01 0.6], []); %get rid of specks
I = imadjust(I, [0.025 0.4], []); %brighten remaining



%two blurring methods
% I = imgaussfilt(I, 1.5);

%https://www.mathworks.com/matlabcentral/answers/305707-mean-of-neighbor-pixel
% k=[1 1 1; 1 0 1; 1 1 1]/800;
% I = conv2(double(I),k,'same');



O = I;

end