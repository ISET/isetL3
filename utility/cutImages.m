function [rawOut, tOut] = cutImages(raw, tgt, outImgSz)
%% Cut big images to smaller ones
%
%     cutImages(raw, tgt, [outImgSz])
%
% This function cuts large input images (e.g. images directly from camera,
% 3k x 2k) into a bunch of smaller images. Smaller images can be used for
% L3 debugging and better used for L3 training.
%
% Inputs:
%   raw      - 2D raw image
%   tgt      - target images in 3D matrix (e.g. jpeg images)
%   outImgSz - the small image size
%
% Outputs:
%   rawOut   - cell array of 2D cutted small images
%   tOut     - cell array of corresponding target images
%
% Examples:
%   padSz = 2;
%   [I_raw, I_jpg] = loadScarletNikon('DSC_0767', true, padSz);
%   [rOut, tOut] = cutImages(I_raw, I_jpg, [1296 1936]);
%
% Programming Note:
%   If outImgSz is not a multiple of the size of cfa, the output images
%   in (rawOut, tOut) might not share the same cfa pattern (i.e. they could
%   be misaligned)
%
% HJ/BW, VISTA TEAM, 2015

%% Check inputs
if ieNotDefined('raw'), error('raw input required'); end
if ieNotDefined('tgt'), error('target output required'); end
if ieNotDefined('outImgSz'), outImgSz = size(raw) / 2; end
if isscalar(outImgSz), outImgSz = [outImgSz, outImgSz]; end
assert(all(outImgSz<size(raw)), 'outImgSz should be smaller than raw');

%% Cut images
imgSz = [size(tgt, 1) size(tgt, 2)];
padSz = (size(raw) - imgSz)/2;
assert(all(padSz >= 0), 'raw size should be larger than target size');

indx = 1;
tOut = cell(prod(floor(imgSz ./ outImgSz)), 1);
rawOut = cell(prod(floor(imgSz ./ outImgSz)), 1);

w = outImgSz(2)-1; % width
h = outImgSz(1)-1; % height
offset = [0 0 2*padSz]; % offset between raw and target
for y = 1 : outImgSz(2) : size(tgt, 2)-outImgSz(2)+1
    for x = 1 : outImgSz(1) : size(tgt, 1)-outImgSz(1)+1
        tOut{indx} = tgt(x:x+h, y:y+w, :);
        rawOut{indx} = raw(x:x+h+2*padSz(1), y:y+w+2*padSz(2));
        indx = indx + 1;
        offset(2) = offset(2) + padSz(2);
    end
    offset(1) = offset(1) + padSz(1);
    offset(2) = 0;
end

%% END