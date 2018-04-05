function [inImg, outImg, pType] = dataGet(obj, nImg, varargin)
% Compute the corresponding sensor images and target images for training
% using ISET simulator
%
%  [inImg, outImg, pType] = dataGet(obj, nImg)
%
% Inputs:
%   obj  - l3DataSimulation object
%   nImg - number of images to be retrieved
%
% Outputs:
%   inImg  - cell array of camera raw images
%   outImg - target output image
%   pType  - underlying pixel index in cfa for each position in camera raw
%            image data
%
% See also:
%   l3DataCamera.dataGet, l3DataISET.dataGet
%
% HJ, VISTA Team, 2015

%% Check inputs
if notDefined('nImg'), nImg = inf; end
if ~isempty(varargin), recompute = varargin{1}; else, recompute = false; end
if length(varargin)>1, sensorSz = varargin{2}; else, sensorSz = []; end

% Return data in obj directly if user allows and they have been stored
if ~recompute && ~isempty(obj.outImg) && ~isempty(obj.inImg) ...
        && ~isempty(obj.pType) && (length(obj.inImg) > nImg || isinf(nImg))
    if isinf(nImg)
        inImg = obj.inImg;
        outImg = obj.outImg;
        pType = obj.pType;
    else
        % Not sure about expFrac - doesn't exist.  So, just deleting
        % inImg  = obj.inImg(1:nImg*length(expFrac));
        % outImg = obj.outImg(1:nImg*length(expFrac));
        inImg  = obj.inImg(1:nImg);
        outImg = obj.outImg(1:nImg);
        pType  = obj.pType;
    end
    return;
end

% Load scenes / optical images if not sufficient
if length(obj.sources) < nImg && ~isinf(nImg), obj.loadSources(nImg); end
if isinf(nImg) && isempty(obj.sources)
    nImg = 7; obj.loadSources(nImg);
end

%% Check camera parameters
% Check for optics
% If there is some optical image inputs as sources, we make sure that the
% scenes are computed with the same optics
for ii = 1 : length(obj.sources)
    if strcmp(obj.sources{ii}.type, 'opticalimage')
        obj.camera = cameraSet(obj.camera, 'oi', obj.sources{ii});
        break;
    end
end

% Adjust sensor size to match field of view
% pType is designed as a matrix, meaning that the sensor size should always
% be the same. Here, we adjust the sensor size to match the first source
% field of view
if isempty(sensorSz)
    source = obj.sources{1};
    
    % get field of view
    if strcmp(source.type, 'scene')
        scene = source; oi = cameraGet(obj.camera, 'oi');
        fov = sceneGet(scene, 'fov');
    else
        scene = []; oi = source;
        fov = oiGet(source, 'fov');
    end
    
    % set sensor size
    s = cameraGet(obj.camera, 'sensor');
    s = sensorSetSizeToFOV(s, fov, scene, oi);
    
    % set sensor to camera
    obj.camera = cameraSet(obj.camera, 'sensor', s);
end

% camera noise-free sensor
c = obj.camera;
sensorNF = sensorSet(cameraGet(c, 'sensor'), 'noise flag', -1);
sensorNF = sensorSet(sensorNF, 'exp time', 1);

%% Compute sensor images
% print progress info
if obj.verbose
    cprintf('Keywords*', 'Generating data by simulation:');
    str = [];
end

% allocate space for inImg and outImg
totImg = length(obj.sources);
obj.inImg = cell(totImg * length(obj.expFrac), 1);
obj.outImg = cell(totImg * length(obj.expFrac), 1);

% compute for each scene / oi
for ii = 1 : totImg
    % compute optical image if source is scene
    source = obj.sources{ii};
    switch source.type
        case 'scene'
            oi = oiCompute(source, cameraGet(obj.camera, 'oi'));
        case 'opticalimage'
            oi = source;
        otherwise
            error('Unknown source type: %s', source.type);
    end
    
    % Adjust illuminant level and attach oi to camera
    oi = oiAdjustIlluminance(oi, 100); % reference luminace as 100 cd/m2
    c = cameraSet(c, 'oi', oi);
    
    % Compute desired output
    outImg = sensorComputeFullArray(sensorNF, oi, obj.idealCMF);
    
    % Compute full exposure time
    % 0.95-0.97 is the number of saturated pixels we allow
    % We need to figure out how to set this.
    fullExpTime = autoExposure(oi, cameraGet(c, 'sensor'), 0.99, 'specular');
    
    % Compute raw images for each illuminant level
    for jj = 1 : length(obj.expFrac)
        % compute index
        indx = (ii-1)*length(obj.expFrac) + jj;
        
        % adjust exposure time
        c = cameraSet(c, 'sensor exp time', fullExpTime * obj.expFrac(jj));
        
        % print progress info
        if obj.verbose
            fprintf(repmat('\b', [1 length(str)]));
            str = sprintf('%d/%d', indx, totImg * length(obj.expFrac));
            fprintf(str);
        end
        
        % compute raw image
        c = cameraCompute(c, 'oi', 'normal', false);
        
        % store raw image and desired output
        obj.inImg{indx} = cameraGet(c, 'sensor volts');
        obj.outImg{indx} = outImg * obj.expFrac(jj);
    end
end

% set return values
inImg  = obj.inImg;
outImg = obj.outImg;
pType  = obj.pType;

% print progress info
if obj.verbose
    fprintf(repmat('\b', [1 length(str)]));
    cprintf('Comments', 'Done\n');
end

end

