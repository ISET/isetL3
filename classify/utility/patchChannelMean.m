function [c_mean, c_num] = patchChannelMean(p_data, p_type)
% Compute channel mean for all patches
% 
%   c_mean = patchChannelMean(p_data, p_type)
%
% Inputs:
%   p_data - patch_data, each column represents one patch
%   p_type - pixel type, same shape as p_data
%
% Output:
%   c_mean - channel mean of each patch
%
% See also:
%   im2patch, patchMean, patchContrast
%
% HJ, VISTA TEAM, 2015

% Check inputs
if notDefined('p_data'), error('patch data required'); end
if notDefined('p_type'), error('pixel type required'); end

% Compute unique pixel type
% Here, we assume that each patch contains all channels
channels = unique(p_type(:, 1));

% Compute channel mean for each patch
c_mean = zeros(length(channels), size(p_type, 2));
c_num = zeros(length(channels), size(p_type, 2));
for ii = 1 : length(channels)
    indx = (p_type == channels(ii));
    c_mean(ii, :) = bsxfun(@rdivide, sum(p_data.*indx), sum(indx));
    c_num(ii, :) = sum(indx);
end


end