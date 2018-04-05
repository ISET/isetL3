function [aligned, direction] = checkImageAlignment(raw, rgb, offset, verbose)
% check alignment between Bayer pattern camera raw and rendered rgb
%   aligned = checkImageAlignment(raw, rgb, offset)
%
% Inputs:
%   raw - camera raw image as 2D matrix
%   rgb - camera rendered image
%   offset  - offset between raw and rgb image, default [0 0]
%   verbose - bool, indicating whether or not to print debug information
%
% Outputs:
%   aligned   - bool, indicating if the offset is correct
%   direction - if offset is not correct, to what direction it should be
%               moved towards
%
% See also:
%   alignImages
%
% HJ, VISTA TEAM, 2016

% Check inputs
if notDefined('raw'), error('camera raw image required'); end
if notDefined('rgb'), error('camera rendered image required'); end
if notDefined('offset'), offset = [0 0]; end
if notDefined('verbose'), verbose = true; end

% Init parameters
patchSz = [5 5];
cfa = [1 2; 3 4];
raw = imcrop(raw, [offset(2) offset(1) size(rgb, 2)-1 size(rgb, 1)-1]);
direction = [0 0];

% Train l3 kernels on the two images
l3t = l3TrainOLS();
l3t.l3c.p_max = 1e4;
l3t.l3c.patchSize = patchSz;
l3t.l3c.cutPoints = {quantile(raw(:), linspace(0, 1, 30)), []};
if ~verbose, l3t.verbose = false; l3t.l3c.verbose = false; end
l3t.train(l3DataCamera({raw}, {rgb}, cfa));
close all; l3t.plot('kernel mean', 1);

% Check if the images are aligned by inspecting the kernels
kernels = l3t.kernels(1:numel(cfa):end);
meanK = abs(mean(cell2mat(reshape(kernels, [1 1 length(kernels)])),3));
meanK = meanK(2:end, :);

% adjust vertical alignment
aligned = true;
k = sum(reshape(meanK, [patchSz 3]), 3);
top = sum(k(1:(patchSz(1)-1)/2, :));
bottom = sum(k((patchSz(1)+3)/2:end, :));
if mean(abs(top-bottom)./(top+bottom)) > 0.15
    aligned = false;
    if mean(top) < mean(bottom), direction(1) = 1;
    else direction(1) = - 1; end
end

% adjust horizontal alignment
left = sum(k(:, 1:(patchSz(2)-1)/2), 2);
right = sum(k(:, (patchSz(1)+3)/2:end), 2);
if mean(abs(left-right) ./ (left+right)) > 0.15
    aligned = false;
    if mean(left) < mean(right), direction(2) = 1;
    else direction(2) = - 1; end
end

if aligned
    if all(max(meanK) ~= meanK(13, :))
        aligned = false;
        direction = [nan nan];
    end
end