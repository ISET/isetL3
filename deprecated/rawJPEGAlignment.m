%% Analyze geometric distortions between raw and jpeg data
%
% HJ observed that there is geometric distortion.  In regions with texture
% and edges the geometric distortions mean we are not learning the right
% mapping.  So, we either need to
%
%    * Compensate for the geometric distortions, or
%    * Only analyze uniform regions where small displacements don't matter
%
%
% This script helps us visualize the geometric distortions between the
% raw and jpeg images
%
% It appears that the NIKON data are not quite aligned left to right and
% probably not up and down the columns either.  Check the rationale in
% loadScarletNikon for how the shifting was done.
%
% Is it possible that the shifting differs between images?
%

%% Create remote data object for SCIEN
rd = rdata;

%% Download a pair of images from the NIKON camera
rawFile = 'DSC_0767.pgm';
rawData = rd.imageRead(rawFile);

jpgFile= 'DSC_0767.JPG';
jpgData = rd.imageRead(jpgFile);
jpgData = single(jpgData);

croppedRaw = rawAdjustSize(rawData,[size(jpgData,1), size(jpgData,2)]);
croppedRaw = single(croppedRaw);

%% Check the image
img(:,:,3) = croppedRaw(1:2:end,1:2:end);
img(:,:,2) = (croppedRaw(1:2:end,2:2:end) + croppedRaw(2:2:end,1:2:end))*0.5;
img(:,:,1) = croppedRaw(2:2:end,2:2:end);
img = ieScale(img,0,1);
vcNewGraphWin; image(img);

%%
jpgData = ieScale(jpgData,0,1);

vcNewGraphWin; image(jpgData);

%% Check alignment across the row
row = 500;

rawLine = img(row,:,2);
jpgLine = jpgData(2*row,1:2:end,2);

rawLine = ieScale(rawLine,0,1);
jpgLine = ieScale(jpgLine,0,1);
% plot(rawLine,jpgLine,'k.'); axis equal; identityLine;

nCols = length(rawLine);
vcNewGraphWin;
plot(1:nCols,rawLine,'r--', 1:nCols,jpgLine,'g:');
legend({'raw','jpg'})

%% Check alignment across the col
col = 500;

rawLine = img(:,col,2);
jpgLine = jpgData(1:2:end,2*col-1,2);

rawLine = ieScale(rawLine,0,1);
jpgLine = ieScale(jpgLine,0,1);
% plot(rawLine,jpgLine,'k.'); axis equal; identityLine;

nRows = length(rawLine);
vcNewGraphWin;
plot(1:nRows,rawLine,'r-', 1:nRows,jpgLine,'g-');
legend({'raw','jpg'})

