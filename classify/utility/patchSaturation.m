function p_sat = patchSaturation(p_data, p_type, thresh)
% Compute contrast for all patches
%
%   p_cont = patchSaturation(p_data, p_type, thresh)
%
% Inputs:
%   p_data - patch_data, each column represents one patch
%   p_type - pixel type, same shape as p_data
%   thresh - threshold of saturation
%
% Outputs:
%   p_cont - contrast for all patches
%
% See also:
%   im2patch, patchChannelMean, patchMean, patchContrast
%
% HJ, VISTA TEAM, 2015

% Check inputs
if notDefined('p_data'), error('p_data required'); end
if notDefined('p_type'), error('p_type required'); end
if notDefined('thresh'), error('threshold required'); end

% Compute unique pixel type
% Here, we assume that each patch contains all channels
channels = unique(p_type(:, 1));

% Compute saturation index
% 
% The saturation is encoded as a binary value.
% For example, suppose there are 4 channels and we set a bit when that
% channel is saturated. There can be 2^4 possible patterns for the case
% with 4 channels, so s.sat is between 0 and 15. Later, we use it for
% indexing and increment by 1
% For example: channel 1 only : 8, channel 2 only: 4, channel 3 only: 2,
% channel 4 only: 1.
p_sat = zeros(1, size(p_data, 2));
sat_indx = p_data > thresh;

for ii = 1 : length(channels)
    indx = (p_type == channels(ii));
    p_sat = 2 * p_sat + any(sat_indx .*indx);
end

p_sat = p_sat + 1;

end