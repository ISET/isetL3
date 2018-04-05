function p_cont = patchContrast(p_data, p_type, c_mean)
% Compute contrast for all patches
%
%   p_cont = patchContrast(p_data, p_type, [c_mean])
%
% Inputs:
%   p_data - patch_data, each column represents one patch
%   p_type - pixel type, same shape as p_data
%   c_mean - optional, containing channel mean of patches
%
% Outputs:
%   p_cont - contrast for all patches
%
% Notes:
%   Patch contrast is computed as mean absolute difference between pixel
%   and its corresponding channel mean.
%
% See also:
%   im2patch, patchChannelMean, patchMean
%
% HJ, VISTA TEAM, 2015

% Check inputs
if notDefined('p_data'), error('p_data required'); end
if notDefined('p_type'), error('p_type required'); end
if notDefined('c_mean'), c_mean = patchChannelMean(p_data, p_type); end

% Compute unique pixel type
% Here, we assume that each patch contains all channels
channels = unique(p_type(:, 1));

% Compute contrast
p_cont = zeros(1, size(p_data, 2));
for ii = 1 : length(channels)
    indx = (p_type == channels(ii));
    p_cont = p_cont + sum(abs(bsxfun(@minus,p_data,c_mean(ii, :)).*indx));
end

end