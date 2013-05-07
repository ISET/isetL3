function [im,illuminantEnergy]=L3ISETmultispectral(reflectances,...
                wave,illname,meanLuminance,filterTransmissions,...
                cameraparams,illuminantlevel,savename)

% Run ISET to generate measurements from multispectral scenes using
% particular filters.
%
% [im,illuminantEnergy]=L3ISETmultispectral(reflectances,...
%                 wave,illname,meanLuminance,filterTransmissions,...
%                 cameraparams,illuminantlevel,savename)
%
% INPUTS:
%   reflectances:     Matrix giving reflectances of scene,
%                     size(reflectances)= n x m x length(wave)
%   wave:       Vector giving the wavelength samples
%   illname:    String containing filename of the illuminant shape
%   meanLuminance:  Scalar giving mean scene luminance in units of cd/m^2
%                   If empty, no scaling occurs and the loaded illuminant's
%                   intensity is used.
%   filterTransmissions:    Matrix giving camera sensitivities
%                   size(filterTransmissions)=length(wave) x number filters
%   cameraparams:  Structure giving many parameters for the optics, sensor,
%                  etc.  Fields include:  horizontalFOV,fNumber,
%                  exposureDuration,focalLength,darkvoltage,readnoise,dsnu,
%                  prnu,voltageSwing,wellCapacity,fillfactor,pixelSize,
%                  conversiongain,quantizationMethod

%   horizontalFOV:  Scalar giving degrees of horizontal field of view 
%               (warning is displayed if  scene and sensor resolution are 
%               dissimilar)
%   fNumber:    Dimensionless, ratio of aperture and focal length, 
%               4 is good and 12-16 is blurry
%   illuminantlevel:   (Optional) scalar to multiply by illuminant for each
%               wavelength, only used if meanLuminance=[]
%   savename:   (Optional) String containing filename to save resultant image
%               if not passed in nothing will be saved
%
% OUTPUT:
%   im:         computed image that is also stored in savename if passed in,
%               contains multiple layers corresponding to the filters in
%               cfaname
%   illuminantEnergy:   vector giving the energy of the illuminant for the
%                       scene after adjusting to get the desired
%                       meanLuminance
%
%Exposure is set to 1/60 seconds so SNR can be controlled by varying the mean
%luminance.
%
%Code is modeled after estCreateMultipleGroundTruth and iset_input_images.
%
% Copyright Steven Lansel, 2010


%% Scene (modeled after iset_get_optics)

% following is modeled after sceneFromFile(imname,'multispectral') which
% may be used for ISET compressed scenes

scene = sceneCreate('multispectral');
scene = sceneSet(scene,'wave',wave);
scene = sceneSet(scene,'fov',cameraparams.horizontalFOV); % match the scene field of view (fov) with the sensor fov


% Read the prescribed illuminant
illuminantEnergy = vcReadSpectra(illname,wave);

if isempty(meanLuminance) && ~isempty(illuminantlevel)
    illuminantEnergy=illuminantEnergy*illuminantlevel;
end

illuminantQuanta=Energy2Quanta(wave,illuminantEnergy);

%following converts reflectances to quanta (photons) but name is not
%changed to avoid memory replication
for ii=1:length(wave)
    reflectances(:,:,ii) = reflectances(:,:,ii)*illuminantQuanta(ii);
end

if isa(reflectances,'single')
    reflectances=double(reflectances);
end

scene = sceneSet(scene,'cphotons',reflectances);

aspectratio=size(reflectances,2)/size(reflectances,1);  %used later







% clear reflectances






scene = sceneSet(scene,'illuminantEnergy',illuminantEnergy);

scene = sceneSet(scene,'illuminantComment',illname);

% Set the mean luminance as per the simulation
if ~isempty(meanLuminance)
    scene = sceneAdjustLuminance(scene,meanLuminance);
end

illuminantEnergy = sceneGet(scene,'illuminantEnergy');

%% Optics (modeled after iset_get_optics)
oi = oiCreate;
optics = oiGet(oi,'optics'); %
optics = opticsSet(optics,'fnumber',cameraparams.fNumber);
optics = opticsSet(optics,'offaxis','skip');
% optics = opticsSet(optics,'offaxis','cos4th');
optics = opticsSet(optics,'focallength',cameraparams.focalLength);
oi = oiSet(oi,'optics',optics);
oi = oiCompute(scene,oi);
% 
% figure
% plot(energy2quanta(wave,radiance2irradiancefactor*illuminantEnergy))
% hold on
% plot(squeeze(max(max(oiGet(oi,'photons'),[],1),[],2)),'-rx')




%% Sensor (modeled after sensorCreate)
%
%  We create multiple monchrome sensors that each have a different spectral
%  responsivity.  We capture the scene with them.  Then we can get the
%  electrons out for every point, as if we had a perfect multi-well
%  camera.

sensor = sensorCreate('monochrome');
sensor = sensorSet(sensor,'wave',wave);
sensor.color.filterSpectra=ones(length(wave),1);   %fixes length if length(wave)~=31
sensor.color.irFilter=ones(length(wave),1);    %fixes length if length(wave)~=31
sensor.pixel.spectralQE=ones(length(wave),1);    %fixes length if length(wave)~=31

sensor = sensorSet(sensor,'quantizationMethod',cameraparams.quantizationMethod); 
sensor = sensorSet(sensor,'NoiseFlag',0);  % Turn off noise

pixel = sensorGet(sensor,'pixel');
pixel = pixelSet(pixel,'size',[cameraparams.pixelSize cameraparams.pixelSize]);   % Pixel Size
pixel = pixelSet(pixel,'conversiongain', cameraparams.conversiongain);        % Volts/e-
    
sensor = sensorSet(sensor,'pixel',pixel);
sensor = sensorSet(sensor,'exposuretime',cameraparams.exposureDuration); % in units of seconds
sensor = pixelCenterFillPD(sensor,cameraparams.fillfactor);


%Following sets the right aspect ratio for sensor (number of pixels in the
%rows/columns are later changed by sensorSetSizeToFOV, only ratio is set here)
rows=100;   %an arbitrary number since only the ratio is of interest now
cols=round(rows*aspectratio);
sensor = sensorSet(sensor,'rows',rows);
sensor = sensorSet(sensor,'cols',cols);

%Following sets horizontal field of view to desired value
sensor = sensorSetSizeToFOV(sensor,cameraparams.horizontalFOV,scene,oi);

sensorsize=sensorGet(sensor,'size');
rows=sensorsize(1);     cols=sensorsize(2);

% This produces different channel sensor values that we will place in the
% monochrome sensor.
numchannels=size(filterTransmissions,2);


im = zeros(rows,cols,numchannels);
for kk=1:numchannels;
    s = sensorSet(sensor,'filterspectra',filterTransmissions(:,kk));
    s = sensorSet(s,'Name',sprintf('Channel-%.0f',kk));
    s = sensorCompute(s,oi,0);
    im(:,:,kk) = sensorGet(s,'volts');
end



%% Save Result
if nargin==11 & ~isempty(savename)
    save(savename,'im','illname','cfaname','noisetype','meanLuminance','illuminantEnergy','cameraparams')
end