function O = Preprocess(I)
%preprocess image for contouring
bithresh = 0.2;
seDilate = strel('disk', 2,4);
seErode = strel('disk', 3,4);

% I = imsharpen(I);
I = imadjust(I, [0.0 0.45], []); %get rid of specks
% I = imadjust(I, [0.05 0.5], []); %brighten remaining
I = imbinarize(I, bithresh);
I = im2uint8(I);
I = imdilate(I, seDilate );
% I = imerode(I, seErode);
I = imadjust(I, [0 0.6],[]);

% bw blurring
windowSize=12;  % Decide as per your requirements
kernel=ones(windowSize)/windowSize^2;
result=conv2(single(I),kernel,'same');
result=result>0.5;
I(~result)=0; 


O = I;

end