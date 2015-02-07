function dataIG = removeOutOfGamut(data, wave, lights)

nwave = length(wave);
nsamples = size(data,2);

filters = load('XYZ');
[~,Iw] = ismember(wave,filters.wavelength);
filters.wavelength = filters.wavelength(Iw);
filters.data = filters.data(Iw,:);

ill = ieReadSpectra(['D65','.mat'],wave);
ill = ill / (ill' * filters.data(:,2));
whiteD65 = ieXYZFromEnergy(ill',wave);

dataIll = bsxfun(@times, data, ill);
xyzIll = ieXYZFromEnergy(dataIll',wave);
xyzIll = xyzIll / whiteD65(end,2);
xyzIll2 = RGB2XWFormat(srgb2xyz(xyz2srgb(XW2RGBFormat(xyzIll,nsamples,1))));

IG = sum((xyzIll - xyzIll2).^2,2) < 1e-15;
dataIG = data(:,IG);

