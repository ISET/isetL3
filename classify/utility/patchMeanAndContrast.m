function stat = patchMeanAndContrast(pData, pTypeCol, varargin)
% Compute mean and contrast of all patches
%
%   stat = patchMean(p_data, p_type, c_mean)
%
% Inputs:
%   pData    - patch data, each column represents one patch
%   pTypeCol - pixel type, same shape as p_data
%
% Outputs:
%   stat   - statistics matrix. row 1 is patch mean and row 2 is contrast
%
% See also:
%   im2patch, patchChannelMean, patchContrast, patchMean
%
% HJ, VISTA TEAM, 2015

[p_mean, c_mean] = patchMean(pData, pTypeCol);
p_cont = patchContrast(pData, pTypeCol, c_mean);
stat = [p_mean; p_cont];

end