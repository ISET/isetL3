function patchVec = RGB2PatchVec(tgtImg, patchSz, format, varargin)
%     Generate the ground truth vector for the training from the target image.
%     ZL/BW, VISTA TEAM, 2018
    %% Extract parameters
    p = inputParser;
    vFunc = @(x) ismatrix(x) && isnumerical(x) && (length(size(x)) == 2);
    p.addRequired('tgtImg', vFunc);
    p.addRequired('patchSz', vFunc);
    
    vFunc = @(x) isstring(x);
    p.addRequired('format', 'single', vFunc);
    p.parse(tgtImg, patchSz, format, varargin{:});
    
    % Get the dimension of the patch
    rPatch = patchSz(1);
    cPatch = patchSz(2);
    
    % Get the dimension of the rawData
    [rTgtData, cTgtData, channels] = size(tgtImg);
    
    %% 
    switch format 
        case 'single'
            
            rPatchImg = rTgtData - rPatch + 1;
            cPatchImg = cTgtData - cPatch + 1;
            patchVec = zeros(rPatchImg * cPatchImg, 3);
            
            for rr = 1 : rPatchImg
                for cc = 1 : cPatchImg
                    rCenter = (rr + rPatch) / 2;
                    cCenter = (cc + cPatch) / 2;
                    patchVec((rr - 1) * cPatchImg + cc, :) =...
                                                    tgtImg(rCenter, cCenter, :);
                end
            end 
            
        case 'rggb'
            
    end      
    %% Helper function to create flatten crop blcoks for rggb
    function Crop = cropAndFlatten(rawData, r, c, patchSz)
        [rPatch, cPatch] = size(patchSz);

        Crop = rawData(r : r + rPatch - 1, c : c + cPatch - 1);
        Crop = reshape(Crop, [1, numel(Crop)]);
    end
    
end