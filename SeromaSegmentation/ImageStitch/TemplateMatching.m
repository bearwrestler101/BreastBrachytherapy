function canvas = TemplateMatching(frame, stitch_indices, image_cell)

close all; 
% 1->2 -8
% 2->3 -7

tMatcher = vision.TemplateMatcher;

% release(tMatcher)

%load images
%last 5 columns taken out because ROI in US capture wasn't set correctly
firstImage = image_cell{stitch_indices(frame,1),1}(:,2:end-5);
secondImage = image_cell{stitch_indices(frame-8,2),1}(:,2:end-5);
thirdImage = image_cell{stitch_indices(frame-15, 3),1}(:,2:end-5);

%set image to be searched and template - hard coded areas
Image = secondImage(:, 1:190);
Template = firstImage(15:650,440:610);

%template matching
location = tMatcher(Image, Template);

%find centered upper-left cell in Template
[sx, sy] = size(Template);
centerUL = ceil([sy sx]/2);

%add back rows that got were cropped out for centered upper-left cell of
%entire image
corrected = [centerUL(1)+439 centerUL(2)+14];

% for moving second image to align matching point
yAdjust = abs(corrected(2) - location(2));
xAdjust = abs(corrected(1) - location(1));


%create canvases and fill with images
canvas1 = uint8(zeros(size(firstImage,1)+yAdjust, size(firstImage,2)+xAdjust));
canvas2 = canvas1;
canvas1(1:size(firstImage,1), 1:size(firstImage,2))=firstImage;

if yAdjust==0, yAdjust=1; end
if xAdjust==0, xAdjust=1; end

canvas2(yAdjust:yAdjust+size(secondImage,1)-1, xAdjust:xAdjust+size(secondImage,2)-1)=secondImage;

%add canvases, find overlap, average pixels within overlap
canvas = canvas1+canvas2;
overlap = canvas1 & canvas2;
canvas(overlap) = canvas(overlap)/2;

%set image to be searched and and templated - hard coded
Image = thirdImage(:, 1:190);
Template = canvas2(15:650, end-175:end-5);

%template matching
location = tMatcher(Image, Template);

%find centered upper-left cell in Template
[sx, sy] = size(Template);
centerUL = ceil([sy sx]/2);

%this makes sense if you draw it out
corrected = [centerUL(1)+size(canvas2,2)-175 centerUL(2)+14];

% for moving third image to align matching point
yAdjust = abs(corrected(2) - location(2));
xAdjust = abs(corrected(1) - location(1));

%create canvas and fill with third image
canvas3 = uint8(zeros(size(firstImage,1)+yAdjust, size(firstImage,2)+xAdjust));

if yAdjust==0, yAdjust=1; end
if xAdjust==0, xAdjust=1; end

canvas3(yAdjust:yAdjust+size(thirdImage,1)-1, xAdjust:xAdjust+size(thirdImage,2)-1)=thirdImage;

%canvas is padded to match sizing and assigned to canvas2
canvas2 = padarray(canvas, [size(canvas3,1)-size(canvas,1) size(canvas3,2)-size(canvas,2)],'post');

%add canvases, find overlap, average pixels within overlap
canvas = canvas2 + canvas3;
overlap = canvas2 & canvas3;
canvas(overlap) = canvas(overlap)/2;


end
