function [generatedPoints] = normals(xi, yi)

% finds normals from each onSurf value and generates inside and outside points offSurf

% ensures that each offSurf generated is closest to its corresponding onSurf

%OUTPUT: [generatedPoints] = [onSurf; offSurf], columns are (x,y) and distance value


yi = -yi; %TODO: may not matter as we're just getting points

[onSurf, offSurf_out1, ~, offSurf_in1, ~] = deal(zeros(size(xi,1)-1, 3));
offSurfacedist = 3;
normalLine = 4;

% figure; hold on; plot(xi, yi);

%normal at each onSurf point calculated from its two adjacent points
for i = 1:length(xi)-1

    if i ~= length(xi)-1
        A = [xi(i),yi(i)]; B = [xi(i+2),yi(i+2)];
    else
        A = [xi(i),yi(i)]; B = [xi(2),yi(2)];
    end

    testNormal = [xi(i+1), yi(i+1)] + null(A-B)' .* normalLine;

    %If normal is pointing inward, switch directions
    if inpolygon(testNormal(1),testNormal(2),xi,yi)
        directionAdjust = -1;
    else
        directionAdjust = 1;
    end

    % for visualization only
%     normal = [xi(i+1), yi(i+1)] + directionAdjust .* null(A-B)' .* normalLine;  

    offSurf_out1(i,:) = [([xi(i+1),yi(i+1)] + directionAdjust .* null(A-B)' .* offSurfacedist),  offSurfacedist];
    offSurf_in1(i,:) = [([xi(i+1),yi(i+1)] + directionAdjust .* null(A-B)' .* -offSurfacedist), -offSurfacedist];
    
    onSurf(i,:) = [xi(i+1), yi(i+1),0];
    
    % for visualization only
%     line([xi(i+1),normal(1)],[yi(i+1),normal(2)])

end

offSurf = [offSurf_out1; offSurf_in1];
generatedPoints = [onSurf; offSurf];

numPnts = size(xi,1)-1;

%----------------%
% Makes sure each offSurf point is closest to its onSurf point
% numRepeat and inc (increment by which to adjust) are set empirically
% numRepeat is set to make sure that points that were adjusted first still
% meet distance criteria after later points are adjusted
%----------------%

for numRepeat = 1:15
    for i = 1:size(offSurf, 1)
        inc = 0.1;

        V = vecnorm(offSurf(i,1:2)'-generatedPoints(:,1:2)');
        [~, I] = min(V(setdiff(1:end, numPnts+i)));


        if I ~= i && i <= 100
            saveLength = offSurf(i,1:2)-onSurf(i,1:2);
            while I~=i

                offSurf_adjust = onSurf(i,1:2)+ saveLength - inc .* saveLength;
                V = vecnorm(offSurf_adjust'-generatedPoints(:,1:2)');
                [~, I] = min(V(setdiff(1:end, numPnts+i)));
                inc = inc + 0.1;
            end
            offSurf(i,1:2) = offSurf_adjust;
            offSurf(i,3) =  norm(offSurf(i,1:2)-onSurf(i,1:2));
            generatedPoints = [onSurf; offSurf];

        elseif I ~=i-numPnts && i > 100
            saveLength = offSurf(i,1:2)-onSurf(i-numPnts,1:2);
            while I~=i-numPnts
                offSurf_adjust = onSurf(i-numPnts,1:2) + (saveLength - inc .* saveLength);
                V = vecnorm(offSurf_adjust'-generatedPoints(:,1:2)');
                [~, I] = min(V(setdiff(1:end, numPnts+i)));
                inc = inc + 0.1;
            end
            offSurf(i,1:2) = offSurf_adjust;
            offSurf(i,3) = -norm(offSurf(i,1:2)-onSurf(i-numPnts,1:2));
            generatedPoints = [onSurf; offSurf];
        end
    end
end


% figure; hold on; plot(onSurf(:,1),onSurf(:,2),'o'); plot(offSurf(:,1),offSurf(:,2),'o');

breakpoint = 0;
% https://www.mathworks.com/matlabcentral/answers/85686-how-to-calculate-normal-to-a-line