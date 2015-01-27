clear, clc, close all

% bayer = im2double(imread('srgbResult_Bayer_exp0.055.png'));
% rgbw = im2double(imread('srgbResult_RGBW_exp0.055.png'));
% hdr = im2double(imread('srgbResult_HDR_denselumsampling_exp0.14.png'));
% ideal = im2double(imread('idealResult.png'));
hdr1 = im2double(imread('srgbResult_HDR1_exp0.45.png'));
hdrcy = im2double(imread('srgbResult_HDRcy_exp0.09.png'));

col = 1 : 160;
row = 310 : 410;
scale = 4;
%%
% bayercrop = bayer(row, col, :) * scale;
% rgbwcrop = rgbw(row, col, :) * scale;
% hdrcrop = hdr(row, col, :) * scale;
% idealcrop = ideal(row, col, :) * scale;
hdrcrop1 = hdr1(row, col, :) * scale;
hdrcycrop = hdrcy(row, col, :) * scale;

% 
% imwrite(bayercrop, 'cropbayer.png');
% imwrite(rgbwcrop, 'croprgbw.png');
% imwrite(hdrcrop, 'crophdr.png');
% imwrite(idealcrop, 'cropideal.png');
imwrite(hdrcrop1, 'crophdr1.png');
imwrite(hdrcycrop, 'crophdrcy.png');