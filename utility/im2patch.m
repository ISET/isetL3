function [im_patch, pTypeCol] = im2patch(raw_image, patch_size, p_type)
%  convert raw image matrix to patches matrix
%
%    im2patch(raw_image, patch_size, cfa_size)
%
%  Inputs:
%    raw_image   - 2D raw image data matrix
%    patch_size  - size of each patch in [n_row, n_col]
%    p_type      - position of each pixel in cfa repeating pattern
%
%
% Outputs:
%   im_patch  - matrix with each column containing data from one patch
%   pTypeCol  - position of each pixel in cfa, same size as im_patch
%
% Note:
%   1) pTypeCol in this function is different from pType in cfa2ptype
%   2) The output matrix could be quite large. If the input matrix is
%      large, it could be slow.
%
% See also:
%   cfa2ptype
%
% HJ, VISTALAB TEAM, 2015

% Check inputs
if notDefined('raw_image'), error('raw image required'); end
if notDefined('patch_size'), error('patch size required'); end
if notDefined('p_type'), error('cfa size required'); end

% convert
im_patch = im2col(raw_image, patch_size, 'sliding');
if nargout > 1, pTypeCol = im2col(p_type, patch_size, 'sliding'); end

end