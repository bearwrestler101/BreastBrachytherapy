function [s_x, s_y] = fnc_gen(zInt,zValues,w,epsilon)
%generate s(x) from sample points, original points, weights, and phi (rbf)

%create empty array
s_x = zeros(length(zInt),1);
s_y = zeros(length(zInt),1);


for i = 1:length(zInt)
    for k = 1:length(zValues)
        %summation(weights*phi(||x_int-xk||)) for k = # original points
        s_x(i) = s_x(i)+ w(k,1)*exp(-(epsilon*(norm(zInt(i)-zValues(k))))^2);
        s_y(i) = s_y(i)+ w(k,2)*exp(-(epsilon*(norm(zInt(i)-zValues(k))))^2);
    end    
end
end

