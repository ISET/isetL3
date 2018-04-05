function [rawData, jpg] = loadScarletNikon(imgName, cropFlag, varargin)
%% Load Nikon Camera Image Data from Scarlet Server
%    [rawData, jpgImg] = loadScarletNikon(imgName, process)
%
%  Inputs:
%    imgName     - name of the image
%    cropFlag    - whether or not to crop the rawData
%    varargin{1} - pad size, used when cropFlag is true, default is 0
%    varargin{2} - offset, relationship between Raw and processed, default 0 
%
%  Outputs:
%    rawData - image raw data
%    jpgImg  - jpeg image
%
%  Example:
%    [rawData, jpgImg] = loadScarletNikon('DSC_0767', true, 2);
%
%  See also:  rawAdjustSize(),
%
%  (HJ) VISTA TEAM, 2015

%% Check inputs
if ieNotDefined('imgName'), error('image name required'); end
if ieNotDefined('cropFlag'), cropFlag = true; end
if isempty(varargin), padSz = [0 0]; else padSz = varargin{1}; end
if length(varargin) > 1, offset = varargin{2}; else offset = [0,0]; end

%% Load image
imgDir = 'http://scarlet.stanford.edu/validation/SCIEN/L3/nikond200';
rawData = imread([imgDir '/PGM/' imgName '.pgm']); % raw image
rawData = im2double(rawData);

jpg = imread([imgDir '/JPG/' imgName '.JPG']); % jpeg image
jpg = im2double(jpg);

% make sure that jpgImg and rawData are in same direction (vertical or
% horizontal)
if xor(size(jpg,1)>size(jpg,2), size(rawData,1)>size(rawData,2))
    rawData = rot90(rawData, -1);
end

% adjust size 
% raw image size is larger than jpeg by 24 pixels in height and 28 pixels 
% in width. we crop the raw image to match the jpg image
if cropFlag
    rawData = rawAdjustSize(rawData, [size(jpg, 1) size(jpg, 2)], padSz, offset);
end

end