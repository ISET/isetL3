function p_data = imagePatchData(raw, indx, patchSz, varargin)
% Select patch data from raw images
%
%    p_data = imagePatchData(raw, indx, patchSz)
%
% Inputs:
%   raw     - raw image data
%   indx    - array of patch index (in output space) we want to select
%   patchSz - patch size
%
% Outputs:
%   p_data  - patch data with data from each patch in columns
%
% See also:
%   l3ClassifyFast
%
% HJ, Stanford VISTA TEAM, 2015

% Check inputs
if ~exist('raw', 'var'), error('raw data required'); end
if ~exist('indx', 'var'), error('index required'); end
if ~exist('patchSz', 'var'), error('patch size required'); end

% convert index to be in raw space
[x, y] = ind2sub(size(raw)-patchSz+1, indx(:));
indx = x + (y-1) * size(raw, 1);

% allocate space for p_data
p_data = zeros(prod(patchSz), length(indx));
outRaw = 1;
for jj = 1 : patchSz(2)
    for ii = 1 : patchSz(1)
        p_data(outRaw, :) = raw(indx);
        indx = indx + 1;
        outRaw = outRaw + 1;
    end
    indx = indx + size(raw, 1)-patchSz(1);
end

end