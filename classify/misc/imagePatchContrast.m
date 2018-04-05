function s = imagePatchContrast(raw, cfa, patchSz, varargin)
% Compute patch mean response in the camera raw image
%
%   s = imagePatchContrast(raw, cfa, patchSz)
%
% Inputs:
%   raw     - raw image matrix
%   cfa     - cfa pattern of the raw image
%   patchSz - patch size in [row, col]
%
% Outputs:
%   s       - patch contrast in a row vector
%
% Note:
%   * This funciton assumes that pixels in CFA pattern are all different
%     and thus we can use shift-invariant filter to compute the mean patch
%     response
%   * If the CFA or pType is not shift-invariant, use imagePatchSum,
%     imagePatchMeanAndContrast instead
%
% See also:
%   imagePatchMean, l3ClassifyStats
%
% HJ, Stanford VISTA TEAM, 2016

% Check inputs
if notDefined('raw'), error('raw image data required'); end
if notDefined('cfa'), error('color filter array required'); end
if notDefined('patchSz'), error('patch size required'); end

% generate filter kernel
kernel = channelMeanFilterKernel(cfa, patchSz);

% filter image to find the mean response
raw_sq = raw.^2;
p_cont = 0;
for ii = 1 : size(kernel, 3)
    k = rot90(kernel(:, :, ii), 2);
    p_cont = p_cont + conv2(raw_sq,k,'valid') - conv2(raw,k,'valid').^2;
end
p_cont(p_cont < 0) = 0;
p_cont = sqrt(p_cont/size(kernel, 3));

% build returning statistics matrix
s = p_cont(:)';

end

function kernel = channelMeanFilterKernel(cfa, patchSz, varargin)
% Generate channel mean filter kenel for each patch
%   kernel = channelMeanFilterKernel(cfa, patchSz)
%
% Inputs:
%   cfa     - color filter array pattern or pType matrix
%   patchSz - rows and cols of the patches
%
% Output:
%   kernel  - channel mean filter kernel in patchRow x patchCol x nChannel
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
kernel = zeros([size(pattern) length(p_count)]);
for ii = 1 : length(p_count)
    k = zeros(size(pattern));
    k(pattern == ii) = 1 / p_count(ii);
    kernel(:, :, ii) = k;
end

end
