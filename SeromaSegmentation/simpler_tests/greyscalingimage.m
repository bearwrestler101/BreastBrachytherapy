% for use with MATLAB_image_segmentation_tlbx()
seroma = rgb2gray(imread('seroma2.jpg'));
imshow(seroma);
imwrite(seroma, 'seroma2_gray.jpg');