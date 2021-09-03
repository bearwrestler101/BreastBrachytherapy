function interp_coords = ContourInterpolation2d(contours, N)
%Interpolation of contours

interp_coords = cell(length(contours), 1);

%https://stackoverflow.com/questions/27429784/equally-spaced-points-in-a-contour/27430360#27430360

for k = 1:length(contours)
    cnt = contours{k};
    
    dx = diff(cnt(:,2));
    dy = diff(cnt(:,1));
    
    dS = sqrt(dx.^2+dy.^2);
    dS = [0; dS];
    
    d = cumsum(dS);
    perim = d(end);

    ds = perim/N;
    dSi = ds*(0:N).';
    dSi(end) = dSi(end)-.005;
    
    xi = interp1(d, cnt(:,2), dSi, 'spline');
    yi = abs(-1.*(interp1(d, cnt(:,1), dSi, 'spline')));
    interp_coords{k,1} = [xi yi];
end

end

