function noisevar = L3findnoisevar(sensor,centroid)
%Approximates variance of noise from a set of patches
%
%   noisevar=L3findnoisevar(sensor,centroid)
%
% The noise is estimated from sensor properties.  The centroid gives us an
% estimate of the mean value in the set, which informs us about Poisson
% noise.
%
% INPUTS
%   sensor:     ISET sensor structure giving noise parameters
%   centroid:   average RAW value for each patch in the set
%
% OUTPUT
%   noisevar:   vector variance of noise added to each input variable, 
%               assuming independent noise for each input variable
%
% The noise actually is signal dependent, but the Wiener filter requires
% the noise to be signal independent.  For this reason, we find the
% variance of the noise that is expected for the centroid instead of for
% each patch in the set.
%
% This simplifying assumption means that we are ignoring the variation in
% the noise across the different patches in the set.  But we are still
% accounting for the signal dependent nature of the noise from one pixel to
% the next by calculating the variance using the signal dependent noise
% model for the centroid.
%
% The clusters of patches are designed so that there is a relatively small
% variation in intensity from patch to patch so this assumption is
% reasonable.  For certain CFAs there is a large variation from pixel to
% pixel (such as RGB vs W), which we are accounting for with this approach.
%
% Copyright Stanford VISTA Team 2012


pixel=sensorGet(sensor,'pixel');

darkvoltage  = pixelGet(pixel,'darkvoltage');  % units are volts/sec
exposuretime = sensorGet(sensor,'exposuretime');  % units are sec
conversiongain = pixelGet(pixel,'conversiongain');    % units are volts/electron
readnoise = pixelGet(pixel,'readNoiseVolts');  % units are volts
prnu = sensorGet(sensor,'prnusigma'); % units are percent
dsnu = sensorGet(sensor,'dsnusigma'); % units are volts

%Following parameters are from page 24 (below Eq 3.1) in L3thesis
c=darkvoltage*exposuretime;
k1=sqrt(conversiongain);   %needed for shot noise
k0=readnoise;  
k2=prnu/100;
k3=dsnu;

xsquared=centroid.^2;   %this is a bad approximation but should be close enough

%Following is Equation 3.3 from L3thesis
term1=(c^2+k1^2*(centroid+c)+k0^2) * (k2^2+1);
term2=k2^2 * xsquared;
term3=k3^2;
term4=2*c*centroid * k2^2;  %really is negligible
noisevar=term1+term2+term3+term4;


return
