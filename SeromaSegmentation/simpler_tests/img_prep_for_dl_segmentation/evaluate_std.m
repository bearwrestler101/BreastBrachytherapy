function [reconstruct_list, predImg] = evaluate_std(Preddies, forbidden_list, predImg, checkType)

reconstruct_list = [];


switch checkType
    case 'Centroid'
        meanCent = mean(vertcat(Preddies{2,1:end~=forbidden_list}));
        stdCent = std(vertcat(Preddies{2,1:end~=forbidden_list}));
        disp(meanCent)
        for i = 1:size(Preddies,2)
            if ismember(i, forbidden_list)
                continue
            end
            if (all(Preddies{2,i}>meanCent+stdCent) || all(Preddies{2,i}<meanCent-stdCent))
                disp("Outside mean centroid")
                disp(i)
                
            end


        end

    case 'Other'
MAL = vertcat(Preddies{4,1:end ~=forbidden_list});
sumMAL = sum(MAL);
stdMAL = std(MAL);
meanMAL = mean(MAL);

Sol = vertcat(Preddies{5,1:end ~=forbidden_list});
sumSol = sum(Sol);
stdSol = std(Sol);
meanSol = mean(Sol);

Ext = vertcat(Preddies{6,1:end ~=forbidden_list});
sumExt = sum(Ext);
stdExt = std(Ext);
meanExt = mean(Ext);

for i = 1:size(Preddies,2)

    if ismember(i, forbidden_list)
        continue
    end
    %MajorAxisLength, Solidity, Extent
    if (Preddies{4,i}>meanMAL+stdMAL || Preddies{4,i}<meanMAL-stdMAL) && ...
            (Preddies{5,i}>meanSol+stdSol || Preddies{5,i}<meanSol-stdSol) &&...
            (Preddies{6,i}>meanExt+stdExt || Preddies{6,i}<meanExt-stdExt)
        sprintf("This one is bad: %d", i);
        disp('Trying to fix')
        se = strel('disk',15);
        predImg{i} = imopen(predImg{i}, se);
        tempRP = regionprops(predImg{i}, 'Area', 'Centroid', 'BoundingBox', 'MajorAxisLength','Extent','Solidity');
        [toss,bigBlob] = max(vertcat(tempRP.Area));
        tempRP = struct2cell(tempRP);
        tempRP = tempRP(:,bigBlob);
        disp(tempRP)

        if (tempRP{4}>meanMAL+stdMAL || tempRP{4}<meanMAL-stdMAL) &&...
                (tempRP{5}>meanSol+stdSol || tempRP{5}<meanSol-stdSol) &&...
                (tempRP{6}>meanExt+stdExt || tempRP{6}<meanExt-stdExt)
            disp('Damn that did not work')
            reconstruct_list = [reconstruct_list i];
        else
            
            disp("Success!")
        end
    end
end

end
