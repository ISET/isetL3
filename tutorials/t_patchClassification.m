%% t_patchClassification
% Scripts used to demonstrate the classes was correctly classified
% Super simple patches are used for experiment:
%   1. patch that has no saturated pixel
%   2. patch that has one saturated pixel for each pixel

%%
ieInit;
%%
l3d = l3DataISET();   

% Take the first scene out
l3d.set('scenes', {l3d.scenes{1}});
l3d.set('nscenes', 1);
% Set up parameters for boosting the training data. The variations in the
% scene illuminant level and SPD are established here.
l3d.illuminantLev = [100];
l3d.inIlluminantSPD = {'D65'};
l3d.outIlluminantSPD = {'D65'};

% Create camera and get autoexposure
camera = cameraCreate;
camera = cameraSet(camera,'sensor',sensorCreateQuad);

l3d.camera = camera;

%% Get the raw data
[rawTotal, tgtTotal, pTypeTotal] = l3d.dataGet();

%% Generate raw data and pixel type sets to exam classification
% raw data
rawNonSat = reshape(rawTotal{1}(1:5, 1:5), [numel(rawTotal{1}(1:5, 1:5)), 1]);
rawSingleSat = rawNonSat; rawSingleSat(1) = 0.99;
rawMulSat = rawNonSat;
rawMulSat(1) = 0.98; rawMulSat (9) = 0.99; rawMulSat(16) = 0.99;

rawSample = [rawNonSat rawSingleSat rawMulSat];

% pixel type
pTypeNonSat = reshape(pTypeTotal(1:5, 1:5), [numel(pTypeTotal(1:5, 1:5)), 1]);
pTypeSingleSat = pTypeNonSat;
pTypeMulSat = pTypeNonSat;

pTypeSample = [pTypeNonSat pTypeSingleSat pTypeMulSat];

% tgt
tgtNonSat = reshape(tgtTotal{1}(1:5, 1:5, :), [numel(tgtTotal{1}(1:5, 1:5)), 3]);
tgtSingleSat = tgtNonSat; tgtSingleSat(1,:) = 1;
tgtMulSat = tgtNonSat; 
tgtMulSat(1,:) = 1; tgtMulSat(9,:) = 1; tgtMulSat(16,:) = 1;

tgtSample = {tgtNonSat, tgtSingleSat, tgtMulSat};

%% Training

% Create training class instance.
l3t = l3TrainRidge();

% set training parameters for the lookup tables.
l3t.l3c.cutPoints = {logspace(-1.7, -0.12, 30), []};
l3t.l3c.patchSize = [5 5];

%% 
stat = l3t.l3c.statFunc(rawSample, pTypeSample, l3t.l3c.statFuncParam{:});

%% Set the thresh volt for saturated pixel
if isempty(l3t.l3c.satVolt)
    thresh = cameraGet(l3d.camera, 'sensor voltage swing') - 0.03;
    l3t.l3c.satVolt = thresh;
else
    thresh = l3t.l3c.satVolt;
end


%%
nc = length(unique(pTypeTotal)); % number of channels
satChannel = zeros(1, length(l3t.l3c.cutPoints));
satChannel(1) = power(2, nc) - 1;
obj.satChannels = satChannel;
n_lvls = nc * prod(cellfun(@(x) length(x), l3t.l3c.cutPoints) + 1 + satChannel);

p_sat = patchSaturation(rawSample, pTypeSample, thresh);

%%

labelCol = computeLabelsOuter(l3t.l3c, stat, pTypeSample, p_sat, satChannel);

%% Compare the target class and the calculated class
labelValue = unique(labelCol);

p_data = cell(n_lvls, 1);
p_out  = cell(n_lvls, 1);

for jj = 1 : length(labelValue)

    % Shorten the name
    lv = labelValue(jj);

    % Find the indices with that label value
    indx = (labelCol == lv);

    p_data{lv} = [p_data{lv} rawSample(:, indx)];

    p_out{lv} = [p_out{lv} tgtSample{indx}];

end