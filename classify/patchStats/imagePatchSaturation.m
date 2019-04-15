function s = imagePatchSaturation(raw, cfa, patchSz, voltThres, varargin)
    % Compute patch saturation situation in the camera raw image
    %
    %   s = imagePatchMean(raw, cfa, patchSz)
    %
    % Inputs:
    %   raw         - raw image matrix
    %   cfa         - cfa pattern of the raw image
    %   patchSz     - patch size in [row, col]
    %   voltThres   - voltage saturation threshold 
    % 
    % Outputs:
    %   s           - patch saturation situation
    
    % Check inputs
    if notDefined('raw'), error('raw image data required'); end
    if notDefined('cfa'), error('color filter array required'); end
    if notDefined('patchSz'), error('patch size required'); end
    if ~isempty(varargin), refPType = varargin{1}; end
    
    
    % generate pType kernel
    if ~notDefined('refPType')
        s = saturationTypeRef(raw, patchSz, refPType, voltThres);
    else
        
        k = pTypeKernel(cfa, patchSz);
        % Check the saturation situation and return a corresponding number
        s = saturationType(raw, k, voltThres);
    end
    

end

function kernel = pTypeKernel(cfa, patchSz, refPType, varargin)
% Generate pixel type for each patch
%   kernel = pTypeKernel(cfa, patchSz)
% 
% Inputs:
%   cfa     - color filter array pattern or pType matrix
%   patchSz - rows and cols of the patches
%
% Output:
%   kernel  - 2D mean filter kernel
%
% ZL/BW, VISTA TEAM, 2019

% Check inputs
if notDefined('cfa'), error('cfa pattern required'); end
if notDefined('patchSz'), error('patch size required'); end

if ~notDefined('refPType') 
    if any(size(refPType) < patchSz)
        newCfa = repmat(refPType, ceil(patchSz./size(refPType)));
    else
        newCfa = refPType;
    end
    
else
    if any(size(cfa) < patchSz)
        newCfa = cfa2ptype(size(cfa), ceil(patchSz./size(cfa)).*size(cfa));
    else
        newCfa = cfa;
    end
end
kernel = newCfa(1:patchSz(1), 1:patchSz(2));

end

function satClass = saturationType(raw, kernel, voltThres, varargin)
    satClass = zeros(size(raw) - size(kernel) + 1);
    for ii = 1 : size(raw, 1) - size(kernel, 1) + 1
        for jj = 1 : size(raw, 2) - size(kernel, 2) + 1
            curPatch = raw(ii:ii+size(kernel, 1)-1, jj:jj+size(kernel, 2) - 1);
            satPixelType = unique(kernel(curPatch > voltThres));
            if ~isempty(satPixelType)
                satClass(ii, jj) = sum(sum(2.^(satPixelType-1)));
            end
            satClass(ii, jj) = satClass(ii, jj) + 1;
        end
    end
    
    satClass = satClass(:)';
end

function satClass = saturationTypeRef(raw, patchSz, refPType, voltThres)
    pTypeMap = repmat(refPType, ceil(size(raw)./size(refPType)));
    satClass = zeros(size(raw) - patchSz + 1);
    for ii = 1 : size(raw, 1) - patchSz(1) + 1
        for jj = 1 : size(raw, 2) - patchSz(2) + 1
            curPatch = raw(ii:ii+patchSz(1)-1, jj:jj+patchSz(2) - 1);
            kernel = pTypeMap(ii:ii+patchSz(1)-1, jj:jj+patchSz(2) - 1);
            satPixelType = unique(kernel(curPatch > voltThres));
            if ~isempty(satPixelType)
                satClass(ii, jj) = sum(sum(2.^(satPixelType-1)));
            end
            satClass(ii, jj) = satClass(ii, jj) + 1;
        end
    end
    
    satClass = satClass(:)';
end
