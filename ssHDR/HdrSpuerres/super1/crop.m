clear, clc, close all

near = im2double(imread('srgbnear.png'));
bi = im2double(imread('srgbbi.png'));
super = im2double(imread('super.png'));
ideal = im2double(imread('idealfull.png'));

%%
col = 10: 70;
row = 130 : 230;

nearcrop = near(row, col, :);
bicrop = bi(row, col, :); 
supercrop = super(row, col, :); 
idealcrop = ideal(row+8, col+8, :); 

imwrite(nearcrop, 'cropnear.png');
imwrite(bicrop, 'cropbi.png');
imwrite(supercrop, 'cropsuper.png');
imwrite(idealcrop, 'cropideal.png');