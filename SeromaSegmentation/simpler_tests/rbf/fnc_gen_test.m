function s_x = fnc_gen_test(x_int,x,w,epsilon)
%generate s(x) from sample points, original points, weights, and phi (rbf)

%create empty array
s_x = zeros(length(x_int),1);

for i = 1:length(x_int)
    for k = 1:length(x)
        %summation(weights*phi(||x_int-xk||)) for k = # original points
        s_x(i) = s_x(i)+ w(k)*exp(-1*(epsilon*norm(x_int(i)-x(k)))^2);
        
        % Multiquadric
        %s_x(i) = s_x(i) + w(k)* sqrt(1+(epsilon*norm(x_int(i)- x(k)))^2);
    
    end    
end
end

