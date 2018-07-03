function RGBImg = patchVec2RGBFormat(patchVec, rawImgSz, patchSz, format, varargin)
%   Transfer the trained patchVector to the RGB image.
%   ZL/BW, 2018

    %% Extract the parms
    p = inputParser;
    vFunc = @(x) ismatrix(x) && isnumerical(x) && (length(size(x)) == 2);
    p.addRequired('patchVec', vFunc);
    p.addRequired('rawImgSz', vFunc);
    p.addRequired('patchSz', vFunc);
    
    vFunc = @(x) isstring(x);
    p.addRequired('format', 'single', vFunc);
    p.parse(patchVec, rawImgSz, patchSz, format, varargin{:});
    
    patchVec = p.Results.patchVec;
    rawData = p.Results.rawData;
    patchSz = p.Results.patchSz;
    format = p.Results.format;
    
    % Get the dimension of the patch
    rPatchSz = patchSz(1);
    cPatchSz = patchSz(2);
    
    % Get the dimension of the rawData
    [rRawData, cRawData] = size(rawData);
    %% 
    switch format
        case 'single'
            rRecImg = rRawData - rPatchSz + 1;
            cRecImg = cRawData - cPatchSz + 1;
            RGBImg = zeros(rRecImg, cRecImg, 3);
            
            for rr = 1 : rRecImg
                for cc = 1 : cRecImg
                    RGBImg(rr, cc, :) = patchVec((rr - 1) * cRegImg + cc, :);
                end
            end
        case 'rggb'
            rNumBlockRecImg = (int((rRawData - rPatchSz) / 2)  + 1);
            cNumBlockRecImg = (int((cRawData - cPatchSz) / 2)  + 1);
            RGBImg = zeros(rNumBlockRecImg, cNumBlockRecImg, 3);
            
            for rr = 1 : rNumBlockRecImg
                for cc = 1 : cNumBlockRecImg
                    RGBImg(2 * rr - 1, 2 * cc - 1, :) = patchVec((rr - 1) *...
                                                            cNumBlockRecImg + cc, cc, 1:3);
                    RGBImg(2 * rr - 1, 2 * cc, :)     = patchVec((rr - 1) *...
                                                            cNumBlockRecImg + cc, cc, 4:6);
                    RGBImg(2 * rr, 2 * cc - 1, :)     = patchVec((rr - 1) *...
                                                            cNumBlockRecImg + cc, cc, 7:9);
                    RGBImg(2 * rr, 2 * cc, :)         = patchVec((rr - 1) *...
                                                            cNumBlockRecImg + cc, cc, 10:12);
                end
            end
            
    end
    
    RGBImg = RGBImg / max(max(RGBImg(:,:,2)));
end