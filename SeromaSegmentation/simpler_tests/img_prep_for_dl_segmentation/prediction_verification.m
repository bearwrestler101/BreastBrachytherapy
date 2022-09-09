predImglist = natsortfiles(dir("predictions/*.png"));

[predImg,S,CC]=deal(cell(size(predImglist, 1), 1));
allPreds = cell(3,size(predImglist,1));

for i=1:length(predImglist)
  predImg{i}=imbinarize(imread("predictions/"+predImglist(i).name));  
end

%regionprops and bwconncomp for each image
for i=1:length(predImg)
    im = predImg{i};
    S{i} = regionprops(im, 'Area', 'Centroid', 'BoundingBox', 'MajorAxisLength','Extent','Solidity');
    CC{i} = bwconncomp(im);
end

%copy regionprops stats for biggest areas from each image to a new cell
for i = 1:length(predImg)
    [toss,bigBlob] = max(vertcat(S{i}.Area));
    tempCell = struct2cell(S{i});
    for j = 1:size(tempCell,1)
        allPreds{j,i} = tempCell{j,bigBlob};
    end
end


%% Check for good and bad predictions





minArea = 1000;
maxObj = 1;
forbidden_list = [];
for i = 1:size(allPreds,2)
    if allPreds{1,i} < minArea
        forbidden_list = [forbidden_list i];
        continue
    end

    tempCell = struct2cell(S{i});
    if bwconncomp(predImg{i}).NumObjects > maxObj
        disp("Multiple Areas Detected")

        predImg{i} = santas_list(predImg{i},tempCell);
    else
        predImg{i} = imfill(predImg{i},'holes');
    end

end



% imshow(im)
% rectangle(imgca, 'Position',S.BoundingBox, 'EdgeColor','r');

