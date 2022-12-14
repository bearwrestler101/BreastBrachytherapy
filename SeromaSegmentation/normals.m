function [generatedPoints] = normals(xi, yi)
yi = -yi; %TODO: may not matter as we're just getting points

[onSurf, offSurf_out1, ~, offSurf_in1, ~] = deal(zeros(size(xi,1)-1, 3));
offSurfacedist = 3;
normalLine = 10;
% 
% figure
% hold on
% plot(xi, yi)

for i = 1:length(xi)-1

    if i ~= length(xi)-1
        A = [xi(i),yi(i)]; B = [xi(i+2),yi(i+2)];
    else
        A = [xi(i),yi(i)]; B = [xi(2),yi(2)];
    end

    testNormal = [xi(i+1), yi(i+1)] + null(A-B)'.*normalLine;

    %If normal is pointing inward, switch directions
    cntrAvg = [mean(xi), mean(yi)];
    if norm(cntrAvg-[xi(i+1), yi(i+1)])>norm(cntrAvg-[testNormal(1), testNormal(2)])
        directionAdjust = -1;
    else
        directionAdjust = 1;
    end

    normal = [xi(i+1), yi(i+1)] + directionAdjust .* null(A-B)' .* normalLine;

    offSurf_out1(i,:) = [([xi(i+1),yi(i+1)] + directionAdjust .* null(A-B)' .* offSurfacedist),  offSurfacedist];
    offSurf_in1(i,:) = [([xi(i+1),yi(i+1)] + directionAdjust .* null(A-B)' .* -offSurfacedist), -offSurfacedist];
    
    onSurf(i,:) = [xi(i+1), yi(i+1),0];
    
%     line([xi(i+1),normal(1)],[yi(i+1),normal(2)])

end

offSurf = [offSurf_out1; offSurf_in1];
generatedPoints = [onSurf; offSurf];

% plot(offSurf(:,1),offSurf(:,2),'o')
wtf = [];
onSurf2 = [onSurf; onSurf];
for i = 1:size(offSurf, 1)
    %TODO:fix offSurfacedist direction, fix normal generation direction above, run
    %through all points again to make sure that closest values had been achieved
    V = vecnorm(offSurf(i,1:2)'-generatedPoints(:,1:2)');
    [~, I] = min(V(setdiff(1:end, size(xi,1)-1+i)));
    saveLength = offSurf(i,1:2)-onSurf2(i,1:2);
    inc = 0.1;
    if I ~= i && i <= 100

        while I~=i

            offSurf_adjust = onSurf2(i,1:2)+ saveLength - inc .* saveLength;
            V = vecnorm(offSurf_adjust'-generatedPoints(:,1:2)');
            [~, I] = min(V(setdiff(1:end, size(xi,1)-1+i)));
            inc = inc + 0.1;
        end
        offSurf(i,1:2) = offSurf_adjust;

    elseif I ~=i-100 && i > 100
        while I~=i-100
            offSurf_adjust = onSurf2(i,1:2) + (saveLength - inc.*saveLength);
            V = vecnorm(offSurf_adjust'-generatedPoints(:,1:2)');
            [~, I] = min(V(setdiff(1:end, size(xi,1)-1+i)));
            inc = inc + 0.1;
        end
        offSurf(i,1:2) = offSurf_adjust;
    end
end

breakpoint = 0;
% https://www.mathworks.com/matlabcentral/answers/85686-how-to-calculate-normal-to-a-line