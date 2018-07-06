function RGBImg = patchVec2RGBFormat(patchVec, rawImgSz, patchSz, format, varargin)
% Reconstruct the image from the ML neural network.
% 
%       RGBImg = patchVec2RGBFormat(patchVec, rawImgSz, patchSz, format, varargin)
% 
% Description
%    This function returns the reconstructed RGB image. It takes the vector 
%    result from the model and convert the vector back to the [row, col, channel]
%    format RGB image.
% 
% Inputs
% 
% Optional key/value pairs
%   None
%
% Returns
%   RGBImg
% 
% ZL/BW, 2018
% 
% See also raw2PatchVecFormat, RGB2patchVecFormat
% 
% Example:
%{
    scene = sceneCreate; xyzImages = sceneGet(scene, 'xyz');
    vcNewGraphWin; imagescRGB(xyzImages);
    patchVec = RGB2patchVecFormat(xyzImages, [5, 5], 'rggb');

    rgbRecImg = patchVec2RGBFormat(patchVec, [size(xyzImages, 1),...
    size(xyzImages, 2)], [5, 5],'rggb');
    vcNewGraphWin; imagescRGB(rgbRecImg);
%}
%% Extract the parms
p = inputParser;

p.addRequired('patchVec', @ismatrix);
p.addRequired('rawImgSz', @ismatrix);
p.addRequired('patchSz', @ismatrix);

format = ieParamFormat(format);
p.addRequired('format', @ischar);
p.parse(patchVec, rawImgSz, patchSz, format, varargin{:});

patchVec = p.Results.patchVec;
rawImgSz = p.Results.rawImgSz;
patchSz = p.Results.patchSz;
format = p.Results.format;

% Get the dimension of the patch
rPatch = patchSz(1);
cPatch = patchSz(2);

% Get the dimension of the rawData
rRawData = rawImgSz(1);
cRawData = rawImgSz(2);

%% 
switch format
    case 'single'
        
        boundary = ceil(rPatch/2);
        rowSamps = boundary : (rRawData - boundary);
        boundary = ceil(cPatch/2);
        colSamps = boundary : (cRawData - boundary);
        RGBImg = zeros(numel(rowSamps), numel(colSamps), 3);
        
%         for rr = 1 : rRecImg
%             for cc = 1 : cRecImg
%                 RGBImg(rr, cc, :) = patchVec((rr - 1) * cRegImg + cc, :);
%             end
%         end
        RGBImg = XW2RGBFormat(patchVec, numel(rowSamps), numel(colSamps));
        
    case 'rggb'
        % Positions where r pixel locates
        boundary = ceil(rPatch / 2);
        rowSamps = boundary:2:(rRawData - boundary); 
        boundary = ceil(cPatch/2);
        colSamps = boundary:2:(cRawData - boundary);
        
        % Dimension of the image to be constructed (2*numel because rggb format)
        RGBImg = zeros(2 * numel(rowSamps), 2 * numel(colSamps), 3);
        
        redChnl     = patchVec(:, 1:3);
        greenChnl_1 = patchVec(:, 4:6);
        greenChnl_2 = patchVec(:, 7:9);
        blueChnl    = patchVec(:, 10:12); 

        RGBImg(1:2:end, 1:2:end, :) = XW2RGBFormat(redChnl, numel(rowSamps), numel(colSamps));
        RGBImg(2:2:end, 1:2:end, :) = XW2RGBFormat(greenChnl_1, numel(rowSamps), numel(colSamps));
        RGBImg(1:2:end, 2:2:end, :) = XW2RGBFormat(greenChnl_2, numel(rowSamps), numel(colSamps));
        RGBImg(2:2:end, 2:2:end, :) = XW2RGBFormat(blueChnl, numel(rowSamps), numel(colSamps));

end

RGBImg = RGBImg / max(max(RGBImg(:,:,2)));
end