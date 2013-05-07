function filters = L3findfilters(L3,noiseFlag,patchindices,symmetryflag)
%L3FINDFILTERS calculates Wiener filters for patches in a particular cluster
%
% OLD: L3findfilters(patches,centeroutput,patchindices,flip,blockpattern,nummissingcolors,...
%     sensor,noiseflag,sigmafactor,means,contrasts,meansfilter)
%
%    [filters,trainsnrclusters]= L3findfilter(L3,noiseflag,patchindices)
%
%INPUTS:
%   patches:    
%   centeroutput:   matrix giving the values at the center pixel for all
%                   desired output bands
%                   (size(centeroutput)=nummissingcolors x numpatches)
%   patchindices:  vector of binaries describing which patches belong to
%                    the cluster
%   flip:       structure containing binaries that describe whether the
%               filters should be forced to have symmetry along a direction
%   blockpattern:   matrix containing index of color channel that is
%                   measured at each pixel in the patch    (can be 3-D 
%                   array if multiple measurements at each pixel)
%   nummissingcolors:  number of bands in desired output image
%   sensor:     structure containing sensor and pixel parameters for noise
%   noiseflag:  scalar indicating whether the filter should be optimized
%               assuming the incoming patch measurements will be further 
%               corrupted by noise that is not already in patches
%               (0 means fit assuming no noise will be added later,
%                otherwise fit assuming noise will be added later)
%   sigmafactor: scalar factor that describes the believed noise variance
%                when the actual noise variance corresponds to sigmafactor=1
%   means:      matrix giving the predicted mean in each measured band for
%               the center pixel in each patch
%   contrasts:     vector giving the sum of the deviation from the predicted
%               mean for each patch
%   meansfilter:  matrix that gives means (means=meansfilter*patches)
%
%OUTPUTS:
%   filters:     matrix giving Wiener filter, xhat=filters*[x,means]
%   trainsnrclusters:  scalar giving the SNR for the derived estimator
%                       (does not include any measurement noise)
%
% Copyright Steven Lansel, 2010



% This is very similar to L3findglobalpipelinefilter.m.  These two files
% should probably be merged.  (In the past this file was different because
% the flat and texture filters had a different format than the direct
% global pipeline filter.  But this has now changed so the filters are very
% similar.)

%% Check inputs
if ieNotDefined('L3'), error('Require L3'); end
if ieNotDefined('noiseFlag'), error('Noise flag required.'); end
if  nargin<3 | isempty(patchindices)
    % By default, use all patches
    npatches = L3Get(L3,'n sensor patches');
    patchindices = true(1, npatches);
end

if nargin<4 | isempty(symmetryflag)
    % By default, don't enforce symmetry
    symmetryflag = 0;
else
    %should check if symmetryflag is binary
end

%% Initialize parameters
blockpattern   = L3Get(L3,'block pattern');
sensor         = L3Get(L3,'sensor design');
sigmafactor    = L3Get(L3,'sigma factor');
nIdealFilters  = L3Get(L3,'n ideal filters');
centeroutput   = L3Get(L3,'ideal vector');
saturationpixels = L3Get(L3, 'saturation pixels');  % indicates which pixels should be ignored

%% Find Noise Variance
if noiseFlag == 0
    patches  = L3Get(L3,'sensor patches noisy');
    noisevar = 0;
else  % noiseFlag~=0
    % There is noise.  Find it.
    patches = L3Get(L3,'sensor patches');
    centroid=mean(patches(:,patchindices),2);    
    noisevar=L3findnoisevar(sensor,centroid);
    noisevar=sum(patchindices)*sigmafactor*noisevar;
end

%% Remove all pixels for saturated channels
if noiseFlag~=0
    noisevar(saturationpixels) = [];
end
patches(saturationpixels,:) = [];

%% Find Wiener filter
smallfilters = L3Wiener(patches(:,patchindices), centeroutput(:,patchindices), noisevar);

%% Put 0's in Filter for Pixels belong to Saturated Channels
filters = zeros(size(smallfilters,1), length(saturationpixels));
filters(:,~saturationpixels) = smallfilters;

%% Enforce Symmetry if desired
if symmetryflag
    flip = L3Get(L3,'flip');
    filters = L3enforcesymmetry(filters, nIdealFilters, blockpattern, flip);
end

return