function [inImg, outImg, pType] = dataGet(obj, nScenes, varargin)
% Compute the corresponding sensor and target images for L3 training
%
%  [inImg, outImg, pType] = dataGet(obj, nImg)
%
% Inputs:
%   obj  - l3DataISET object
%   nScenes - number of scenes to be retrieved (must be subset of
%          the scenes, default is all the scenes).  The number of
%          images returned is nScenes times the number of
%          illuminant levels used in the simulation.
%   varargin:
%      varargin{1} = recompute (true/false)
%
% Outputs:
%   inImg  - cell array of camera raw images
%   outImg - target output image
%   pType  - underlying pixel index in cfa for each position in camera raw
%            image data
%
% See also:
%   l3DataCamera.dataGet
%
% QT/HJ/BW (c) Stanford VISTA Team 2015
%
% Update/Todo: Change the illuminant level to two sets: input illuminant
% and target illuminant. This is used for HDR application. (ZL, 2018)

%% Check inputs
if notDefined('nScenes')
    % The number of images is each scene times the number of
    % illuminant level simulations for that scene.
    nScenes = obj.get('nscenes');
    nImg = obj.get('nscenes')*length(obj.illuminantLev);
else
    nImg = nScenes*length(obj.illuminantLev);
end

% Check if we force a recompute.s
recompute = false;
if ~isempty(varargin), recompute = varargin{1}; end

if nScenes > obj.get('nscenes'), error('Not enough data'); end

% Return data in obj directly if user allows and they have been stored
if ~recompute && ~isempty(obj.outImg) && ~isempty(obj.inImg) ...
        && ~isempty(obj.pType)
    inImg  = obj.inImg(1:nImg);
    outImg = obj.outImg(1:nImg);
    pType  = obj.pType;
    return;
end

%% Check camera parameters
% check wavelength consistency
c = obj.get('camera');
c = cameraSet(c, 'sensor wave', obj.get('scene wave'));
c = cameraSet(c, 'sensor noise flag', 2);

% adjust sensor size to match scene
scene = obj.get('scenes', 1);
oi = cameraGet(c, 'oi');

sensor = cameraGet(c, 'sensor');
sensor = sensorSetSizeToFOV(sensor, sceneGet(scene, 'fov'), scene, oi); 
% sensor = sensorSetSizeToFOV(sensor, 45, scene, oi);

% make sure sensor size is a multiple of cfa size
sz = sensorGet(sensor, 'size');
cfaSz = sensorGet(sensor, 'cfa size');
sensor = sensorSet(sensor, 'size', ceil(sz ./ cfaSz) .* cfaSz);

% Set sensor back to camera
c = cameraSet(c, 'sensor', sensor);
            
%% Get parameters
%  luminance levels and number of illuminants
levels = obj.get('illuminant levels');
nIllum = obj.get('n illuminants');

% camera noise-free sensor
sensorNF = sensorSet(cameraGet(c,'sensor'), 'noise flag', -1);
% sensorNF = sensorSet(sensorNF, 'exp time', 0.28);
sensorNF = sensorSet(sensorNF, 'sensor analog Offset', 0);
%% Compute sensor images
% print progress info
if obj.verbose
    cprintf('Keywords*', 'Generating data by simulation:');
    str = [];
end

% compute for each scene
for ii = 1 : nScenes
    % Get input scene and illuminat spd
    scene = obj.get('scenes', ii);
    
    for jj = 1 : nIllum
        inIl  = obj.get('in illuminant spd', jj);
        outIl = obj.get('out illuminant spd', jj);

        % Adjust scene for output illluminant
        outScene = sceneAdjustIlluminant(scene, outIl);
        outScene = sceneAdjustLuminance(outScene, 10);

        % Compute desired output
        oi = oiCompute(outScene, oi);
%         Get rid of the xyz, and use the same sensor to get the srgb image
        outImg = sensorComputeFullArray(sensorNF, oi,obj.get('ideal cmf'));
        outImg = xyz2srgb(outImg / max(max(max(outImg))));
%         outImg = sensorComputeFullArray(sensorNF, oi, ieReadSpectra('RGB.mat', obj.get('scene wave')) );
%         sensorData = sensorCompute(sensorNF, oi);
%         ip = ipCreate;
%         ip = ipCompute(ip, sensorData);
%         outImg = ipGet(ip, 'srgb');
       
        % Adjust scene for input illuminant spd
        inScene = sceneAdjustIlluminant(scene, inIl);

        % Compute raw images for each illuminant level
        for kk = 1 : length(levels)
            % compute index
            indx = (ii-1)*length(levels)*nIllum+(jj-1)*length(levels)+kk;

            % print progress info
            if obj.verbose
                fprintf(repmat('\b', [1 length(str)]));
                str = sprintf('%d/%d', indx, nScenes * length(levels)*nIllum);
                fprintf(str);
            end

            % adjust scene to have desired mean luminance
            inScene = sceneAdjustLuminance(inScene, levels(kk));

            % compute raw image
            c = cameraCompute(c, inScene, 'normal', false);
            
            % If camera is using auto-exposure, we estimate the exposure
            % time and make it a fixed value
            if cameraGet(c, 'sensor auto exposure')
                expTime = autoExposure(cameraGet(c, 'oi'), ...
                    cameraGet(c, 'sensor'));
                c = cameraSet(c, 'sensor exp time', expTime);
            end

            % store raw image and desired output
            obj.inImg{indx} = cameraGet(c, 'sensor volts');
            
            obj.outImg{indx} = outImg * levels(kk);
%             obj.outImg{indx} = outImg;
        end
    end
end

% set back to camera and current object
obj.set('camera', c);

% In case the user asked for these separately
inImg  = obj.inImg;
outImg = obj.outImg;
pType  = obj.pType;

% print progress info
if obj.verbose
    fprintf(repmat('\b', [1 length(str)]));
    cprintf('Comments', 'Done\n');
end

end

%% END
