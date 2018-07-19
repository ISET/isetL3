function [s, k] = imagePatchRandom(raw, ~, patchSz, varargin)
% Compute patch response in the camera raw image using random kernels
%
%   [s, k] = imagePatchRandom(raw, cfa, patchSz)
%
% Inputs:
%   raw     - raw image matrix
%   cfa     - cfa pattern of the raw image
%   patchSz - patch size in [row, col]
%
% Outputs:
%   s       - patch mean response in a row vector
%   k       - random kernel
%
% Note:
%   * This funciton assumes that pixels in CFA pattern are all different
%     and thus we can use shift-invariant filter to compute the mean patch
%     response
%   * This function is used to compute baseline performance only, do not
%     use it in real l3 training or rendering
%
% See also:
%   imagePatchContrast, imagePatchMean, l3ClassifyStats
%
% HJ, Stanford VISTA TEAM, 2016

% Check inputs
if notDefined('raw'), error('raw image data required'); end
if notDefined('patchSz'), error('patch size required'); end

% generate filter kernel
k = randn(patchSz);

% filter image to find the mean response
p_mean = conv2(raw, rot90(k, 2), 'valid');

% build returning statistics matrix
s = p_mean(:)';

end
