function luminanceindex = L3FindLuminanceIndex(L3)

% Find closest luminance value for each training patch
%
% luminanceindex = L3FindLuminanceIndex(L3)
%
% For the current patcht type and saturation case, for each patch find the
% luminance value that is closest to each patch's luminance.  Valid
% luminance values are only ones that were previously trained and have
% learned filters stored in the L3 structure.
%
% luminancenindex:  Vector containing index to matched luminance value in
%                   the luminance list stored in L3
%
% This is generally called by L3applyPipeline2Patches.m


%% Load Data
luminanceSampleIndices = L3Get(L3,'luminance saturation case');
luminancelist = L3Get(L3,'luminance list');
patchLuminanceSamples = luminancelist(luminanceSampleIndices);

% The variable allPatches  is all of the allPatches for a patch type.  In
% the below loop, the sensor patches stored in the L3 structure are  just
% the those for a particular patch luminance.  Here we figure out for each
% training patch which of the training luminance values is closest. here.

patchluminances = L3Get(L3, 'sensor patch luminance');
differences = repmat(patchluminances',1,length(patchLuminanceSamples)) - ...
    repmat(patchLuminanceSamples,length(patchluminances),1);
[~,luminanceindex] = min(abs(differences'),[],1);

% luminanceindex refers to the entry from the luminance samples with
% filters.  The following line gets the entry out of all luminance
% samples (including ones that have no filters).
luminanceSamples = find(luminanceSampleIndices);
luminanceindex = luminanceSamples(luminanceindex);