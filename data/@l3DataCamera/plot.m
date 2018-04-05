function [g, uData] = plot(obj, param, varargin)
% Visualize image data in the object
%
%  Put up an image of the raw (input) and target (output) image data.
%  The raw data are a mosaic and show up as a gray scale image. And the 
%  target is an RGB image, normally
%
% Inputs:
%   param    - string indicating the plot type and can be chosen from
%              'raw': raw mosaic image data
%              'target': target RGB image
%   varargin - optional parameters, now varargin{1} indicates which image
%              to be plotted
%
% Outputs:
%   g        - handle of the figure
%   uData    - data of plotted image
%
% Example:
%    l3d.plot('raw');
%    l3d.plot('target');
%
% HJ/BW, Stanford VISTA TEAM, 2015

% check inputs
if ~isempty(varargin), whichImage = varargin{1}; else whichImage = 1; end

% make plots according to param
switch ieParamFormat(param)
    case {'raw','inImg'}
        g = vcNewGraphWin; uData = obj.inImg{whichImage};
        imagesc(uData); colormap(gray)
    case {'target','outImg'}
        g = vcNewGraphWin; uData = obj.outImg{whichImage};
        imagescRGB(uData);
    otherwise
        error('Unknown parameter %s\n',param);
end


