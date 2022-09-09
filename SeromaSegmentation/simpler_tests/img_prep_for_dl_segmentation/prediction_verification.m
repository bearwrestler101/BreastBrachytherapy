predImglist = natsortfiles(dir("predictions/*.png"));

[predImg,S,CC]=deal(cell(size(predImglist, 1), 1));
allPreds = cell(3,size(predImglist,1));

for i=1:length(predImglist)
  predImg{i}=imread("predictions/"+predImglist(i).name);  
end

%regionprops and bwconncomp for each image
for i=1:length(predImg)
    im = predImg{i};
    im = imbinarize(im);
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

%might need to move above allPreds


[sumCent,meanCent] = deal(zeros(1,2));
for i = 1:size(allPreds,2)
    sumCent(1,1) = sumCent(1,1)+allPreds{2,i}(1);
    sumCent(1,2) = sumCent(1,2)+allPreds{2,i}(2);
end

meanCent(1,1) = sumCent(1,1)/size(allPreds,2);
meanCent(1,2) = sumCent(1,2)/size(allPreds,2);

minArea = 1000;
maxObj = 1;
for i = 1:size(allPreds,2)
    if allPreds{1,i} < minArea
        disp(i)
        continue
    end

    tempCell = struct2cell(S{i});
    tempImg = imbinarize(predImg{i});
    if bwconncomp(tempImg).NumObjects > maxObj
        disp("Multiple Areas Detected")

        santas_list(tempImg,tempCell);
    end

end
% imshow(im)
% rectangle(imgca, 'Position',S.BoundingBox, 'EdgeColor','r');

