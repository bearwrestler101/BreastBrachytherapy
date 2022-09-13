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
    
    %load all areas in image into tempCell
    tempCell = struct2cell(S{i});

    %if multiple areas detected - try to fill them, 
    %if only one area detected - simply fill background holes within seroma
    if bwconncomp(predImg{i}).NumObjects > maxObj
        disp("Multiple Areas Detected")
        predImg{i} = fill_areas(predImg{i},tempCell);
    else
        predImg{i} = imfill(predImg{i},'holes');
    end

end
[S, allPreds] = create_allPreds(predImg);

%[~, predImg] = evaluate_std(allPreds, forbidden_list, predImg, 'Centroid');

[forbidden_list, predImg] = evaluate_std(allPreds, forbidden_list, predImg, 'BoxOverlap');

[forbidden_list, predImg] = evaluate_std(allPreds, forbidden_list, predImg, 'Other');
[S, allPreds] = create_allPreds(predImg);
forbidden_list = sort(unique(forbidden_list));


% imshow(im)
% rectangle(imgca, 'Position',S.BoundingBox, 'EdgeColor','r');

