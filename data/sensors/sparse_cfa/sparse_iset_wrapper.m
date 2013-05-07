%% s_SimulateCustomCFA.m:
%
%  Simulate a digital image sensor with custom color filter array spatial
%  arrangements and user-defined quantum efficiency functions.  The pixels
%  can have infrared sensitivity.
%
%  cfaDesignUI: To establish the properties of the pixels, including their
%  quantum efficiency and spatial arrangement, use the routine cfaDesignUI.
%  The spatial arrangement (color filter array) can include many different
%  types of colored pixels.  The color filter array is a repeating block of
%  size (n x m).  The colors pixels can be placed in any arrangement within
%  the block.
%
%  The remaining parts of this script use conventional ISET-3.0 functions
%  to create a scene including infrared data and special infrared
%  processing.
%
%  This script steps through the ISET components: scene, optics, sensor,
%  and processor modules.  In this example, we build a color corrected
%  image based on a sensor with four colors, one of which is infrared.
%
%  The script is arranged into several cells (for Matlab 7.4 or higher).
%  These cells begin with a '%%'.  The ordering of events is:
%
%    0. Specify CFA
%         - sampling arrangement
%         - color filter sensitivities
%         - Save as a file
%    1. Specify scene
%    2. Specify scene optics and compute optical image
%    3. Specify sensor parameters
%            - pixel area, conversion gain, noise characteristics, etc.
%    4. Specify image processor attributes (demosaicing algorithm,
%           color correction, etc.)


%% Define CFA arrangement and color filters
%
% The cfaDesignUI script is an interactive program that allows you to
% design the properties of the color filter array and the spectral quantum
% efficiency of the pixels.
%
% cfaDesignUI first opens a window that asks for CFA attributes (number of
% rows, columns, and distinct colors). These values will be used to create
% a graphical UI that will let a user design custom color filter
% transmittances as Gaussian curves over the wavelength range.
%
% Then, the user specifies the transmittance curves in one of three ways:
%   1. Selecting an exisiting color filter transmittance function
%   2. A Gaussian transmittace function by defining its mean and variance
%   3. A rectangular transmittance function by defiing its center and width
% Spatial locations are designated by clicking on samples in the
% color filter windows.
%
% The CFA design utility is invoked by the matlab script cfaDesignUI.m.
% After a suitable CFA has been designed it must be saved as a matlab Mat
% file. This can be done in the File --> Save CFA menu of the cfaDesignUI
% interface.


% Design and save a CFA using the cfaDesignUI utitlity.

% Here we provide as examples a list of 3 different CFA structures created
% and saved using cfaDesignUI.

cfaList = {'cfaNikonD200IR.mat',...
    'NikonD100.mat',...
    'cfaRGBIR.mat',...
    'cfaRGBNearIR.mat'};

% Choose the CFA that will be used in the simulation
cfaIndex = 3;

% Load Matlab file for the chosen cfa
filterFile = fullfile(isetRootPath,'data','sensor',cfaList{cfaIndex});

filterFile = 'cfa_4x4_5colors'
cfa = load(filterFile);

%% --- SCENE ---

% The sceneList cell has filenames of a number of multispectral scenes
% sceneList = {'books.mat',...
%     'esserCalib.mat',...
%     'esserBlocks.mat',...
%     'fruitPlatter.mat',...
%     'vegCalib.mat',...
%     'vegPlatter.mat',...
%     'MCC.mat',...
%     'MCCfullres.mat'};
% Choose scene
% sceneIndex = 1;

%fullFileName = vcSelectImage;

% fullFileName = fullfile(isetRootPath,'data','images','multispectral',...
%     'ir',sceneList{sceneIndex});

%fullFileName = '/storage-2/resampledSpectralData/VegCalib_wave_12nm_space_2.mat'

%fullFileName = '/home/parmar/work/ISET multispectral/Flowers/Lily/sr338x506/Lily-hdrs.mat'
%fullFileName{1} = '/home/parmar/work/ISET multispectral/Fruit_Vegetables/Fruit/sr338x506/Fruit-hdrs.mat'

%fullFileName = 'J:\work\ISET multispectral\Faces/CaucasianMale/Clinton/sr338x506/Clinton-hdrs.mat';

fullFileName = '/home/parmar/work/ISET multispectral/Faces/CaucasianMale/Clinton/sr338x506/Clinton-hdrs.mat';
%fullFileName{2} = '/home/parmar/work/ISET multispectral/Objects_Tungsten/StuffedAnimals_tungsten/sr338x506/StuffedAnimals_tungsten-hdrs.mat'
%fullFileName{3} = '/home/parmar/work/ISET multispectral/Objects_Tungsten/JapaneseDoll_tungsten/sr338x506/JapaneseDoll_tungsten-hdrs.mat'

%fullFileName = '/home/parmar/work/LEDmultispectral/scenes_iset/ms_iset_person_4_2.mat';

tmpName{1} = 'fruit';
tmpName{2} = 'stuffed_animals';
tmpName{3} = 'japanese_doll'

%%
%%for jj = 1:3
%scene = sceneFromFile(fullFileName{jj},'multispectral');
scene = sceneFromFile(fullFileName,'multispectral');
%     scene = sceneFromFile('RaphaelSchoolOfAthens.JPG','rgb')
%     scene = sceneFromFile('ponte_vecchio.JPG','rgb')
%    scene = sceneFromFile('lions.png','rgb')
scene = sceneAdjustLuminance(scene,5);
scene = sceneSet(scene,'fov',2.64);
vcAddAndSelectObject('scene',scene); sceneWindow;


%% --- Optics ---

%Create the Optics
oi = oiCreate;
% Set optics parameters
optics = oiGet(oi,'optics');
optics = opticsSet(optics,'fnumber',8);
optics = opticsSet(optics,'offaxis','skip');
%optics = opticsSet(optics,'offaxis','cos4th');
optics = opticsSet(optics,'focallength',100e-3);     % Focal length (m)50
% Compute the optics image
oi = oiSet(oi,'optics',optics);
oi = oiCompute(scene,oi);
% View optics image in GUI
vcAddAndSelectObject('oi',oi); oiWindow;   % Check selection method...

%%

%% --- SENSOR ---
% Create the sensor and set its parameters. These parameters were estimated
% from measurments of a Nikon D200 digital SLR camera. Data for some
% attributes (e.g., voltageSwing, wellCapacity, etc.) were not available
% and could not be readily estimated. Standard assumptions have been made
% in choosng values for these attributes. We obtained additional sensor
% information from several different sources, including published data
% sheets For example, we used published data about pixel size,
% voltage swing, well capacity, conversion gain, and analog
% gain. Since conversion gain (volts/electrons) is equal to the voltage
% swing (volts) divided by well capacity (electrons), we could check that
% these numbers are consistent.  The sensor measurements and parameter data
% were obtained for the Nikon cameras when the ISO setting was 100. A
% detailed account of the procedures used for estimating sensor attributes
% can be found in the third section of thefinal report.

wellCapacity = 36000;        % Electrons
voltageSwing = 1.08;         % Volts
pixelSize    = 6e-6;          % 6.095*1e-6;   % Meters
cfaType      = 'custom';     % Bayer pattern
bpp          = 12;           % Twelve bits per pixel adc
fillFactor   = 0.9;          % Note that the sensor is a CCD

% Sensor measurements
prnuLevel = 0.011;       % Photoreceptor nonuniformity
dsnuLevel = 0.00055;   % dark signal

conversionGain = voltageSwing/wellCapacity; % Volts per electron
darkVolts = 0;                              % Bits/sec/pixel
readNoiseVolts = 0.0002;                    % Std dev in V

% Pixel attributes
spectrum.wave = cfa.wavelength;
pixel = pixelCreate('default',0,[],spectrum);
pixel = pixelSet(pixel,'size',[pixelSize pixelSize]);     % Pixel Size
pixel = pixelSet(pixel,'conversionGain',conversionGain);  % Volts/e-
pixel = pixelSet(pixel,'voltageSwing',voltageSwing);      % Volts
pixel = pixelSet(pixel,'darkVoltage',darkVolts) ;         % V/sec/pixel
pixel = pixelSet(pixel,'readNoiseVolts',readNoiseVolts);  % std. dev. in V

% Sensor attributes
sensor = sensorCreate('Custom',pixel,cfa.filterOrder,filterFile);
sensor = sensorSet(sensor,'wave',spectrum.wave);
sensor = sensorSet(sensor,'Name','Custom');
sensor = sensorSet(sensor,'rows',560);
sensor = sensorSet(sensor,'cols',800);
sensor = sensorSet(sensor,'dsnulevel',dsnuLevel);
sensor = sensorSet(sensor,'prnulevel',prnuLevel);

sensor = sensorSet(sensor,'quantizationMethod','12 bit');

sensor = sensorSet(sensor,'pixel',pixel);
sensor = pixelCenterFillPD(sensor,fillFactor);

% Analog gain
sensor = sensorSet(sensor,'analogGain',7.98);
sensor = sensorSet(sensor,'analogOffset',0.0);  % Units are volt

% Set exposure time here. You may need to change this for different CFAs.
sensor = sensorSet(sensor,'autoExposure','off');

expTime = logspace(-2,0,15);
nTimes = length(expTime);

%%
for kk = 5 %:nTimes

    %sensor = sensorSet(sensor,'exposuretime',1/50); % in units of seconds

    sensor = sensorSet(sensor,'exposuretime',expTime(kk)); % in units of seconds

    % Compute the sensor image
    sensor = sensorCompute(sensor,oi);
    % View sensor image in GUI
    vcAddAndSelectObject('sensor',sensor); sensorImageWindow;

    % Render the image

    % Create a display image with basic attributes
    vci = vcImageCreate;
    vci = imageSet(vci,'name','NoColor');
    vci = imageSet(vci,'scaledisplay',1);
    vci = imageSet(vci,'renderGamma',0.6);

    % Enable multichannel demosaicing and color correction optimized for the
    % MCC


%    vci = imageSet(vci,'demosaicmethod','bilinear');
    vci = imageSet(vci,'demosaicmethod','multichannel');
%    vci = imageSet(vci,'demosaicmethod','useIRchannel');

    % If noIR = 1, IR info is omitted in the color transform
    vci = imageSet(vci,'noIR',1);

    % Set color conversion method
    vci = imageSet(vci,'colorconversionmethod','MCC Optimized');
    % vci = imageSet(vci,'colorconversionmethod','Esser Optimized');
    vci = imageSet(vci,'internalColorSpace','XYZ');
    vci = imageSet(vci,'colorBalanceMethod','Gray World');

    % Compute image object
    vci = vcimageCompute(vci,sensor);

    % Render image in ISET processor window
    % vci = vcimageCompute(vci,sensor);
    vcAddAndSelectObject(vci);
    vcimageWindow;

    %         vciH = ieSessionGet('vcimageHandles');
    %         procTrueSize(vciH);
    %         f_number =  num2str(expTime(kk))
    %         ll = length(f_number);
    %
    %
    %         if ll >=4
    %             f_name = sprintf('bayer_%s_%s.png',tmpName{jj},f_number(1:4));
    %         else
    %             f_name = sprintf('bayer_%s_%s.png',tmpName{jj},f_number(1:ll));
    %         end
    %         print('-dpng',f_name);

end

%%end
