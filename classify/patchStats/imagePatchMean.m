function s = imagePatchMean(raw, cfa, patchSz, varargin)
% Compute patch mean response in the camera raw image
%
%   s = imagePatchMean(raw, cfa, patchSz)
%
% Inputs:
%   raw     - raw image matrix
%   cfa     - cfa pattern of the raw image
%   patchSz - patch size in [row, col]
%
% Outputs:
%   s       - patch mean response in a row vector
%
% Note:
%   * This funciton assumes that pixels in CFA pattern are all different
%     and thus we can use shift-invariant filter to compute the mean patch
%     response
%   * If the CFA or pType is not shift-invariant, use imagePatchSum,
%     imagePatchMeanAndContrast instead
%
% See also:
%   imagePatchContrast, l3ClassifyStats
%
% HJ, Stanford VISTA TEAM, 2016

% Check inputs
if notDefined('raw'), error('raw image data required'); end
if notDefined('cfa'), error('color filter array required'); end
if notDefined('patchSz'), error('patch size required'); end

% generate filter kernel
k = meanFilterKernel(cfa, patchSz);

% filter image to find the mean response
p_mean = conv2(raw, rot90(k, 2), 'valid');

% build returning statistics matrix
s = p_mean(:)';

end

function kernel = meanFilterKernel(cfa, patchSz, varargin)
% Generate mean filter kenel for each patch
%   kernel = meanFilterKernel(cfa, patchSz)
%
% Inputs:
%   cfa     - color filter array pattern or pType matrix
%   patchSz - rows and cols of the patches
%
% Output:
%   kernel  - 2D mean filter kernel
%
% HJ, VISTA TEAM, 2016

% Check inputs
if notDefined('cfa'), error('cfa pattern required'); end
if notDefined('patchSz'), error('patch size required'); end

% Check if input is cfa or pType
if any(size(cfa) < patchSz)
    cfa = cfa2ptype(size(cfa), ceil(patchSz./size(cfa)).*size(cfa));
end
pattern = cfa(1:patchSz(1), 1:patchSz(2));

% Count the number of each pixel
p_count = histc(pattern(:), unique(pattern));

% Generate mean filter kernel
kernel = 1 ./ p_count(pattern) / length(p_count);

end
