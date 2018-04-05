%% s_L3TrainOne
%
%    Reverse engineer Nikon Camera on a single image
%
% HJ, VISTA TEAM, 2015

% Init ISET SESSION
ieInit;

%% Init parameters
cfa = [2 1; 3 4]; % [g r; b g]
patch_sz = [5 5];
   
% Init training data parameters
base = 'http://scarlet.stanford.edu/validation/SCIEN/L3/nikond200/processed/';

% Training & Rendering for each class
s = lsScarlet(base, '.jpg');

%% Train on one file
trainFile = 3;

% load raw and jpg image
img_name = s(trainFile).name(1:end-4);
raw = im2double(imread([base img_name '.pgm']));
jpg = im2double(imread([base img_name '.jpg']));

% build l3Data class
l3d = l3DataCamera({raw}, {jpg}, cfa);

% Init training class
l3t = l3TrainOLS();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.cutPoints = {logspace(-3.8, -1.4, 20), []};

% learn linear filters
l3t.train(l3d);

%% Kernel visualization
classID = 30;   % Some plots show an analysis for just one class
outChannel = 1; % Some plots show one output channel
pType = 1;      % The type of pixel (g1, r, g2, b)

% show kernel image
l3t.plot('kernel image', classID);

% mean plot for one pixel type
l3t.plot('kernel mean', pType);

% prediction vs target in one class
l3t.plot('class prediction', classID);

% residual vs target in one class
l3t.plot('class residual', classID);

% p-value for coefficients in one class
l3t.plot('class p value', classID);

% play the movie of kernel of one pixel type
l3t.plot('kernel movie', pType, outChannel);

%%  Render the image we trained on
l3r = l3Render();

l3_RGB = ieClip(l3r.render(raw, cfa, l3t), 0, 1);
vcNewGraphWin; imshow(l3_RGB);

%% Render one of the other images
testFile = 5;
img_name = s(testFile).name(1:end-4);
[I_rawTest, jpgTest] = loadScarletNikon(img_name, true, pad_sz, offset);
l3_RGB = l3r.render(I_rawTest, cfa, l3t);
imshow(l3_RGB); vcNewGraphWin; imshow(jpgTest)