% bm4d denoise tutorial
%% load img
imgPath = '/home/zhenglyu/Conference/ScienTalk2018/Figures/conv_ip_img.mat';
% img = imread(imgPath);
file = load(imgPath);
img = file.outImg;
%%
org_img = im2double(img);
%%
% imshow(org_img);

%% Set the parameters
sigma=0.1225; window_size= 8; search_width= 19; 
l2= 0; selection_number = 8; l3= 2.7;

%%
for channel = 1:3
    img = padarray(org_img(:,:,channel),[search_width search_width], ...
        'symmetric','both');
    noisy_image = img;0cgnoptu
    noisy_img(:,:,channel) = noisy_image;
    basic_result(:,:,channel) = first_step(noisy_image, sigma, ...
        window_size, search_width, l2, l3, selection_number);
    basic_padded = padarray(basic_result(:,:,channel), ...
        [search_width search_width],'symmetric','both');
    final_result(:,:,channel) = second_step(noisy_image,basic_padded, ...
        sigma, window_size, search_width, l2, selection_number);
end

%%
noisy_img = noisy_img(search_width+1:end-search_width, ...
    search_width+1:end-search_width,:);

imwrite(noisy_img,'results/noisy_image.jpg');
imwrite(uint8(basic_result),'results/res_phase1.jpg');
imwrite(uint8(final_result),'results/res_phase2.jpg');