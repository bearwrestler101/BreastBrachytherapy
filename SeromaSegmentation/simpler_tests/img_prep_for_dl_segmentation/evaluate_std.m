function [outputArg1,outputArg2] = evaluate_std(allPreds)

sumMAL = sum(vertcat(allPreds{4,:}));
stdMAL = std(vertcat(allPreds{4,:}));
meanMAL = sumMAL/size(allPreds,2);

sumSol = sum(vertcat(allPreds{5,:}));
stdSol = std(vertcat(allPreds{5,:}));
meanSol = sumSol/size(allPreds,2);

sumExt = sum(vertcat(allPreds{6,1}));
stdExt = std(vertcat(allPreds{6,:}));
meanExt = sumExt/size(allPreds,2);

for i = 1:size(allPreds,2)

    if ismember(i, forbidden_list)
        continue
    end
    evaluate_std(allPreds)
    %MajorAxisLength
    if (allPreds{4,i}>meanMAL+stdMAL || allPreds{4,i}<meanMAL-stdMAL)

        %Solidity
        if (allPreds{5,i}>meanSol+stdSol || allPreds{5,i}<meanSol-stdSol)

            %Extent
            if (allPreds{6,i}>meanExt+stdExt || allPreds{6,i}<meanExt-stdExt)
                disp('Extent')
                disp(i);

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
