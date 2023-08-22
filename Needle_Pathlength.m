Folder = '..\Test subjects\1\';
path_length = zeros(3,4);
for k = 2:4
    filename = fullfile(Folder, sprintf('1_%d.csv',k));
    unity = readmatrix(filename);
    NDI_pos = unity(:,2:4);
    Clicks = 0;
    %radius = 0.0447;
    %x_offset = 0.4546;
    %y_offset = 0.01447;
    radius = 0.025;
    x_offset = 0.4609;
    y_offset = 0.0173;
    j = 1; 
    transform =  [
        0.0229   -0.0241   -1.0002   -0.0000
        1.0080   -0.0007    0.0122   -0.0000
        0.0000   -1.0096    0.0377   -0.0000
        0.4620   -0.2944    0.0006    1.0000]; 


    for i = 2:height(NDI_pos)

        if (((NDI_pos(i, 1) - x_offset)^2 + (NDI_pos(i,2) - y_offset)^2)^(1/2) <= radius) && (((NDI_pos(i-1, 1) - x_offset)^2 + (NDI_pos(i-1,2) - y_offset)^2)^(1/2) <= radius)
            
            Clicks = Clicks + unity(i,23); 
            path_length(j,k) = path_length(j,k) + ((NDI_pos(i,1)-NDI_pos(i-1,1))^2 + (NDI_pos(i,2)-NDI_pos(i-1,2))^2 + (NDI_pos(i,3)-NDI_pos(i-1,3))^2)^(1/2);
            
        elseif Clicks == 3
            Clicks = 0;
            j = j+1;
        end

    end 
end

