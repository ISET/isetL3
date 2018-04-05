function raw = rawAdjustSize(raw, tgt_size, pad_size, offset)
% Adjust raw camera (Nikon) image to match size and position of camera output
%
%   raw = rawAdjustSize(raw, tgt_size, pad_size, offset)
%
% We find that for the Nikon (and probably other) cameras there is some
% padding and offset between the pixels in the raw image and the pixels in
% the processed output.  We have been able for the Nikon case to align the
% pixels by a pad and offset, which is implemented here.
%
% Note that for some cameras (e.g., Sony) the raw data have a large
% geometric distortion.  We will have to figure out how what to do about
% those cases separately.
%
% Inputs:
%   raw      - camera raw image
%   tgt_size - target jpg image size
%   pad_size - padding size, this depends on patch size
%   offset   - offset of raw and output JPEG RGB data
%
% Outputs:
%   raw - cropped camera raw image
%
% Example:
%    croppedRaw = rawAdjustSize(rawData,[size(jpg,1), size(jpg,2)],[0,0]);
%
% See also:
%   loadScarletNikon
%
% HJ, VISTA TEAM, 2015

% Check inputs
if notDefined('raw'), error('camera raw image required'); end
if notDefined('tgt_size'), error('target jpg image size required'); end
if notDefined('pad_size'), pad_size = [0 0]; end
if notDefined('offset'), offset = [0,0]; end  % Row/Col offset

% Crop raw image
r = tgt_size(1); c = tgt_size(2);
r_start = (size(raw, 1) - r)/2 - pad_size(1) + offset(1);
c_start = (size(raw, 2) - c)/2 - pad_size(2) + offset(2);
raw = imcrop(raw, [c_start, r_start, [c, r]+2*pad_size-1]);

end
