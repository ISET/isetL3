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
% HJ, VISTA TEAM, 2015

% Compute channel mean if provided
if notDefined('c_mean')
    c_mean = patchChannelMean(p_data, p_type);
end
p_mean = mean(c_mean);

end