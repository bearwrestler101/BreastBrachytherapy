% Extracts and separates the relevant video and position data 

clc; clearvars -except out;

% Initialization - will need to be changed if more scanning paths added
j = 1;
index_cell = cell(3,1);
image_cell = cell(3,1);
pos_cell = cell(3,1);

% Records indices when record signal is 1
for i = 1:length(out.recordout.time)-1
    
    %checks if record signal is 1
    if out.recordout.signals.values(:,:,i) == 1
        index_cell{j} = [index_cell{j}; i];
    end
    
    %checks if stream of 1's has ended to move to next cell 
    if out.recordout.signals.values(:,:,i) ~= out.recordout.signals.values(:,:,i+1) ...
            && out.recordout.signals.values(:,:,i) == 1
        
        j = j + 1;
    end   
end

% Uses extracted indices to record video and position information
for i = 1:size(image_cell, 1)
    image_cell{i} = out.vidout.signals.values(:,:,index_cell{i});
    pos_cell{i} = out.pandapos.signals.values(:,:,index_cell{i});
end



% Plot positions at which images were taken
figure
hold on
for i = 1:3
    plot(squeeze(pos_cell{i}(2,1,:)), squeeze(pos_cell{i}(1,1,:)), '.')
end

% Plot differences between adjacent x values
figure
hold on
differences = cell(3,1);
for i = 1:3
    differences{i} = abs(diff(squeeze(pos_cell{i}(1,1,:))));
    plot(squeeze(pos_cell{i}(2,1,1:(end-1))), differences{i}, '.')
end