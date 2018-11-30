function camera = huaWeiSetup(camera, cameraData)
% camera = huaWeiSetup(camera, camera)

%%

% Set the row & col of the sensor

% camera = cameraSet(camera, 'sensor row', cameraData.sensorRow);
% camera = cameraSet(camera, 'sensor col', cameraData.sensorCol);

% Set the wavelength range
camera = cameraSet(camera, 'sensor wavelength', cameraData.sampleWave);

% color filter transmissivity (visible & IR)
camera = cameraSet(camera, 'sensor filter transmissivities',...
                cameraData.colorFilterTrans);
camera = cameraSet(camera, 'sensor infrared filter',...
                    cameraData.IRFilterTrans);
            
% quantization method
camera = cameraSet(camera, 'sensor quantization method',...
                    strcat(num2str(cameraData.quantizationBit), ' bit'));
% 
% response type                
camera = cameraSet(camera, 'sensor response type', cameraData.responseType);
% 
% Set DSNU and PRNU
camera = cameraSet(camera, 'sensor dsnu level', cameraData.DSNU);
camera = cameraSet(camera, 'sensor prnu level', cameraData.PRNU);

% pixel size
camera = cameraSet(camera, 'pixel pixelwidth',cameraData.pixelSz);
camera = cameraSet(camera, 'pixel pixelheight',cameraData.pixelSz);

% photodetector size
pdSz = cameraData.pixelSz * cameraData.fillFactor;
camera = cameraSet(camera, 'pixel pdwidthandheight',...
                [pdSz, pdSz]);
        
% voltage swing
camera = cameraSet(camera, 'pixel voltageswing', cameraData.voltageSwing);
% 
% conversion gain (NOTICE: we take the 48M mode for now)
camera = cameraSet(camera, 'pixel conversiongain', cameraData.conversionGain48M);
% 
% analog offset
camera = cameraSet(camera, 'sensor analog offset', cameraData.analogOffset);

% dark voltage
camera = cameraSet(camera, 'pixel dark voltage', cameraData.darkVoltage48M);

% read noise
camera = cameraSet(camera, 'pixel read noise volts', cameraData.readNoise48M);

% % set the exposure time
% camera = cameraSet(camera, 'sensor exp time', 0.015);
end