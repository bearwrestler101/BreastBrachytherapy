origImglist = dir("dataset/*.png");
origImg=cell(1,length(origImglist));

for i=1:length(origImglist)
  origImg{i}=imread("dataset/"+origImglist(i).name);
end

%% Resize to 256x256
imsize = 256;
resizedImg = cell(size(origImg,1), size(origImg,2));

for i = 1:length(origImg)
    resizedImg{i}=imresize(origImg{i}, [imsize imsize]);
end

%% Adding speckle

for k = 1:size(resizedImg, 2)
    if isa(resizedImg{k}, 'uint8')

        snpNoise = zeros(round(imsize*1), round(imsize*0.3));
        rng('shuffle');

        %random points where zeros turned to ones
        row = randi([1 size(snpNoise,1)],1,200);
        column = randi([1 size(snpNoise,2)],1,200);

        for i=1:size(row,2)
            snpNoise(row(i),column(i)) = 1;
            
            %adding extra ones around a point to create clusters
            if row(i)>4 && row(i) <=size(snpNoise,1)-4 && column(i)>4 && column(i)<=size(snpNoise,2)-4 && rand > 0.6
                rowExtra = randi([-3 3], [4 1]);
                columnExtra = randi([-3 3], [4 1]);
                for j = 1:size(rowExtra,1)
                    snpNoise(row(i)+rowExtra(j),column(i)+columnExtra(j)) = 1;
                end
            end
        end
        snpNoise = imresize(snpNoise,[imsize, imsize]);

        %mat2gray() fixes max/min of snpNoise for conversion to uint8
        snpNoise = uint8(255 * mat2gray(snpNoise,[0 1]));
        snpNoise = imgaussfilt(snpNoise,1); %gaussian filter
        
        % add noise to original image
        resizedImg{k} = imadd(snpNoise, resizedImg{k}(:,:,1));
    end
end

%% Gamma Up, Down and Rotate 90, 180, 270

[gammaUp, gammaDown] = deal(resizedImg);

for i = 1:length(gammaUp)
    if isa(gammaUp{i}, "uint8") %imgs=uint8, masks=logical
        gammaUp{i} = imadjust(gammaUp{i},[],[],0.7);
        gammaDown{i} = imadjust(gammaDown{i},[],[],1.5);
        continue
    end
end

[rot90_gUp, rot180_gUp, rot270_gUp] = deal(gammaUp);
[rot90_gDown, rot180_gDown, rot270_gDown] = deal(gammaDown);

for i = 1:length(resizedImg)
    rot90_gUp{i} = imrotate(rot90_gUp{i}, 90);
    rot180_gUp{i} = imrotate(rot180_gUp{i}, 180);
    rot270_gUp{i} = imrotate(rot270_gUp{i}, 270);
    rot90_gDown{i} = imrotate(rot90_gDown{i}, 90);
    rot180_gDown{i} = imrotate(rot180_gDown{i}, 180);
    rot270_gDown{i} = imrotate(rot270_gDown{i}, 270);
end

%% Combine all versions
dataset = [resizedImg, gammaUp, gammaDown, rot90_gUp, rot90_gDown, rot180_gUp, rot180_gDown, rot270_gUp, rot270_gDown];

%%

[imgs, masks, masks1, masks2] = deal([]);

%find indeces of images and masks in original dataset
for i = 1:length(origImglist)
    if origImglist(i).name(end-4:end)== ").png"
        imgs = [imgs; i];
    elseif origImglist(i).name(end-4:end)=="k.png"
        masks = [masks; i];
    elseif origImglist(i).name(end-4:end)=="1.png"
        masks1 = [masks1; i];
    elseif origImglist(i).name(end-4:end)=="2.png"
        masks2 = [masks2; i];
    end
end

%%

% save augmented images to file
for i = 1:9 %upper limit of foor loop specifies how many variations of the original dataset make up the augmented one
    for j = 1:length(imgs)
        k = imgs(j) + (i-1)*length(origImglist); %finds only images in dataset using imgs list
        imgNum = j + (i-1)*length(imgs); %imgNum allows naming the images in a consecutive order
        dataset{k} = cat(3, dataset{k}, dataset{k}, dataset{k});
        imwrite(dataset{k}, "snp_augmented_dataset/benign (" + imgNum + ").png")
    end
end


% save augmented masks to file
for i = 1:9
    for j = 1:length(masks)
        k = masks(j) + (i-1)*length(origImglist);
        maskNum = j + (i-1)*length(masks);
        imwrite(dataset{k}, "snp_augmented_dataset/benign (" + maskNum + ")_mask.png");
        if find(masks1== k-(i-1)*length(origImglist)+1)
            imwrite(dataset{k+1}, "snp_augmented_dataset/benign (" + maskNum + ")_mask_1.png");
        end
        if find(masks2 == k-(i-1)*length(origImglist)+2)
            imwrite(dataset{k+2}, "snp_augmented_dataset/benign (" + maskNum + ")_mask_2.png");
        end

    end
end