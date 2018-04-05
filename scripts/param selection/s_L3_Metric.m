%% s_L3_Metric.m
%
%  Compute some standard metrics for L3 schema. The metric and test chart
%  includes:
%    1) Mecbth color chart for color accuracy
%    2) Slanted bar / spatial frequency chart
%
%  For computing the metric, we train and render on the same set of images
%
%  HJ, VISTA TEAM, 2016

%% Init
ieInit;  % init ISET session
patchSz = [5, 5];
padSz = (patchSz-1)/2;
pixelSize = [1.8 1.8]*1e-6;
fnumber   = 2;

%% Color accuracy

% Create scene
% scene = sceneCreate('macbeth d65');
% scene = sceneCreate('reflectance chart');
% sFiles{1} = 'MunsellSamples_Vhrel.mat';
% sFiles{2} = 'Food_Vhrel.mat';
% sFiles{3} = 'HyspexSkinReflectance.mat';
%
% pSize = 24; sSamples = [70 79 20];
% wave = 400:10:700; grayFlag = true; sampling = 'r';
% scene = sceneCreate('reflectance chart',pSize,sSamples,sFiles,wave,grayFlag,sampling);
% scene = sceneSet(scene,'fov',20);
% ieAddObject(scene); sceneWindow;

% Create a color ramp scene
width = 512; height = 512;

% These are the base colors
colors = [0 0 1; 0 1 1; 0 1 0; 1 1 0; 1 0 0; 1 0 1];
cmap = interp1(colors, linspace(1, size(colors, 1), width));

intMap = logspace(-0.7, 0, height)';
scene_img = ind2rgb(repmat(1:width, [height 1]), cmap);
scene_img = bsxfun(@times, intMap, scene_img);

d = displayCreate('LCD-Apple');
d = displaySet(d, 'gamma', 'linear');
scene = sceneFromFile(scene_img, 'rgb', [], d);
scene = sceneSet(scene, 'h fov', 10);

%  create l3 data structure
camera = cameraCreate;
camera = cameraSet(camera,'pixel size constant fill factor',pixelSize);
camera = cameraSet(camera,'optics fnumber',fnumber);

l3d = l3DataSimulation('sources', {scene},'camera',camera);

% Changes the exposures.  Does not seem to matter
l3d.expFrac = [1 0.1:0.2:0.95];
cfa = cameraGet(l3d.camera, 'sensor cfa pattern');

% Training
%  Ridge regression training object
l3t = l3TrainRidge();

% Training parameters
l3t.l3c.patchSize = patchSz;
l3t.l3c.cutPoints = {logspace(-2, -0.1, 2), []}; % Levels
l3t.train(l3d);
% l3t.fillEmptyKernels;

%  render
l3r = l3Render();
l3_XYZ = ieClip(l3r.render(l3d.inImg{1}, cfa, l3t), 0, 1);
ideal_XYZ = l3d.outImg{1};
ideal_XYZ = ideal_XYZ(padSz(1)+1:end-padSz(1), padSz(2)+1:end-padSz(2), :);

% show image
vcNewGraphWin; imagescRGB(xyz2srgb(ideal_XYZ)); title('Ideal');
vcNewGraphWin; imagescRGB(xyz2srgb(l3_XYZ)); title('L3')

%  compute deltaE difference
de = deltaEab(l3_XYZ, ideal_XYZ, max(max(ideal_XYZ)));

tmp = RGB2XWFormat(ideal_XYZ);
[val,idx] = max(tmp(:,2));
whitePt = tmp(idx,:);
[deltaEImage, params, xyz1, xyz2] = scielab(ideal_XYZ,l3_XYZ,whitePt);
vcNewGraphWin; imagesc(deltaEImage); colorbar;
vcNewGraphWin; hist(deltaEImage(:),100)

%% MTF and frequency
scene = sceneCreate('slanted bar');
vcAddObject(scene); % add to session, used when getting the otf function
% scene = sceneCreate('frequency orientation');

scene = sceneSet(scene, 'h fov', 4);
camera = cameraCreate;
ip = ipCreate;

% create l3 data structure
fList = 2:2:14;
pixelList = [1.2:0.2:3 3.5 4 5 6] * 1e-6;
l3_mtf50 = zeros(length(fList), length(pixelList));
optics_mtf50 = zeros(length(fList), 1);

for ii = 1 : length(fList)
    % set optics f/#
    camera = cameraSet(camera,'optics fnumber',fList(ii));
    
    for jj = 1 : length(pixelList)
        camera = cameraSet(camera,'pixel size constant fill factor',pixelList(jj));
        
        l3d = l3DataSimulation('sources', {scene}, 'camera', camera);
        l3d.expFrac = [1 0.1:0.05:0.95];
        cfa = cameraGet(l3d.camera, 'sensor cfa pattern');
        
        % train
        l3t = l3TrainRidge();
        l3t.l3c.patchSize = patchSz;
        l3t.l3c.cutPoints = {logspace(-4, -0.1, 80), []};
        l3t.train(l3d);
        l3t.fillEmptyKernels;
        
        % render
        l3r = l3Render();
        l3_XYZ = l3r.render(l3d.inImg{1}, cfa, l3t);
        
        % compute MTF50 for L3 rendered image
        [~, lrgb] = xyz2srgb(l3_XYZ);
        ip = ipSet(ip,'result',lrgb);
        mtfData = ieISO12233(ip,l3d.camera.sensor);
        l3_mtf50(ii, jj) = mtfData.mtf50;
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

% Compare MTF50 with different exposure duration
sceneIndx = 1:5;
camera = cameraCreate;
camera = cameraSet(camera,'pixel size constant fill factor', pixelSize);
l3_lum_mtf50 = zeros(length(fList), length(sceneIndx));

for ii = 1 : length(fList)
    % set optics f/#
    camera = cameraSet(camera,'optics fnumber',fList(ii));
    l3d = l3DataSimulation('sources', {scene}, 'camera', camera);
    l3d.expFrac = [1 0.1 0.05 0.03 0.01 0.2:0.05:0.95];
    cfa = cameraGet(l3d.camera, 'sensor cfa pattern');
    
    % train
    l3t = l3TrainRidge();
    l3t.l3c.patchSize = patchSz;
    l3t.l3c.cutPoints = {logspace(-4, -0.1, 80), []};
    l3t.train(l3d);
    l3t.fillEmptyKernels;
    
    % render
    l3r = l3Render();
    for jj = 1 : length(sceneIndx)
        l3_XYZ = l3r.render(l3d.inImg{sceneIndx(jj)}, cfa, l3t);
        
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