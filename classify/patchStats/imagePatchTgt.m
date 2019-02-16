function tgtData = imagePatchTgt(tgtImg, upscaleFactor)
% Patch the target images into vectors.
%
%   tgtData = imagePatchTgt(tgtImg, upscaleFactor);
%
% Inputs:
%   tgtImg          - target image
%   upscaleFactor   - upscale factors
%
% Outputs:
%   tgtData         - patched target images

[row, col, channel] = size(tgtImg);
rIndx = [1:upscaleFactor:row];
cIndx = [1:upscaleFactor:col];

tgtData = zeros(row * col / upscaleFactor^2, upscaleFactor^2 * channel);
idx = 1;
for ii = 1 : length(cIndx)
    for jj = 1 : length(rIndx)
        curPatch = tgtImg(rIndx(jj):rIndx(jj)+upscaleFactor-1,...
                            cIndx(ii):cIndx(ii)+upscaleFactor-1,:);
        tgtData(idx, :) = curPatch(:);  
        idx = idx + 1;
    end
end
end