%% Huawei Camera sensor properties setup

%% init
ieInit;

%% load the data
dataPath = '/home/zhenglyu/Research/isetL3/local/';
dataName = 'huaweiSensorParm.mat';

cameraData = load(strcat(dataPath, dataName));


%% Set the camera with the Huawei parameter
camera = cameraCreate;

% Create the quadra pattern
camera = cameraSet(camera,'sensor',sensorCreateQuad);

% Set the row & col of the sensor

camera = cameraSet(camera, 'sensor row', cameraData.sensorRow);
camera = cameraSet(camera, 'sensor col', cameraData.sensorCol);

% Set the wavelength range
camera = cameraSet(camera, 'sensor wavelength', cameraData.sampleWave);

% color filter transmissivity (visible & IR)
camera = cameraSet(camera, 'sensor filter transmissivities',...
                cameraData.colorFilterTrans);
camera = cameraSet(camera, 'sensor infrared filter',...
                    cameraData.IRFilterTrans);
             
% quantization method
camera = cameraSet(camerea, 'sensor quantization method',...
                    cameraData.quantizationBit);
% response type                
camera = cameraSet(camera, 'sensor response type', cameraData.responseType);

% Set DSNU and PRNU
camera = cameraSet(camera, 'sensor dsnu level', cameraData.DSNU);
camera = cameraSet(camera, 'sensor prnu level', cameraData.PRNU);

% pixel size
camera = cameraSet(camera, 'pixel pixelwidth', cameraData.pixelSz);
camera = cameraSet(camera, 'pixel pixelheight', cameraData.pixelSz);

% fill factor
camera = cameraSet(camera, 'pixel sizesamefillfactor',...
                cameraData.fillFactor);
            
% voltage swing
camera = cameraSet(camera, 'pixel voltageswing', cameraData.voltageSwing);

% 
                
                


