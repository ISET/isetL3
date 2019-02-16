function imRGB = XWSR2RGBFormat(imXWSR, row, col, upscaleFactor)
% Convert XW super resolution format data to RGB format
% 
%   imRGB = XWSR2RGBFormat(imXWSR, row, col, upscaleFactor);
%
% Description:
%   Convert XW super resolution format to RGB image. The difference between
%   XWSR2RGBFormat and XW2RGBFormat is the function first reshape the
%   patches into [USF, USF, :], and then fit them into the correct position
%   in the output image.

if notDefined('imXWSR'), error('No image data.'); end
if notDefined('row'), error('No row size.'); end
if notDefined('col'), error('No col size.'); end

x = size(imXWSR, 1);
w = size(imXWSR, 2);

if row * col * upscaleFactor ^ 2 * 3 ~= x * w, error ('XWSR2RGBFormat: Bad row, col values.'); end

%% The rest part is probably not elegant
outRow = row * upscaleFactor;
outCol = col * upscaleFactor;
rIndx = [1:upscaleFactor:outRow];
cIndx = [1:upscaleFactor:outCol];


imRGB = zeros(outRow, outCol, 3);
nBlocks = 1;
for ii = 1 : length(cIndx)
    for jj = 1 : length(rIndx)
        % Decide which block should use in the imXWSR
%         blkStart  = nBlocks * upscaleFactor^2 + 1; 
%         blkEnd    = (nBlocks + 1) * upscaleFactor^2;
        thisBlock = imXWSR(nBlocks,:);
        thisBlock = reshape(thisBlock, [upscaleFactor upscaleFactor, 3]);
        
        % Decide the correct position to fit the block in output image
        indxStart = [rIndx(jj) cIndx(ii)];
        indxEnd   = indxStart + upscaleFactor - 1;
        imRGB(indxStart(1):indxEnd(1), indxStart(2):indxEnd(2),:) = thisBlock;
        nBlocks = nBlocks + 1;
    end
end
end