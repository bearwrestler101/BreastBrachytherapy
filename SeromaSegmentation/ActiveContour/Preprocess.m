function O = Preprocess(I, bithresh, seDilate, seErode)
%preprocess image for contouring

I = imsharpen(I);

I = imadjust(I, [0.0 0.45], []); %get rid of specks
% I = imadjust(I, [0.05 0.5], []); %brighten remaining

% I = imbinarize(I, bithresh);
% I = im2uint8(I);
% I = imdilate(I, seDilate );
I = imerode(I, seErode);
I = imadjust(I, [0 0.6],[]);

O = I;

end