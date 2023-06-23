unity = readmatrix('NDI 5 DoF Tracking\ARDisplay - Breast Brachytherapy\Assets\test.csv');

NDI_pos = unity(:,2:4);
radius = 0.0447;
x_offset = 0.4546;
y_offset = 0.01447; 
path_length = 0; 
transform =  [
    0.0229   -0.0241   -1.0002   -0.0000
    1.0080   -0.0007    0.0122   -0.0000
    0.0000   -1.0096    0.0377   -0.0000
    0.4620   -0.2944    0.0006    1.0000]; 


for i = 2:height(NDI_pos)
    
    if (((NDI_pos(i, 1) - x_offset)^2 + (NDI_pos(i,2) - y_offset)^2)^(1/2) <= radius) && (((NDI_pos(i-1, 1) - x_offset)^2 + (NDI_pos(i-1,2) - y_offset)^2)^(1/2) <= radius)
        
        path_length = path_length + ((NDI_pos(i,1)-NDI_pos(i-1,1))^2 + (NDI_pos(i,2)-NDI_pos(i-1,2))^2 + (NDI_pos(i,3)-NDI_pos(i-1,3))^2)^(1/2); 
        
    end
    
end 

