close all; 
%constants
%error with epsilon~3
epsilon = 0.2;

%given points and corresponding values
x = [1; 3; 2; 5; 7];
f_x = [3; 6; 8; 10; 1];

%create phi matrix to solve for weights
phi_mat = make_phi_mat_test(epsilon, x);

%system of equations to solve for weights
w = phi_mat\f_x;

%sample points - points to interpolate at
x_int = [1:0.1:7];

%generate s(x)
s_x = fnc_gen_test(x_int, x, w, epsilon);

%plotting interpolation and original

hold on
plot(x_int, s_x)
plot(x,f_x)