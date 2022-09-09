function [] = santas_list(binImg, pred)
    [toss,bigBlob] = max(vertcat(pred{1,:}));
    %FIXME added fillholes  
    for j = 1:size(pred,2)
        if j == bigBlob
            disp("main area skipped");
            continue
        end
        %coordinates have to be reversed because regionprops() gives image coordinates
        %but imfill() wants [row,col]
        binImg = ~imfill(~binImg, [round(pred{2,j}(2)) round(pred{2,j}(1))]);

    end
    figure
    imshow(binImg)
    disp(bwconncomp(binImg).NumObjects)


end



