function [O, contours] = Contour(I, bi_thresh, se_erode, se_dilate)
    
%obtain contours - binarize, invert, erode, dilate, find contours

I = imbinarize(I, bi_thresh);
I = imcomplement(I);
%I = imfill(I, 'holes'); %commented b/c goes a little too far
I = imclearborder(I); %might need to remove as seroma might be at edge
I = imerode(I, se_erode);
I = imdilate(I, se_dilate);
contours = bwboundaries(I);
O = I;

end