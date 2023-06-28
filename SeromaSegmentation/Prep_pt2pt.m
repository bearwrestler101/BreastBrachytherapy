function [index_cell, image_cell, pos_cell] = Prep_pt2pt(out)

% Extracts the relevant video and position data 

% Initialization
j = 1;
index_cell = zeros(size(out.recordout.signals.values, 3) ,1);
rec_out = squeeze(out.recordout.signals.values);

% Records first index of 'recordout = 1' for each point
for i = 2:size(rec_out, 1)
    %checks if record signal is 1
    if rec_out(i-1) < rec_out(i)
        index_cell(j) = i;
        j = j + 1;
    end  
end

% Remove 0s and initialize the other arrays
index_cell = index_cell(all(index_cell, 2));
image_cell = cell(size(index_cell,1), 1);
pos_cell = cell(size(index_cell,1), 1);

% Uses extracted indices to record video and position information
for i = 1:size(index_cell, 1)
    image_cell{i} = out.vidout.signals.values(:,:,index_cell(i));
    pos_cell{i} = out.pandapos.signals.values(:,:,index_cell(i));
end

% Plot locations at which images and positions were taken
figure
hold on
for i = 1:size(index_cell,1)
    plot(pos_cell{i}(2,1,:), pos_cell{i}(1,1,:), '.') 
end
end
