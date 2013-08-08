function [meanDeltaE, errorImage] = L3scielabfind(im1,im2,colorspace,whitePointXYZ)

%L3SCIELABFIND calculates the mean S-CIELAB difference between two images
%
% [meanDeltaE, errorImage] = L3scielabfind(im1,im2,colorspace,[whitePointXYZ])
%
%INPUTS:
%   im1, im2:       3-D array containing the RGB or XYZ images to compare
%                   size(im#)=rows x cols x 3   
%   colorspace:     string telling what the image planes are, options:
%                   'RGB'   linear RGB (presumably output from a display)
%                   'XYZ'   XYZ colormatching functions
%   whitePointXYZ:  white point value in XYZ (only used for XYZ images)
%
%OUTPUTS:
%   scielabscore:   scalar giving mean S-CIELAB difference between images
%
%Note this script assumes certain important values such as horizontal field
%of view (relatd to viewing distance).
%
% Example:
%   load hats; 
%   im1 = hats; 
%   im2 = hats + randn(size(hats))*0.03; im2 = ieClip(im2,0,1);
%   colorspace = 'rgb';
%   [meanDeltaE, errImg] = findscielab(im1,im2,colorspace);
%   figure; hist(errImg(:),50)
%   figure; subplot(1,2,1), image(im1); subplot(1,2,2), image(im2);
%   truesize
%
%
% Copyright Steven Lansel, 2010


if strcmpi(colorspace,'RGB')
    % Make this test for RGB, but skip it for XYZ
    if max(im1(:))>1+eps || max(im2(:))>1+eps || min(im1(:))<0 || min(im2(:))<0
        error('Intensity range should be between 0 and 1')
    end
end


%% Set parameters
% sampPerDeg = 23;  %old parameter

horizontalAngle = 20;  % degrees
sz = size(im1);
sampPerDeg = round(sz(2)/horizontalAngle);

% Run CIELAB 2000
params.deltaEversion = '2000';
params.sampPerDeg = sampPerDeg;
params.filterSize = sampPerDeg;
params.filters = [];
% params.filterversion = 'original';
params.filterversion = 'distribution';

wave = 400:700;

%% Calculate for RGB images
if strcmpi(colorspace,'RGB')
    
    % We assume the RGB image is on an old fashioned CRT whose phosphors
    % are sRGB and whose gamma function is in the displayGamma file.
    displaySPD = vcReadSpectra('crtSPD',wave);
    cones =  vcReadSpectra('SmithPokornyCones',wave);
    rgb2lms = cones'* displaySPD;   %conversion matrix from 
    load('displayGamma','gamma');
    % figure; plot(wave,displaySPD)
    % plot(gamma)
    rgbWhite = [1 1 1];
    whitePointLMS = rgbWhite * rgb2lms';  % Row vector of LMS values

    im1RGB = dac2rgb(im1,gamma);
    im1LMS = changeColorSpace(im1RGB,rgb2lms);

    im2RGB = dac2rgb(im2,gamma);
    im2LMS = changeColorSpace(im2RGB,rgb2lms);

    params.imageFormat = 'lms';

%   errorImage = scielab(sampPerDeg, im1LMS, im2LMS, whitepoint, imageformat);   %old version
    errorImage = scielab(im1LMS, im2LMS, whitePointLMS, params);

%% Calculate for XYZ images    
elseif strcmp(colorspace,'XYZ')
    params.imageFormat = 'xyz';
    errorImage = scielab(im1, im2, whitePointXYZ, params);
end

%% Average error image to get score
meanDeltaE = mean(errorImage(:));
% figure; hist(errorImage(:),30)

return