combined_cell_good = [FRH100M_F1_D45_G85_good; FRH100M_F1_D45_G90_good; FRH60M_F1_D45_G80_good];


    for i = 1:height(combined_cell_good) 
        imshow(combined_cell_good{i})
        ROI = drawassisted;
        mask = createMask(ROI);
        imwrite(mask, i+".png")
    end 
