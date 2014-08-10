function L3 = L3AdjustPatchLuminance(L3)

% Scale the light so that each patch has desired luminance.
%
%   L3 = L3AdjustPatchLuminance(L3)
%
% The current patch luminance is calculated for each patch.  This is
% normalized away and the desired patch luminance value is multiplied in.
% This is performed for both the sensor patches and ideal vector.  The
% result is what would have happened if the illumination or camera gain for
% the original scene was scaled so that each patch would have the desired
% luminance.
%
% Effectively the illuminant is being scaled while the reflectances in
% each patch remains the same.  The scaling is so that each patch has the
% desired luminance.  For darker objects in the scene, the light must be
% increased more than for brighter objects.  But for every patch in the
% scene, there is always some amount of light that can result in the 
% desired patch lumiannce.
%
% We want to only consider patches that match the desired saturation case.
% If a pixel saturates that corresponds to a non-saturated color (as
% determined by the saturation case), this patch can be deleted since it
% can never be useful for larger patch luminance values (which are trained
% later in L3Train).  Right now these patches are not deleted because it
% seems like we are less likely to make an error if we carry the data
% around.



%% Load data we will need
L3 = L3ClearIndicesData(L3);  % delete any old flat and saturation indices
desiredluminance = L3Get(L3,'desiredpatchluminance');
npixelsperpatch = L3Get(L3,'n pixels per patch');
nidealfilters = L3Get(L3,'n ideal filters');
patches = L3Get(L3,'sensor patches no 0');
idealVec = L3Get(L3,'ideal vector');
lt = L3Get(L3, 'luminance type');
lumList = L3Get(L3, 'luminance list');

%% Find the range around the current training luminance level.
% Training patches will be randomly scaled into this range. 
if lt == 1 % low end special case
    maxLum = (desiredluminance + lumList(lt + 1)) / 2;    
    minLum = 2 * desiredluminance - maxLum;
    if minLum < 0
        minLum = desiredluminance / 10;
    end
elseif lt == length(lumList) % high end special case
    minLum = (lumList(lt - 1) + desiredluminance) / 2;
    maxLum = 2 * desiredluminance - minLum;
            
    voltagemax = L3Get(L3,'voltage max');
    
    if maxLum > voltagemax
        maxLum = voltagemax;
    end
else
    minLum = (lumList(lt - 1) + desiredluminance) / 2;
    maxLum = (desiredluminance + lumList(lt + 1)) / 2;
end

desiredluminancevector = rand(1, size(patches, 2)) * (maxLum - minLum) + minLum;

%% Perform scaling
luminance = L3Get(L3, 'sensor patch luminance');

%Following is amount we need to scale the illuminant to get desired 
%luminance.
scale = desiredluminancevector ./ luminance;

patches = repmat(scale,npixelsperpatch,1) .* patches;
idealVec = repmat(scale,nidealfilters,1) .* idealVec;


%% Store scaled patches and ideal vector
L3 = L3Set(L3,'sensor patches',patches);
L3 = L3Set(L3,'ideal vector',idealVec);

