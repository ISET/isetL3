function [g, uData] = scenePlot(obj, varargin)
% Visualize multispectral scenes in the object
%
%  The multispectral scenes are stored in ISET scene format. The function
%  plot their transformed RGB images as a mosaic of selected or all scenes. 
%
%
% Inputs:
%
%   varargin - optional parameters, now varargin{1} indicates which scene
%              to be plotted
%
% Outputs:
%   g        - handle of the figure
%   uData    - data of plotted images (cell array)
%
% Example:
%    l3d.scenePlot(); % plot all scenes
%    l3d.scenePlot(3); % plot first 5 scenes
%    l3d.scenePlot([1, 3, 5]); % plot 1st, 3rd and 5th scenes
%
% QT, Stanford VISTA TEAM, 2015

% check inputs
if ~isempty(varargin) 
    if isscalar(varargin{1})
        assert(obj.get('nscenes') > varargin{1}, 'No such many scenes');
        whichScene = 1 : varargin{1}; % first N scenes
    elseif isvector(varargin{1}) && length(varargin{1}) > 1
        whichScene = varargin{1}; % selected scenes
    end
else
    whichScene = 1 : obj.get('nscenes'); % all scenes
end

scenes = obj.get('scenes');
rgbImgs = cell(size(scenes));

g = vcNewGraphWin;
plotSz = ceil(sqrt(length(whichScene)));

for ii = 1 : length(whichScene)
    thisScene = scenes{whichScene(ii)};
    rgbImgs{ii} = sceneShowImage(thisScene, 0);
    subplot(plotSz, plotSz, ii), imshow(rgbImgs{ii})
end
uData = rgbImgs;
