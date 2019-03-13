function imRGB = XWSR2RGBFormat(imXWSR, row, col, upscaleFactor)
% Convert XW super resolution format data to RGB format
% 
%   imRGB = XWSR2RGBFormat(imXWSR, row, col, upscaleFactor);
%
% Description:
%   Convert XW super resolution format to RGB image. The difference between
%   XWSR2RGBFormat and XW2RGBFormat is the function first reshape the
%   patches into [USF, USF, imRGBChannel], and then fit them into the 
%   correct position in the output image.
%
%   Zheng Lyu, Brian Wandell, STANFORD VISTA TEAM, 2019

if notDefined('imXWSR'), error('No image data.'); end
if notDefined('row'), error('No row size.'); end
if notDefined('col'), error('No col size.'); end

x = size(imXWSR, 1);
w = size(imXWSR, 2);

if row * col ~= x * upscaleFactor^2, error ('XWSR2RGBFormat: Bad row, col values.'); end

%% The rest part is probably not elegant
rIndx = [1:upscaleFactor:row];
cIndx = [1:upscaleFactor:col];

imRGBChannel = w / (upscaleFactor^2);
imRGB = zeros(row, col, imRGBChannel);
nBlocks = 1;
for ii = 1 : length(cIndx)
    for jj = 1 : length(rIndx)
        % Decide which block should use in the imXWSR
        thisBlock = imXWSR(nBlocks,:);
        thisBlock = reshape(thisBlock, [upscaleFactor upscaleFactor imRGBChannel]);
        
        % Decide the correct position to fit the block in output image
        indxStart = [rIndx(jj) cIndx(ii)];
        indxEnd   = indxStart + upscaleFactor - 1;
        imRGB(indxStart(1):indxEnd(1), indxStart(2):indxEnd(2),:) = thisBlock;
        nBlocks = nBlocks + 1;
    end
end
end