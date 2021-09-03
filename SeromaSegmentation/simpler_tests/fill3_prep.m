function [x, y, z] = fill3_prep(s_x, s_y, z_int)
%%% DELETE THIS FILE UNLESS USING FILL3 METHOD %%%
for i = 1:length(s_x)
    if mod(i,2)==0        
        s_x{i,1} = flip(s_x{i,1});
    end       
end
x = cell2mat(s_x);
for i = 1:length(s_y)
    if mod(i,2)==0
        s_y{i,1} = flip(s_y{i,1});
    end     
end
y = cell2mat(s_y);

z_cell = cell(length(s_x), 1);
for i = 1:length(s_x)
    if mod(i,2) == 0
        z_cell{i,1} = flip(z_int.');
    else
        z_cell{i,1} = z_int.';
    end
    
end

z = cell2mat(z_cell);
end

