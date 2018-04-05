%% s_L3_RGBW_MTF50.m
%
%  HJ, VISTA TEAM, 2016

%% Init
ieInit;
cfa = [2 1; 3 4];
patchSz = [5 5];
nTrain = 4; % train on first 4 images
expFrac = 0.1:0.1:1;

%% Create RGBW camera
% create rgbw camera with 2x2 color filter array
load rgbcCamera.mat  % this is the standard 8x8 rgbc model from omv
camera = cameraSet(camera, 'sensor cfa pattern', cfa);

% scale RGB spectra
fspec = cameraGet(camera, 'sensor filter spectra');
% fspec(:, 1:3) = fspec(:, 1:3)/2;
camera = cameraSet(camera, 'sensor filter spectra', fspec);

min_cut = log10(10 * cameraGet(camera, 'sensor conversion gain'));
max_cut = log10(0.98 * cameraGet(camera, 'sensor voltage swing'));
cutPoints = {logspace(min_cut, max_cut, 40), []};

%% MTF and frequency
scene = sceneCreate('slanted bar');
vcAddObject(scene); % add to session, used when getting the otf function
% scene = sceneCreate('frequency orientation');

scene = sceneSet(scene, 'h fov', 4);
ip = cameraGet(camera, 'ip');

% create l3 data structure
fList = 2:2:14;
pixelList = [1.2:0.2:3 3.5 4 5 6] * 1e-6;
l3_mtf50 = zeros(length(fList), length(pixelList));
optics_mtf50 = zeros(length(fList), 1);

for ii = 1 : length(fList)
    % set optics f/#
    camera = cameraSet(camera, 'optics fnumber', fList(ii));
    
    for jj = 1 : length(pixelList)
        try
        camera = cameraSet(camera, 'pixel size constant fill factor', pixelList(jj));
        
        l3d = l3DataSimulation('camera', camera, 'expFrac', expFrac);
        l3d.loadSources(inf, 'scene');
        l3d.sources{end} = scene;
        
        % train
        l3t = l3TrainRidge();
        l3t.l3c.patchSize = patchSz;
        l3t.l3c.cutPoints = cutPoints;
        l3t.train(l3d);
        l3t.fillEmptyKernels;
        l3t.symmetricKernels;
        
        % render
        l3r = l3Render();
        camera = cameraSet(camera, 'sensor auto exposure', true);
        camera = cameraCompute(camera, scene);
        l3_XYZ = l3r.render(cameraGet(camera, 'sensor volts'), cfa, l3t);
        l3_XYZ(l3_XYZ < 0) = 0;
        
        % compute MTF50 for L3 rendered image
        [~, lrgb] = xyz2srgb(l3_XYZ);
        ip = ipSet(ip,'result',lrgb);
        mtfData = ieISO12233(ip,l3d.camera.sensor); close;
        l3_mtf50(ii, jj) = mtfData.mtf50;
        catch
        end
    end
    
    % compute MTF50 for optics
    % There might be some functions to get this value directly, but I don't
    % remember what it is. Here, we compute it by hand.
    oi = cameraGet(camera, 'oi');
    otf = oiGet(oi, 'optics otf', oi, [], 550);
    fSupport = oiGet(oi, 'fSupport', 'mm');
    freq = fftshift(fSupport(:, :, 1));
    [~, indx] = min(abs(otf(1, 1:end/3)-0.5));
    optics_mtf50(ii) = freq(1, indx);
end

% plot MTF50 of L3, sensor Nyquist and optics MTF50
vcNewGraphWin;
% sensorNyquist = mtfData.nyquistf * ones(length(fList), 1);
plot(fList, [l3_mtf50 optics_mtf50]);
xlabel('Optics f/#'); ylabel('Frequency (cycles/mm)');

%% Compare MTF50 with different exposure duration
sceneIndx = 1:5;
l3_lum_mtf50 = zeros(length(fList), length(sceneIndx));
camera = cameraSet(camera, 'pixel size constant fill factor', 1.4e-6);
expFrac = [1 0.1 0.05 0.03 0.01 0.2:0.1:0.9];

oi = cameraGet(camera, 'oi');
oi = oiCompute(oi, scene);
rgbw_exp = autoExposure(oi, cameraGet(camera, 'sensor'), 0.98, 'specular');

for ii = 1 : length(fList)
    % set optics f/#
    camera = cameraSet(camera,'optics fnumber',fList(ii));
    l3d = l3DataSimulation('camera', camera, 'expFrac', expFrac);
    l3d.expFrac = expFrac;
    
    % train
    l3t = l3TrainRidge();
    l3t.l3c.patchSize = patchSz;
    l3t.l3c.cutPoints = cutPoints;
    l3t.train(l3d);
    l3t.fillEmptyKernels;
    l3t.symmetricKernels;
    
    % render
    l3r = l3Render();
    for jj = 1 : length(sceneIndx)
        camera = cameraSet(camera, 'sensor exposure time', rgbw_exp * expFrac(jj));
        camera = cameraCompute(camera, scene);
        l3_XYZ = l3r.render(cameraGet(camera, 'sensor volts'), cfa, l3t);
        
        % compute MTF50 for L3 rendered image
        [~, lrgb] = xyz2srgb(l3_XYZ);
        ip = ipSet(ip, 'result', lrgb);
        mtfData = ieISO12233(ip, l3d.camera.sensor); close;
        l3_lum_mtf50(ii, jj) = mtfData.mtf50;
    end
end


% plot MTF50 of L3, sensor Nyquist and optics MTF50
vcNewGraphWin; plot(fList, [l3_lum_mtf50 optics_mtf50]);
xlabel('Optics f/#'); ylabel('Frequency (cycles/mm)');