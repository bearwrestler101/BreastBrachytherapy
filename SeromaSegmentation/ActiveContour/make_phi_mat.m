function phi_mat = make_phi_mat(zValues, epsilon)
%generating phi matrix to solve for weights

%create empty array
phi_mat = zeros(size(zValues, 1));


for i = 1:size(zValues, 1)
    for j = 1:size(zValues, 1)
        %fill rows and columns with phi = exp(-(epsilon*||xj - xi||)^2)
        phi_mat(i,j) = exp(-(epsilon*norm(zValues(j) - zValues(i)))^2);
    end
end 
end

