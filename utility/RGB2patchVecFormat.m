function [patchVec, row, col] = RGB2patchVecFormat(rgbImg, patchSz, format, varargin)
% Crop and generate the "label" vector for the ML work.
% 
%       patchVec = RGB2patchVecFormat(rgbImg, patchSz, format, varargin)
% 
% Description
%   Take the rgb image (could be the target or other image), crop, take
%   the target pixel(s) and the put them into a vector.
% 
% The dimension of the patchVec should be:
%           (n, 3)      for the 'single' format
%           (n, 12)     for the 'rggb' format
% 
% Inputs
%   rgbImg
%   patchSz
%   format
% 
% Optional key/value pairs
%  None
%
% Returns
%  patchVec
% 
% ZL/BW, VISTA TEAM, 2018
%
% See also raw2PatchVecFormat, patchVec2RGBFormat
% 
% Example:
%{
    scene = sceneCreate; xyzImages = sceneGet(scene, 'xyz');
    vcNewGraphWin; imagescRGB(xyzImages);
    mlVec = RGB2patchVecFormat(xyzImages, [5, 5], 'rggb');
%}

%% Extract the parms
p = inputParser;

p.addRequired('rgbImg', @isnumeric);
p.addRequired('patchSz', @isvector);

format = ieParamFormat(format);
p.addRequired('format', @ischar);

p.parse(rgbImg, patchSz, format, varargin{:});

rgbImg = p.Results.rgbImg;
patchSz = p.Results.patchSz;
format  = p.Results.format;

% Get the dimension of the patch
rPatch = patchSz(1);
cPatch = patchSz(2);

% Get the dimension of the rawData
[rRGBImg, cRGBImg, ~] = size(rgbImg);

%% Crop and generate the "label" vector

switch format
    case 'single'
        % Calculating how many patches we expect.
        % 
        boundary = ceil(rPatch/2);
        rowSamps = boundary : (rRGBImg - boundary);
        boundary = ceil(cPatch/2);
        colSamps = boundary : (cRGBImg - boundary);
        
        patchVec = zeros(numel(rowSamps), numel(colSamps), 3);
        
        for rr = 1:numel(rowSamps)
            for cc = 1:numel(colSamps)
                
                tgtPixel = rgbImg(rowSamps(rr), colSamps(cc), :);
                patchVec(rr, cc, :) = tgtPixel;
                
            end
        end
        [patchVec,row,col] = RGB2XWFormat(patchVec);
        
    case 'rggb'
        % Calculating how many patches we need to have.
        
        boundary = ceil(rPatch/2);
        rowSamps = boundary:2:(rRGBImg - boundary);
        boundary = ceil(cPatch/2);
        colSamps = boundary:2:(cRGBImg - boundary);

        patchVec = zeros(numel(rowSamps), numel(colSamps), 4 * 3);

        for rr = 1:numel(rowSamps)
            for cc = 1:numel(colSamps)
                
                tmp = rgbImg(rowSamps(rr), colSamps(cc), :);     tgtPixels = tmp;
                tmp = rgbImg(rowSamps(rr)+1, colSamps(cc), :);   tgtPixels = cat(3,tgtPixels,tmp);
                tmp = rgbImg(rowSamps(rr), colSamps(cc)+1, :);   tgtPixels = cat(3,tgtPixels,tmp);
                tmp = rgbImg(rowSamps(rr)+1, colSamps(cc)+1, :); tgtPixels = cat(3,tgtPixels,tmp);

                patchVec(rr,cc,:) = tgtPixels;
            end
        end
        [patchVec,row,col] = RGB2XWFormat(patchVec);
end

end
