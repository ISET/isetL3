%% Test correction

camera = cameraSet(camera,'vci name','default');
vci = camera.vci;
xyz = vci.L3.processing.xyz;
method = 'manual matrix entry';
vci = imageSet(vci, 'illuminant correction method', method);
[xyzcorr,vci] = imageIlluminantCorrection(xyz, vci);

xyzcorr  = xyzcorr / max(xyzcorr(:));
[srgb, lrgb] = xyz2srgb(xyzcorr);
%%
figure, imshow(srgb)
imwrite(srgb, ['L3_tung_to_tung_XYZ_with_' method '.png']);