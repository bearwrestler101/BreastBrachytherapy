function binImg = fill_areas(binImg, pred)
    [toss,bigBlob] = max(vertcat(pred{1,:}));
    
    for j = 1:size(pred,2)
        if j == bigBlob
            disp("Skipping main area");
            continue
        end
        %coordinates have to be reversed because regionprops() gives image coordinates
        %but imfill() wants [row,col]
        binImg = ~imfill(~binImg, [round(pred{2,j}(2)) round(pred{2,j}(1))]);
        
        %fill possible holes in seroma
        binImg = imfill(binImg, 'holes');
    end
    figure
    imshow(binImg)
    disp(bwconncomp(binImg).NumObjects)





