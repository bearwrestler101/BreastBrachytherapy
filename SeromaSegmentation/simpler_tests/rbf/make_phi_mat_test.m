function phi_mat = make_phi_mat_test(epsilon, data)
%generating phi matrix to solve for weights

%create empty array
phi_mat = zeros(length(data));


for i = 1:length(data)
    for j = 1:length(data)
        %fill rows and columns with phi = exp(-(epsilon*||xj - xi||)^2)
        phi_mat(i,j) = exp(-1*(epsilon*norm(data(j)-data(i)))^2);
        
        % Multiquadric
        %phi_mat(i,j) = sqrt(1+(epsilon*norm(data(j)- data(i)))^2);

    end
end 
end

