
Ti = 3000; Te = 10000; Nils = 50;
Tstep = 1/((1/Te-1/Ti)/Nils);
T = round(1./(1/Ti:1/Tstep:1/Te));
Tstep = (Te-Ti)/Nils;
T = Ti:Tstep:Te;
ils = cell(Nils,1);
for i = 1:Nils+1
   ils{i} = sprintf('B%d',T(i));
end

ils{Nils+2} = 'D65';

scene = sceneFromFile('StuffedAnimals.mat','multispectral');

load L3camera_RGBW1_D651
sz = sceneGet(scene,'size');
camera = cameraSet(camera,'sensor size',sz);
oi     = cameraGet(camera,'oi');
sensor = cameraGet(camera,'sensor');
sDist  = sceneGet(scene,'distance');
scenefov = sensorGet(sensor,'fov',sDist,oi);
scene = sceneSet(scene,'fov',scenefov);

for i = 1:length(ils)
    illum = ils{i};
    if illum(1) ~= 'B'
        scene = sceneAdjustIlluminant(scene,[illum '.mat']);
    else
        illum = illuminantCreate('blackbody',scene.spectrum.wave,str2double(illum(2:end)),100);
        illum = Quanta2Energy(illum.spectrum.wave,double(illum.data.photons));
        scene = sceneAdjustIlluminant(scene,illum);
    end
    [~,xyzIdeal] = cameraCompute(camera,scene,'idealxyz');
    imagesc(xyz2srgb(xyzIdeal/max(max(xyzIdeal(:,:,2))))); axis equal, axis off
    if ils{i}(1) ~= 'B'
        title(ils{i},'FontSize',16,'FontWeight','b'); 
    else
        title(sprintf('Black Body %sK',ils{i}(2:end)),'FontSize',16,'FontWeight','b'); 
    end
    export_fig(sprintf('%s.eps',ils{i}),'-eps','-transparent')
    export_fig(sprintf('%s.png',ils{i}),'-png','-transparent')
end


