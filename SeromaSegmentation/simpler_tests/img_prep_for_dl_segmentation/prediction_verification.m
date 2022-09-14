close all; clear;
predImglist = natsortfiles(dir("predictions/*.png"));

predImg = cell(size(predImglist, 1), 1);

for i=1:length(predImglist)
  predImg{i}=imbinarize(imread("predictions/"+predImglist(i).name));  
end

[S, allPreds] = create_allPreds(predImg);


% Check for good and bad predictions

minArea = 1000;
maxObj = 1;
forbidden_list = [];



for i = 1:size(allPreds,2)

    %if detected seroma too small, add image to forbidden_list
    if allPreds{1,i} < minArea
        forbidden_list = [forbidden_list i];
        continue
    end

end


for i=1:size(allPreds,2)
    if ismember(i, forbidden_list)
        disp("Skipping:")
        disp(i)
        continue
    end
    
    %load all areas of an image into tempCell
    tempCell = struct2cell(S{i});

    %if multiple areas detected - try to fill them, 
    %if only one area detected - simply fill background holes within seroma
    if bwconncomp(predImg{i}).NumObjects > maxObj
        disp("Multiple Areas Detected")
        predImg{i} = fill_areas(predImg{i},tempCell);
        predImg{i} = imfill(predImg{i},'holes');
    else
        predImg{i} = imfill(predImg{i},'holes');
    end

end
[~, allPreds] = create_allPreds(predImg);

%[~, predImg] = evaluate_std(allPreds, forbidden_list, predImg, 'Centroid');

[forbidden_list, predImg] = evaluate_std(allPreds, forbidden_list, predImg, maxObj, 'BoxOverlap');

[forbidden_list, predImg] = evaluate_std(allPreds, forbidden_list, predImg, maxObj, 'Other');
[S, allPreds] = create_allPreds(predImg);
forbidden_list = sort(unique(forbidden_list));

%clear our endpoints from allPreds and forbidden_list as they are likely
%erroneous and cannot be reconstructed from surrounding segmentations

forbidden_list = [1,2,3,5,11,12,13];
lastErase = 1;
lastErase_end = size(allPreds,2);
for i = 1:size(forbidden_list,2)
    if isempty(forbidden_list)
        break
    
    elseif forbidden_list(end) == lastErase_end
        lastErase_end = lastErase_end-1;
        forbidden_list = forbidden_list(:,1:end-1);
        allPreds = allPreds(:,1:end-1);
        predImg = predImg(1:end-1,:);
        
    elseif forbidden_list(1) == lastErase
        lastErase = lastErase + 1;
        forbidden_list = forbidden_list(2:end);
        allPreds = allPreds(:,2:end);
        predImg = predImg(2:end,:);
    end

end

%bad if forbidden_list has consecutive values that weren't at the ends
if ~isempty(forbidden_list)
for i = 1:size(forbidden_list,2)
    disp(i)
    imshow(predImg{5})
    predImg{forbidden_list(i)} = predImg{forbidden_list(i)-1} | predImg{forbidden_list(i)+1};
    figure
    imshow(predImg{5})
end 
end
[S, allPreds] = create_allPreds(predImg);

% imshow(im)
% rectangle(imgca, 'Position',S.BoundingBox, 'EdgeColor','r');

