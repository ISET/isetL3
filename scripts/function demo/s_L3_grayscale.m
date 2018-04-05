%% s_Grayscale
%    Learn kernel that converts camera raw into gray scale output
%
%  HJ, VISTA TEAM, 2016

%% Init
ieInit;
patchSz = [5 5];
padSz = (patchSz - 1)/2;

%% Learn linear transform with ISET camera simulation
nImg = 7;
l3d = l3DataSimulation();
[raw, xyz] = l3d.dataGet(nImg);

% normalize y channel
y = cell(size(xyz));
xyz_max = max(max(cell2mat(xyz))); 
for ii = 1 : nImg
    y{ii} = xyz{ii}(:,:,2) / xyz_max(2);
end

% learn the transform
l3t = l3TrainRidge();
l3t.train(l3DataCamera(raw(1:end-1), y(1:end-1), l3d.cfa));

% Render on an image
l3r = l3Render();
l3_y = l3r.render(raw{end}, l3d.cfa, l3t);
tgt_y = y{end}(padSz(1)+1:end-padSz(1), padSz(2)+1:end-padSz(2), :);

vcNewGraphWin; imshow(l3_y);
vcNewGraphWin; plot(l3_y(:), tgt_y(:), '.'); identityLine;

%% Learning the transform in non-linear space
%  Learning the lumiannce (Y) is not challenging and the learned kernel
%  will be exactly the same as the one learned from raw to XYZ (or xyY).
%
%  However, when learning from raw to sRGB vs raw to grayscale, we might
%  see some difference...
rdt = RdtClient('scien');
rdt.crp('/L3/Farrell/D200/garden');

% load train and test data
raw = im2double(rdt.readArtifact('dsc_0768', 'type', 'pgm'));
rgb = im2double(rdt.readArtifact('dsc_0768', 'type', 'jpg'));
gray = rgb2gray(rgb);
cfa = [2 1; 4 3];

raw_test = im2double(rdt.readArtifact('dsc_0769', 'type', 'pgm'));
jpg_test = im2double(rdt.readArtifact('dsc_0769', 'type', 'jpg'));
gray_test = rgb2gray(jpg_test);
tgt_y = gray_test(padSz(1)+1:end-padSz(1), padSz(2)+1:end-padSz(2), :);

% train directly toward monochrome space
l3t = l3TrainRidge();
l3t.train(l3DataCamera({raw}, {gray}, cfa));
l3r = l3Render();
l3_y = ieClip(l3r.render(raw_test, cfa, l3t), 0, 1);

% vcNewGraphWin; imshow(l3_y);

% train in rgb color space and convert to gray image afterwards
l3t = l3TrainRidge();
l3t.train(l3DataCamera({raw}, {rgb}, cfa));

l3r = l3Render();
l3_RGB = ieClip(l3r.render(raw_test, cfa, l3t), 0, 1);
l3_gray = rgb2gray(l3_RGB);

% Compute difference and compare
l3_gray_diff = mean(abs(tgt_y(:) - l3_y(:)));
l3_rgb_diff = mean(abs(tgt_y(:) - l3_gray(:)));