function dataIG = removeOutOfGamut(data, wave, lights)

lights = {'D65'};

nwave = length(wave);
nsamples = size(data,2);
IG = ones(nsamples,1);

r = ceil(sqrt(nsamples)); c = ceil(nsamples/r);
dataExt = [data,data(:,ones(r*c-nsamples,1))];

scene = sceneReflectanceChart(dataExt,[],24,wave,1,'r');
load L3camera_RGBW1_D651
sz = sceneGet(scene,'size') + 20;
camera = cameraSet(camera,'sensor size',sz);
oi     = cameraGet(camera,'oi');
sensor = cameraGet(camera,'sensor');
sDist  = sceneGet(scene,'distance');
scenefov = sensorGet(sensor,'fov',sDist,oi);
scene = sceneSet(scene,'fov',scenefov);

scene  = sceneAdjustIlluminant(scene,'D65.mat');
scene  = sceneAdjustLuminance(scene,50);
[~,xyzD65] = cameraCompute(camera,scene,'idealxyz');

cp(1,1) = 3; cp(1,2) = sz(1)-2;
cp(2,1) = sz(2)-1; cp(2,2) = sz(1)-2;
cp(3,1) = sz(2)-1; cp(3,2) = 2;
cp(4,1) = 3; cp(4,2) = 2;
% Number of rows/cols in the patch array
r = scene.chartP.rowcol(1); % This show be a sceneGet.
c = scene.chartP.rowcol(2);
[mLocs,pSize] = chartRectanglesFG(cp,r,c);

% These are down the first column, starting at the upper left.
delta = round(min(pSize)/4); % Central portion of the patch
tgtXYZ = zeros(size(mLocs,2),3);
for ii=1:size(mLocs,2)
    tgtXYZ(ii,:) = squeeze(mean(mean(xyzD65(mLocs(1,ii)+(-delta:delta),mLocs(2,ii)+(-delta:delta),:),1),2));
end
whiteXYZ = tgtXYZ(r*(c-1)+1,:)
max(tgtXYZ(:))

% imagesc(xyz2srgb(xyzD65/max(xyzD65(:)))), hold on
% for ii=1:size(mLocs,2)
%     plot(mLocs(2,ii)+delta,mLocs(1,ii)+delta,'o'); 
%     plot(mLocs(2,ii)-delta,mLocs(1,ii)-delta,'o'); 
% end
% pause, hold off

for nl = 1:length(lights)
    
    scene = sceneAdjustIlluminantEq(scene,[lights{nl},'.mat']);
    [~,xyzIll] = cameraCompute(camera,scene,'idealxyz');

    tgtXYZ = zeros(size(mLocs,2),3);
    for ii=1:size(mLocs,2)
        tgtXYZ(ii,:) = squeeze(mean(mean(xyzIll(mLocs(1,ii)+(-delta:delta),mLocs(2,ii)+(-delta:delta),:),1),2));
    end
    xyzIll = tgtXYZ(1:nsamples,:) / max(whiteXYZ);
    xyzIll2 = RGB2XWFormat(srgb2xyz(xyz2srgb(XW2RGBFormat(xyzIll,nsamples,1))));
    
    IG = IG & (sum((xyzIll - xyzIll2).^2,2) < 1e-15);
    
end

dataIG = data(:,IG);

