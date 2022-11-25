function [] = normals(xinew, yinew)
%close all
figure
hold on
plot(xinew, yinew)
offSurface = [length(xinew),2];

for i = 1:length(xinew)-1

    if i ~= length(xinew)-1
        A = [xinew(i),yinew(i)]; B = [xinew(i+2),yinew(i+2)];
    else
        A = [xinew(i),yinew(i)]; B = [xinew(1),yinew(1)];
    end

    x = [A(1);B(1)]; y = [A(2);B(2)];

    normal = [xinew(i+1), yinew(i+1)] + null(A-B)'.*10;
    cntrAvg = [mean(xinew), mean(yinew)];
    offSurface(i,:) = ([xinew(i+1),yinew(i+1)]+null(A-B)'.*3);

    %If normal is pointing inward, switch directions
    if norm(cntrAvg-[xinew(i+1), yinew(i+1)])>norm(cntrAvg-[normal(1), normal(2)])
        normal = [xinew(i+1), yinew(i+1)] - null(A-B)'.*10;
        offSurface(i,:) = ([xinew(i+1),yinew(i+1)]-null(A-B)'.*3);
    end

    line([xinew(i+1),normal(1)],[yinew(i+1),normal(2)])

    

end

 plot(offSurface(:,1),offSurface(:,2),'o')
end
% https://www.mathworks.com/matlabcentral/answers/85686-how-to-calculate-normal-to-a-line