function [p_mean, c_mean] = patchMean(p_data, p_type, c_mean)
% Compute mean intensity of all patches
%
%   [p_mean, c_mean] = patchMean(p_data, p_type, c_mean)
%
% Inputs:
%   p_data - patch_data, each column represents one patch
%   p_type - pixel type, same shape as p_data
%   c_mean - optional, containing channel mean of patches
%
% Outputs:
%   p_mean - patch mean
%   c_mean - channel mean
%
% See also:
%   im2patch, patchChannelMean, patchContrast
%
% HJ/ZL, VISTA TEAM, 2015

% Compute channel mean if provided
% This is the original version, which is not correct. We can't simply
% calculate the mean based on the mean for each channel, since the number
% of pixels for each channel in patches are not the same!
% if notDefined('c_mean')
%     c_mean = patchChannelMean(p_data, p_type);
% end
% p_mean = mean(c_mean);

% Instead, we should write the function like this:

if notDefined('c_mean')
    [c_mean, c_num] = patchChannelMean(p_data, p_type);
end
p_mean = bsxfun(@rdivide, sum(c_mean.*c_num), sum(c_num));

end