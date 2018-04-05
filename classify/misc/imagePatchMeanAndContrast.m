function s = imagePatchMeanAndContrast(raw, cfa, patchSz, varargin)
% Compute mean and contrast for each patch in one raw image
%
%   s = imagePatchMeanAndContrast(raw, cfa, patchSz)
%
% Inputs:
%   raw     - raw image matrix
%   cfa     - cfa pattern of the raw image
%   patchSz - patch size in [row, col]
%
% Outputs:
%   s       - stats matrix, s(1, :) is patch mean and s(2, :) is contrast
%
% Note:
%   * This function computes patch mean and contrast based on image data
%     while patchMean function takes patch data (data after im2col)
%     Usually, im2col can be slow and takes great amount of memory. Thus,
%     if only the mean and contrast is desired (not patch data), this
%     method is more recommended
%   * The contrast defined in this function is the sum of the variance of
%     all channels and the contrast in patchContrast is defined as the
%     mean absolute difference
%   * If the CFA pattern is shift-invariant, use imagePatchMean and
%     imagePatchContrast instead
%
% See also:
%   imagePatchSum, patchMeanAndContrast, l3ClassifyStats
%
% HJ, Stanford VISTA TEAM, 2015

% Check inputs
if notDefined('raw'), error('raw image data required'); end
if notDefined('cfa'), error('color filter array required'); end
if notDefined('patchSz'), error('patch size required'); end

% Compute patch channel sum
[c_sum, c_count] = imagePatchSum(raw, cfa, patchSz);

% Compure patch mean and contrast
p_mean = mean(c_sum ./ c_count, 3);
c_sum_sq = imagePatchSum(raw.^2, cfa, patchSz);
p_cont = mean((c_sum_sq./c_count - (c_sum./c_count).^2), 3);
p_cont(p_cont < 0) = 0;
p_cont = sqrt(p_cont);

s = [p_mean(:)'; p_cont(:)'];

end