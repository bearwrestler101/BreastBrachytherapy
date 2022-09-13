function [S, allPreds] = create_allPreds(predImg)


S=cell(size(predImg, 1), 1);
allPreds = cell(3,size(predImg,1));

for i=1:length(predImg)
    im = predImg{i};
    S{i} = regionprops(im, 'Area', 'Centroid', 'BoundingBox', 'MajorAxisLength','Extent','Solidity');
end

%copy regionprops stats for biggest areas from each image to a new cell
for i = 1:length(predImg)
    [toss,bigBlob] = max(vertcat(S{i}.Area));
    tempCell = struct2cell(S{i});
    for j = 1:size(tempCell,1)
        allPreds{j,i} = tempCell{j,bigBlob};
    end

end

