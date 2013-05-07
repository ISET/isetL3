function L3 = L3AdjustPatchLuminance(L3)

% This function was written before we deal with saturation cases
% separately.  Because all saturation possibilities were considered, this
% function needed to be much more complex to get the desired patch
% luminance.  It has now been replaced with a function that only considers
% the desired saturation case.



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
% General approach is to repeatedly find the scalar multiple needed to 
% multiply the unsaturated measurements in the patch to achieve the desired
% patch luminance.  Scale the patch and the centeroutput accordingly.  If
% no measurements in the patch saturate because of this, we are done.  But
% if something saturates because of the scaling, we have to threshold the
% measurements and try scaling again.




%% Load data we will need
desiredluminance = L3Get(L3,'desiredpatchluminance');
npixelsperpatch = L3Get(L3,'n pixels per patch');
nidealfilters = L3Get(L3,'n ideal filters');
patches = L3Get(L3,'sensor patches');
idealVec = L3Get(L3,'ideal vector');
luminancefilter = L3Get(L3,'luminance filter');        

sensorM = L3Get(L3,'sensorm');
pixel = sensorGet(sensorM,'pixel');
voltageSwing = pixelGet(pixel,'voltage swing');

%% Perform scaling
saturated=false(size(patches));
finishedpatches=false(1,size(patches,2));

while ~all(finishedpatches)
    
    weightedpatches = diag(luminancefilter) * patches(:,~finishedpatches);
    luminancenonsaturated = sum(weightedpatches .* ~saturated(:,~finishedpatches));
    luminancesaturated = sum(weightedpatches .* saturated(:,~finishedpatches));
    
    %Following is amount we need to scale the illuminant to get desired 
    %luminance.  Keep in mind that scaling the luminance does not change
    %the luminance component from the already saturated measurements.    
    scale = (desiredluminance-luminancesaturated) ./ luminancenonsaturated;

    %For convenience, both saturated and nonsaturated pixels are scaled.
    %Scaling saturated pixels doesn't make sense but it is ok because all
    %saturated pixels are later clipped.
    patches(:,~finishedpatches) = repmat(scale,npixelsperpatch,1)...
                                .* patches(:,~finishedpatches);
    
    idealVec(:,~finishedpatches) = repmat(scale,nidealfilters,1)...
                                .* idealVec(:,~finishedpatches);
        
    nowsaturated=(patches >= voltageSwing-.001);
    patches(nowsaturated) = voltageSwing;
    
    finishedpatches = (sum(saturated) == sum(nowsaturated));
    saturated = nowsaturated;
end


%% Store scaled patches and ideal vector
L3 = L3Set(L3,'sensor patches',patches);
L3 = L3Set(L3,'ideal vector',idealVec);