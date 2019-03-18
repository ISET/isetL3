function tgtData = imagePatchTgt(tgtImg, upscaleFactor, numMethod, srPatchSize)
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


switch numMethod
    case 1
      rIndx = [1:upscaleFactor:row];
        cIndx = [1:upscaleFactor:col];
        tgtData = zeros(row * col / upscaleFactor^2, upscaleFactor^2 * channel);
        idx = 1;
        for ii = 1 : length(cIndx)
            for jj = 1 : length(rIndx)
                curPatch = tgtImg(rIndx(jj):rIndx(jj)+upscaleFactor-1,...
                                    cIndx(ii):cIndx(ii)+upscaleFactor-1,:);
                This function flatened the patch in R, G and B channel.                
                tgtData(idx, :) = curPatch(:); 
                idx = idx + 1;
            end
        end
    case 2
        rIndx = [1:upscaleFactor:row - srPatchSize(1)+1];
        cIndx = [1:upscaleFactor:col - srPatchSize(2)+1];
        tgtData = zeros(length(rIndx)*length(cIndx), prod(srPatchSize)*channel);
        idx = 1;
        for ii = 1:length(cIndx)
            for jj = 1:length(rIndx)
                curPatch = tgtImg(rIndx(jj):rIndx(jj)+srPatchSize(1)-1,...
                                cIndx(ii):cIndx(ii)+srPatchSize(2)-1,:);
                tgtData(idx, :) = curPatch(:);
                idx = idx + 1;
            end
        end

       
end
end