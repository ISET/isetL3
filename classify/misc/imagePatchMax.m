function c_max = imagePatchMax(raw, cfa, patchSz, ret_vec)
% Compute max value for each patch in one raw image
%
%   c_max = imagePatchMax(raw, cfa, patchSz)
%
% Inputs:
%   raw     - raw image matrix
%   cfa     - cfa pattern of the raw image
%   patchSz - patch size in [row, col]
%   ret_vec - bool, indicating to return a vector or matrix for each
%             channel (RGB format vs WX format)
%
% Outputs:
%   c_max   - channel max matrix / vector
%
% Note:
%   * This output of this function is usually used to determine the
%     saturation type of a patch
%
% See also:
%   imagePatchMeanAndContrast, patchMean, l3ClassifyFast
%
% HJ, Stanford VISTA TEAM, 2016

% Check inputs
if notDefined('raw'), error('raw image data required'); end
if notDefined('cfa'), error('color filter array required'); end
if notDefined('patchSz'), error('patch size required'); end
if notDefined('ret_vec'), ret_vec = true; end

% Convert cfa to pixel type of the full raw image
nPixelTypes = length(unique(cfa));
if size(cfa) < size(raw)
    p_type = cfa2ptype(size(cfa), size(raw));
else
    p_type = cfa;
end

% Init space
c_max = zeros([size(raw)-patchSz+1, nPixelTypes]);
pad_sz = (patchSz-1)/2;
rect = [1+pad_sz([2 1]) size(c_max, 2)-1 size(c_max, 1)-1];

% compute mean for one channel at a time
for ii = 1 : nPixelTypes
    cur_max = imdilate(raw .* (cfa(p_type) == ii), ones(patchSz));
    c_max(:, :, ii) = imcrop(cur_max, rect); 
end

if ret_vec, c_max = RGB2XWFormat(c_max)'; end