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
for ii = 1 : length(rIndx)
    for jj = 1 : length(cIndx)
        curPatch = tgtImg(rIndx(ii):rIndx(ii)+upscaleFactor-1,...
                            cIndx(jj):cIndx(jj)+upscaleFactor-1,:);
        tgtData(idx, :) = curPatch(:);  
        idx = idx + 1;
    end
end
end