function [forbidden_list, predImg] = evaluate_std(Preddies, forbidden_list, predImg, maxObj, checkType)


switch checkType

    % Centroid case is obsolete %
    case 'Centroid' %kind of a mess - don't know how many standard deviations to use or whether to check against both centroid coordinates or just one
        meanCent = mean(vertcat(Preddies{2,setdiff(1:end, forbidden_list)}));
        stdCent = std(vertcat(Preddies{2,setdiff(1:end, forbidden_list)}));
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

    case 'BoxOverlap'
        bboxOverlap = zeros(1,size(Preddies,2));
        meanBox = mean(vertcat(Preddies{3,setdiff(1:end, forbidden_list)}));
        for i = 1:size(Preddies,2)
            if ismember(i, forbidden_list)
                continue
            end
            
            bboxOverlap(i) = bboxOverlapRatio(Preddies{3,i}, meanBox);
            
            if bboxOverlap(i)<0.3
                forbidden_list = [forbidden_list i];
                disp("Boxes don't overlap:")
                disp(i)
            end
            
        end
        
    case 'Other'
        MAL = vertcat(Preddies{4,setdiff(1:end, forbidden_list)});
        sumMAL = sum(MAL);
        stdMAL = std(MAL);
        meanMAL = mean(MAL);

        Sol = vertcat(Preddies{5,setdiff(1:end, forbidden_list)});
        sumSol = sum(Sol);
        stdSol = std(Sol);
        meanSol = mean(Sol);

        Ext = vertcat(Preddies{6,setdiff(1:end, forbidden_list)});
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
                img = imopen(predImg{i}, se);

                tempRP = regionprops(img, 'Area', 'Centroid', 'BoundingBox', 'MajorAxisLength','Extent','Solidity');
                [~,bigBlob] = max(vertcat(tempRP.Area));
                tempRP = struct2cell(tempRP);

                %if multiple areas detected - try to fill them,
                %if only one area detected - simply fill background holes within seroma
                if bwconncomp(img).NumObjects > maxObj
                    disp("Multiple areas detected in fixed image")
                    img = fill_areas(img,tempRP);
                else
                    img = imfill(img,'holes');
                end
                
                tempRP = tempRP(:,bigBlob);
                if (tempRP{4}>meanMAL+stdMAL || tempRP{4}<meanMAL-stdMAL) &&...
                        (tempRP{5}>meanSol+stdSol || tempRP{5}<meanSol-stdSol) &&...
                        (tempRP{6}>meanExt+stdExt || tempRP{6}<meanExt-stdExt)
                    disp('Did not work')
                    forbidden_list = [forbidden_list i];
                else
                    predImg{i} = img;
                    disp("Segmentation fixed!")
                    disp(i)
                end
            end
        end

end
