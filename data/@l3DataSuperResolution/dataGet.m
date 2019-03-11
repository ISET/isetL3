function [inImg, outImg, pType] = dataGet(obj, nImg, varargin)
% Compute the corresponding sensor and target images for L3 training
%
%  [inImg, outImg, pType] = dataGet(obj, nImg, varargin)
%
% Inputs:
%   obj             - l3DataSuperResolution object
%   nImg            - number of the images to be obtained.
%   varargin{1}     - recompute (true/false)
%
% Outputs:
%  inImg            - cell array of camera raw images
%  outImg           - target higher resolution image
%  pType            - underlying pixel index in cfa for each position in
%                     camera raw data
% 
% See also:
%
% ZL/BW, Stanford VISTA Team 2019
%% Setup and check inputs
sources = obj.sources;
recompute = false;
if ~isempty(varargin), recompute = varargin{1}; end

if notDefined('nImg') % make sure we have the number of the image 
    nImg = length(sources);
end

if nImg > length(sources), error('Not enough images'); end

% Return data in obj directly if user allows and they have been stored
if ~recompute && ~isempty(obj.outImg) && ~isempty(obj.inImg) ...
        && ~isempty(obj.pType)
    inImg  = obj.inImg(1:nImg);
    outImg = obj.outImg(1:nImg);
    pType  = obj.pType;
    return;
end
% Allocate space for the inImg and outImg
inImg = cell(1, nImg);
outImg = cell(1, nImg);

% Get the upscale factor
upscaleFactor = obj.upscaleFactor;
%% Set camera parameters
% Check wavelength consistency
c = obj.get('camera');
c = cameraSet(c, 'sensor noise flag', 2);
sensor = cameraGet(c, 'sensor'); % Use the sensor to compute the sensor data.
idealCF = obj.get('ideal cmf');  idealCF = idealCF./ max(max(max(idealCF)));% The ideal color filter to be given to the noise-free sensor.
%% Compute sensor data and target image
if obj.verbose
    cprintf('Keywords*', 'Generating data by simulation:');
    str = [];
end


for ii = 1 : nImg
    curSource = sources{ii};
    
    % Generate the oi if curSource is not scene
    switch curSource.type
        case 'scene'
            oi = cameraGet(c, 'oi');
            oi = oiCompute(oi, curSource);
        case 'opticalimage'
            oi = curSource;
    end
    
    
    % Change the size of the sensor according to the source (which is scene/oi)
    sensor = sensorSet(sensor, 'wave', oiGet(oi, 'wave'));
    sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov'));
    
    % Compute the sesor raw data
    sensor = sensorCompute(sensor, oi);
    inImg{ii} = sensorGet(sensor, 'volts');

    
    if sensorGet(sensor, 'auto exposure')
        expTime = autoExposure(oi, sensor);
        sensor = sensorSet(sensor, 'sensor exp time', expTime);
    end
    
    % Set the noise free sensor
    sensorNF = sensorSet(sensor, 'noise flag', -1);
    sensorNF = sensorSet(sensorNF, 'exp time', 1);
    sensorNF = sensorSet(sensorNF, 'pixel size',...
                    sensorGet(sensor, 'pixel size')/upscaleFactor); % Change the pixel size
    sensorNF = sensorSet(sensorNF, 'pixel pdWidth',...
                    sensorGet(sensor, 'pixel pdWidth')/upscaleFactor);
                
    sensorNF = sensorSet(sensorNF, 'pixel pdHeight',...
                    sensorGet(sensor, 'pixel pdHeight')/upscaleFactor);
                
    sensorNF = sensorSet(sensorNF, 'size', sensorGet(sensor, 'size') * upscaleFactor);
    outImg{ii} = sensorComputeFullArray(sensorNF, oi, idealCF);
    %{
        % Compare the image processed from the sensor and the outImg
        ip = ipCreate;
        ip = ipCompute(ip, sensor);
        lowRes = ipGet(ip, 'data srgb');
        vcNewGraphWin;
        subplot(1, 2, 1); imshow(lowRes);
        subplot(1, 2, 2); imshow(xyz2srgb(outImg{ii}));
    %}
end

% set back to camera and current object
c = cameraSet(c, 'sensor', sensor);
obj.set('camera', c);

% In case the user asked for these separately
obj.inImg = inImg;
obj.outImg = outImg;
pType  = obj.pType;

if obj.verbose
    fprintf(repmat('\b', [1 length(str)]));
    cprintf('Comments', 'Done\n');
end

end