function reconstruct_list = evaluate_std(Preddies, forbidden_list, predImg)

reconstruct_list = [];

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
    %MajorAxisLength
    if (Preddies{4,i}>meanMAL+stdMAL || Preddies{4,i}<meanMAL-stdMAL)

        %Solidity
        if (Preddies{5,i}>meanSol+stdSol || Preddies{5,i}<meanSol-stdSol)

            %Extent
            if (Preddies{6,i}>meanExt+stdExt || Preddies{6,i}<meanExt-stdExt)
                disp('Extent')
                disp(i);
                disp('Trying to fix')
                se = strel('disk',15);
                predImg{i} = imopen(predImg{i}, se);
                tempRP = regionprops(predImg{i}, 'Area', 'Centroid', 'BoundingBox', 'MajorAxisLength','Extent','Solidity');
                [toss,bigBlob] = max(vertcat(tempRP.Area));
                tempRP = struct2cell(tempRP);
                tempRP = tempRP(:,bigBlob);
                disp(tempRP)

                if (tempRP{4}>meanMAL+stdMAL || tempRP{4}<meanMAL-stdMAL) && (tempRP{5}>meanSol+stdSol || tempRP{5}<meanSol-stdSol) && (tempRP{6}>meanExt+stdExt || tempRP{6}<meanExt-stdExt)
                    disp('damn that did not work')
                    reconstruct_list = [reconstruct_list i];
                end
            end
        end
    end


end

% [sumCent,meanCent] = deal(zeros(1,2));
% for i = 1:size(allPreds,2)
%     sumCent(1,1) = sumCent(1,1)+allPreds{2,i}(1);
%     sumCent(1,2) = sumCent(1,2)+allPreds{2,i}(2);
% end
% 
% meanCent(1,1) = sumCent(1,1)/size(allPreds,2);
% meanCent(1,2) = sumCent(1,2)/size(allPreds,2);
