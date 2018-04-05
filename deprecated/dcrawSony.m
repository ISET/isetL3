%% DCRAW development and testing for the Sony data
%
%  On black we did a 
%     sudo apt-get install dcraw
% 
%  To convert ARW to PGM we ran 
%       dcraw -D -o 0 -c -4 DSC01585.ARW > test.pgm
%
%  The pgm data have RGGB format in the output.
%  This is tested and illustrated below.
%  

% This is in the SONY/Flowers directory 
dDir = '/wandellfs/data/validation/SCIEN/L3/SonyRX100/Flowers';
chdir(dDir);

% We created test.pgm as in the header
img = imread('test.pgm');
[r,c] = size(img);
red  = img(1:2:r,1:2:c);
blue = img(2:2:r,2:2:c);
g1   =  img(1:2:r,2:2:c);
g2   = img(2:2:r,1:2:c);
green = (g1 + g2) / 2;

% Show the image
cimg = cat(3,red,green,blue);
cimg = single(cimg);

% A lot of the flowers are red and white.
imagescRGB(cimg);

% Compare the image to the corresponding JPG image
jimg = imread('DSC01585.JPG');
imagesc(jimg);

%% END
