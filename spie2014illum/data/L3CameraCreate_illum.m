function camera = L3CameraCreate_illum(L3)

% Create a camera object from an L3 structure
%
% camera = L3CameraCreate(L3)

camera.name   = 'L3';
camera.type   = 'camera';
camera.oi = oiClearData(L3Get(L3,'oi'));
camera.sensor = L3Get(L3,'design sensor');

L3small = L3ClearData_illum(L3);

vci = vcimageCreate('L3');
vci = imageSet(vci,'L3',L3small);
camera.vci = vci;