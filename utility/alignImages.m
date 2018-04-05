function offset = alignImages(raw, rgb, offset, varargin)
% align raw and rgb images from a Bayer camera
%   [offset, raw] = alignImages(raw, rgb, [offset])
%
% Inputs:
%   raw    - camera raw images
%   rgb    - rendered image
%   offset - optional, the initial guess of offset. If not given, the
%            offset is first estimated by cross correlation
%
% Outputs:
%   offset - offset between the raw and rgb image. For example, if pixel
%            (5, 6) in the raw image corresponds to pixel (1, 1) in the rgb
%            image, the offset should be [4, 5]
%
% Notes:
%   1) The offset here is different from the offset used in rawAdjustSize.
%      The offset in rawAdjustSize is the offset after padding each side
%      with same size. In this function, the offset should always be
%      non-negative
% 
% See also:
%   rawAdjustSize
%
% HJ, VISTA TEAM, 2016

%% Check inputs
if notDefined('raw'), error('camera raw data required'); end
if notDefined('rgb'), error('camera rendered image required'); end
if size(raw,1) < size(rgb, 1) || size(raw, 2) < size(rgb, 2)
    error('raw size must be larger than rendered image size');
end
if any(isodd(size(raw))), error('raw size must be multiple of 2'); end

% init parameters
rgb_sz = [size(rgb, 1), size(rgb, 2)];
cfa = [1 2; 3 4];
patchSz = [5 5];

%% Initialize offset if not given
if notDefined('offset')
    % compute raw luminance as sum of pixels inside cfa
    raw_lum = raw(1:2:512, 1:2:512) + raw(2:2:512, 1:2:512) + ...
              raw(1:2:512, 2:2:512) + raw(2:2:512, 2:2:512);
    rgb_lum = sum(rgb(1:400, 1:400, :), 3);
    
    % compute cross-correlation
    crr = xcorr2(raw_lum, rgb_lum);
    [~, pos] = max(crr(:));
    [r, c] = ind2sub(size(crr), pos);
    offset = max([400-r+1, 400-c+1]*2, 0);
end

%% Check and update offset
while true
    fprintf('offset: [%d, %d]\n', offset(1), offset(2));
    l3t = l3TrainOLS();
    l3t.l3c.p_max = 1e4;
    l3t.l3c.patchSize = [5 5];
    l3t.l3c.cutPoints = {logspace(-3.5, -1.2, 30), []};
    
    I_raw = imcrop(raw, [offset(2) offset(1) rgb_sz(2)-1 rgb_sz(1)-1]);
    l3t.train(l3DataCamera({I_raw}, {rgb}, cfa));
    
    close; l3t.plot('kernel mean', 1); drawnow;
    kernels = l3t.kernels(1:numel(cfa):end);
    meanK = abs(mean(cell2mat(reshape(kernels, [1 1 length(kernels)])),3));
    meanK = meanK(2:end, :);
    
    % adjust vertical alignment
    updated = false;
    k = sum(reshape(meanK, [patchSz 3]), 3);
    top = sum(sum(k(1:(patchSz(1)-1)/2, :)));
    bottom = sum(sum(k((patchSz(1)+3)/2:end, :)));
    if abs(top-bottom)/(top+bottom) > 0.1
        updated = true;
        if top < bottom, offset(1) = offset(1)+1;
        else offset(1) = offset(1) - 1; end
    end
    
    % adjust horizontal alignment
    left = sum(sum(k(:, 1:(patchSz(2)-1)/2)));
    right = sum(sum(k(:, (patchSz(1)+3)/2:end)));
    if abs(left-right) / (left+right) > 0.1
        updated = true;
        if left < right, offset(2) = offset(2) + 1;
        else offset(2) = offset(2) - 1; end
    end
    
    if ~updated, return; end
end