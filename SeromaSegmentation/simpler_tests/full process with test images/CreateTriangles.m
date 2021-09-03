function surf_tri = CreateTriangles(num_cnt, cnt_length)
%CREATE_TRIANGLES
%num_cnt = number of contours
%cnt_length = number of points on a single contour

tri = zeros(cnt_length,3);
surf_tri = cell(num_cnt, 1);

for i = 1:cnt_length - 1
    tri(2*i-1:2*i,:) = [i i+1 i+cnt_length; i+cnt_length i+1+cnt_length i+1];
end

%uses tri as building block to create triangle indices between all adjacent
%contours
for j = 1:num_cnt
   surf_tri{j} =  tri + (j-1) * cnt_length;
end

%triangles between last and first contour
for i = 1:cnt_length - 1
    surf_tri{num_cnt}(2*i-1,3) = i;
    surf_tri{num_cnt}(2*i,1) = i;
    surf_tri{num_cnt}(2*i,2) = i+1;
end

surf_tri = cell2mat(surf_tri);

end

