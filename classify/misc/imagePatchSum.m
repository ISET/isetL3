function [c_sum, c_count] = imagePatchSum(raw, cfa, patchSz)
% Compute channel mean and number of pixels in each channel in each patch
%
%   [c_sum, c_count] = imagePatchSum(raw, cfa, patchSz)
%
% Inputs:
%   raw     - raw image matrix
%   cfa     - cfa pattern of the raw image
%   patchSz - patch size in [row, col]
%
% Outputs:
%   c_sum   - channel sum matrix in MxNxnChannel
%   c_count - number of pixels for each channel in each patch
%
% Note:
%   * This function computes patch mean and channel mean based on image
%     data while patchMean function takes patch data (data after im2col)
%     Usually, im2col can be slow and takes great amount of memory. Thus,
%     if only the mean is desired (not patch data), this method is more
%     recommended
%   * patch mean can be easily computed as mean(c_sum./c_count, 3)
%
% See also:
%   imagePatchMeanAndContrast, patchMean, l3ClassifyStats
%
% HJ, Stanford VISTA TEAM, 2015

% Check inputs
if notDefined('raw'), error('raw image data required'); end
if notDefined('cfa'), error('color filter array required'); end
if notDefined('patchSz'), error('patch size required'); end

% Convert cfa to pixel type of the full raw image
nPixelTypes = length(unique(cfa));
if size(cfa) < size(raw)
    p_type = cfa2ptype(size(cfa), size(raw));
else
    p_type = cfa;
end

% Init space
c_sum = zeros([size(raw)-patchSz+1, nPixelTypes]);
c_count = zeros([size(raw)-patchSz+1, nPixelTypes]);

% pad p_type and raw data with zeros for easy-computing using cumsum
raw = padarray(raw, [1 1], 0, 'pre');

% compute mean for one channel at a time
for ii = 1 : nPixelTypes
    % pick out data from one channel
    indx = (cfa(p_type) == ii);
    indx = padarray(indx, [1 1], 0, 'pre');

    % compute channel mean
    c_img = cumsum(cumsum(raw .* indx, 1), 2); % compute cumulative sum
    c_sum(:, :, ii) = c_img(patchSz(1)+1:end, patchSz(2)+1:end) - ...
        c_img(1:end-patchSz(1), patchSz(2)+1:end) - ...
        c_img(patchSz(1)+1:end, 1:end-patchSz(2)) + ...
        c_img(1:end-patchSz(1), 1:end-patchSz(2));
    
    % compute channel count if desired
    if nargout > 1
        count = cumsum(cumsum(indx, 1), 2);
        c_count(:, :, ii) = count(patchSz(1)+1:end, patchSz(2)+1:end) - ...
            count(1:end-patchSz(1), patchSz(2)+1:end) - ...
            count(patchSz(1)+1:end, 1:end-patchSz(2)) + ...
            count(1:end-patchSz(1), 1:end-patchSz(2));
    end
end