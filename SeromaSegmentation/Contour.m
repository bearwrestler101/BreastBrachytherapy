function [O, contours] = Contour(I, bi_thresh, se_erode, se_dilate)
    
%obtain contours - binarize, invert, erode, dilate, find contours

I = imbinarize(I, bi_thresh);
I = imcomplement(I);
I = imerode(I, se_erode);
I = imfill(I, 'holes');
% I = imclearborder(I); %might need to remove as seroma might be at edge
I = imdilate(I, se_dilate);
contours = bwboundaries(I);

O = I;

end