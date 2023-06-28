combined_cell = [cell'; cell2'; cell3'; cell4'; cell5'; cell6'];


    for i = 1:height(combined_cell) 
        imshow(combined_cell{i})
        ROI = drawassisted;
        mask = createMask(ROI);
        imwrite(mask, i+".png")
    end 
