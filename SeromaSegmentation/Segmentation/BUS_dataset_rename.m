%Augment BUS_dataset with new gamma values and rewrites file names to be
%appended to snp_augmented_dataset

img_names = natsortfiles(dir("BUS_dataset/BUS/original/*.png"));
mask_names = natsortfiles(dir("BUS_dataset/BUS/GT/*.png"));

imgs = cell(size(img_names,1),1);
masks = cell(size(img_names,1),1);


for i=1:length(imgs)
  imgs{i} = imresize(imread("BUS_dataset/BUS/original/"+img_names(i).name),[256 256]);  
  masks{i}=imresize(imread("BUS_dataset/BUS/GT/"+mask_names(i).name),[256 256]);  

end

imgs_bright = imgs;
imgs_dim = imgs;

for i = 1:length(imgs)
    imgs_bright{i} = imadjust(imgs_bright{i},[],[],0.7);
    imgs_dim{i} = imadjust(imgs_dim{i},[],[],1.5);   
end

allImgs = [imgs; imgs_bright; imgs_dim];
allMasks = [masks; masks; masks];

%extract number from last snp_augmented_dataset name - hard coded so be
%careful
max_num = natsortfiles(dir("snp_augmented_dataset/*.png"));
max_num = max_num(end).name;
max_num = str2double(max_num(9:12));


for i = 1:length(allImgs)
    img_num = i + max_num;
    imwrite(allImgs{i}, "BUS_dataset_augmented/benign ("+img_num+").png")
    imwrite(allMasks{i}, "BUS_dataset_augmented/benign ("+img_num+")_mask.png")
end

