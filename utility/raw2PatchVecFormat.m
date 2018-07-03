function patchVec = raw2PatchVecFormat(rawData, patchSz, format, varargin)
%     Crop and transfer the rawData (e.g. rggb) into a flatten vector. 
%     The dimension of the matrix would be :
%           patchVec = matrix(n, H * W)
%     where n is the number of the cropped windows. H and W is the
%     dimension of the patch.
% 
%     ZL/BW, VISTA TEAM, 2018 
    %% Extract the parms
    p = inputParser;
    vFunc = @(x) ismatrix(x) && isnumerical(x) && (length(size(x)) == 2);
    p.addRequired('rawData', vFunc);
  
    p.addRequired('patchSz', vFunc);
    
    format = ieParamFormat(format);
    vFunc = @(x) isstring(x);
    p.addRequired('format', 'single', vFunc);
    p.parse(rawData, patchSz, format, varargin{:});
    
    rawData = p.Results.rawData;
    patchSz = p.Results.patchSz;
    format = p.Results.format;
    
    % Get the dimension of the patch
    rPatch = patchSz(1);
    cPatch = patchSz(2);
    
    % Get the dimension of the rawData
    [rRawData, cRawData] = size(rawData);
    
    

    
    %% Crop the rawData according to style
    
    switch format
        case 'single'
            rPatchImg = rRawData - rPatch + 1;
            cPatchImg = cRawData - cPatch + 1;
            patchVec = zeros(rPatchImg * cPatchImg, rPatch * cPatch);
            
            for rr = 1 : rPatchImg
                for cc = 1 : cPatchImg
                    Crop = cropAndFlatten(rawData, rr, cc, patchSz);
                    patchVec((rr - 1) * cPatchImg + cc, :) = Crop;
                end
            end  
            
        case 'rggb'
            rPatchImg = int((rRawData - rPatch) / 2) + 1;
            cPatchImg = int((cRawData - cPatch) / 2) + 1;
            patchVec = zeros(rPatchImg * cPatchImg, 4 * rPatch * cPatch);
            
            for rr = 1 : rPatchImg
                for cc = 1 : cPatchImg
                    Crp1 = cropAndFlatten(rawData, 2 * rr - 1, 2 * cc - 1, patchSz);
                    Crp2 = cropAndFlatten(rawData, 2 * rr - 1, 2 * cc, patchSz);
                    Crp3 = cropAndFlatten(rawData, 2 * rr, 2 * cc - 1, patchSz);
                    Crp4 = cropandFlatten(rawData, 2 * rr, 2 * cc, patchSz);
                    
                    Crop = [Crp1 Crp2 Crp3 Crp4];
                    patchVec((rr - 1) * cPatchImg + cc, :) = Crop;
                end
            end        
    end        
end


%% Helper function to create flatten crop blcoks for rggb
function Crop = cropAndFlatten(rawData, r, c, patchSz)
    [rPatch, cPatch] = size(patchSz);
    
    Crop = rawData(r : r + rPatch - 1, c : c + cPatch - 1);
    Crop = reshape(Crop, [1, numel(Crop)]);
end
