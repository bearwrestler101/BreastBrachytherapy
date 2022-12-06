function interp_coords = ContourInterpolation2d(contours, N, mean_pos_mat)

%TODO insert mean_pos_mat values in here or normals.m function?

%Interpolation of contours
interp_coords = cell(size(contours,1), 1);

%https://stackoverflow.com/questions/27429784/equally-spaced-points-in-a-contour/27430360#27430360

for k = 1:size(contours,1)
    cnt = contours{k,1};

    dx = diff(cnt(:,2));
    dy = diff(cnt(:,1));
    
    dS = sqrt(dx.^2+dy.^2);
    dS = [0; dS];
    
    d = cumsum(dS);
    perim = d(end);

    ds = perim/N;
    dSi = ds*(0:N).';
%     dSi(end) = dSi(end)-.005;
    
%     xi = interp1(d, cnt(:,2), dSi, 'spline');
%     yi = abs(-1.*(interp1(d, cnt(:,1), dSi, 'spline')));

    %Cubic smoothing spline
    xi = csaps(d, cnt(:,2), 0.003);
    yi = csaps(d, cnt(:,1), 0.003);
    xi = ppval(xi, xi.breaks); %evaluates at original points 
    yi = ppval(yi, yi.breaks);
   
    %Close the contour
    xinew = xi;
    yinew = yi; 
    xinew(1) = xinew(end); %close data
    yinew(1) = yinew(end);
    xinew = csape(d, xinew, 'periodic'); %TODO: periodic doesn't seem to do anything
    yinew = csape(d, yinew, 'periodic');
    xinew = ppval(xinew, dSi); %evaluate at equidistant points
    yinew = ppval(yinew, dSi);
    generatedPoints = normals(xinew, yinew); %find normals of contours and off-surface data
    generatedPoints = [generatedPoints(:,1:2) repelem(mean_pos_mat(k),size(generatedPoints,1))', generatedPoints(:,3)]; %insert z-values
    interp_coords{k,1} = [yinew xinew];

end


end

