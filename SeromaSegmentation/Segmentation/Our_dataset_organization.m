% Pretty much temporary for organizing and augmenting our dataset


max_num = natsortfiles(dir("BUS_dataset_augmented/*.png"));
max_num = max_num(end).name;
max_num = str2double(max_num(9:12));


mask_names = natsortfiles(dir("ROI_Mask/*.png"));
masks = cell(size(mask_names,1),1);


frh_names = natsortfiles(dir("ROI_Mask_Good/*.png")); %path needs updating
frh_masks = cell(size(frh_names,1),1);
%%%have to be loaded in before running script%%%
frh = [FRH100M_F1_D45_G85_good; FRH100M_F1_D45_G90_good; FRH60M_F1_D45_G80_good];

%%%have to be loaded in before running script%%%
imgs = [cell1'; cell2'; cell3'; cell4'; cell5'; cell6'; frh];

for i=1:length(masks)
%   imgs{i} = imresize(imread("BUS_dataset/BUS/original/"+img_names(i).name),[256 256]);  
  masks{i}=imread("ROI_Mask/"+mask_names(i).name);  
  
end

for i = 1:length(frh_masks)
    frh_masks{i} = imread("ROI_Mask_Good/"+frh_names(i).name);
end

masks = [masks; frh_masks];

for i = 1:length(imgs)
    imgs{i} = imresize(imgs{i}, [256 256]);
    masks{i} = imresize(masks{i}, [256 256]);
end


img_bright = imgs;
img_dim = imgs;

for i = 1:length(imgs)
    img_bright{i} = imadjust(img_bright{i},[],[],0.7);
    img_dim{i} = imadjust(img_dim{i},[],[],1.5);   
end

allImgs = [imgs;img_bright;img_dim];
allMasks = [masks;masks;masks];


for i = 1:length(allImgs)
    img_num = i + max_num;
    imwrite(allImgs{i}, "our_dataset_augmented/benign ("+img_num+").png")
    imwrite(allMasks{i}, "our_dataset_augmented/benign ("+img_num+")_mask.png")
end


