function [filters, trM] = L3findfilters_illum(L3,noiseFlag,patchindices,symmetryflag)
%L3FINDFILTERS calculates Wiener filters for patches in a specific cluster
%
%    filters= L3findfilter(L3,noiseflag,patchindices,symmetryflag)
%
% INPUTS:
%   L3:         L3 structure
%   noiseflag:  scalar indicating whether the filter should be optimized
%               assuming the incoming patch measurements will be further 
%               corrupted by noise that is not already in patches
%               (0 means fit assuming no noise will be added later,
%                otherwise fit assuming noise will be added later)
%   patchindices:  vector of binaries describing which patches belong to
%                    the cluster
%   symmetryflag: 0 or 1 saying whether to make filter be symmetric over
%                 certain directions
%
% OUTPUTS:
%   filters:     matrix giving Wiener filter, estimate = filters * patches
%
% (c) Stanford VISTA Team 2013

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
nIdealFilters  = L3Get(L3,'n ideal filters');
centeroutput   = L3Get(L3,'ideal vector');

% following pixels should be ignored
saturationpixels = L3Get(L3, 'saturation pixels');  
Xpixels = L3Get(L3, 'X pixels');
ignorepixels = saturationpixels | Xpixels;

weightColorTransform = L3Get(L3, 'weight color transform');
weightbiasvariance = L3Get(L3, 'weight bias variance');

%% Find Noise Variance
if noiseFlag == 0
    patches  = L3Get(L3,'sensor patches noisy');
    noisevar = 0;
else  % noiseFlag~=0
    % There is noise.  Find it.
    patches = L3Get(L3,'sensor patches');
    centroid=mean(patches(:,patchindices),2);    
    noisevar=L3findnoisevar(sensor,centroid);
    noisevar=sum(patchindices)*noisevar;
end

%% Remove all pixels for saturated or X channels
if noiseFlag~=0
    noisevar(ignorepixels) = [];
end
patches(ignorepixels,:) = [];

%% Find Wiener filter
if length(weightbiasvariance)>1 && any(abs(diff(weightbiasvariance))~=0)
    % If channels are weighted differently, do color transform
   centeroutput = weightColorTransform * centeroutput; 

   smallfilters = zeros(nIdealFilters, size(patches, 1));
   for channel = 1:nIdealFilters
       smallfilters(channel, :) = L3Wiener(patches(:,patchindices), ...
           centeroutput(channel, patchindices), noisevar * weightbiasvariance(channel));
       % If more than 1 channel has same weight, this could be performed
       % slightly more efficient by combining those cases.  We don't now
       % for ease of coding.
   end   
   % transform filters back to XYZ space
   smallfilters = inv(weightColorTransform) * smallfilters;
else
    % If channels are weighted same, no need to do color transform
    smallfilters = L3Wiener(patches(:,patchindices), ...
        centeroutput(:, patchindices), noisevar * weightbiasvariance(1));    
end

%% Put 0's in Filter for Pixels belong to Saturated or X Channels
filters = zeros(size(smallfilters,1), length(ignorepixels));
filters(:,~ignorepixels) = smallfilters;

%% Enforce Symmetry if desired
if symmetryflag
    flip = L3Get(L3,'flip');
    filters = L3enforcesymmetry(filters, nIdealFilters, blockpattern, flip);
end

nScenes = length(L3.scene);
renderXYZ = centeroutput(1 : 3, 1 : nScenes);
D65XYZ = centeroutput(4 : 6, 1 : nScenes);
trM = D65XYZ / renderXYZ; % least square solution
return
