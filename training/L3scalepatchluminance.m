function [patch,centeroutput]=L3scalepatchluminance(patch,centeroutput,...
                                desiredluminance,luminancefilter,saturate)

%L3SCALEPATCHLUMINANCE adjusts patch to have desired luminance and saturation
%
%[patch,centeroutput]=L3scalepatchluminance(patch,centeroutput,...
%                                desiredluminance,luminancefilter,saturate)
%INPUTS:
%   patch:          vector giving the measurements for a single patch
%   centeroutput:   vector giving the values at the center pixel for all
%                   desired output bands
%   desiredluminance: scalar giving the desired luminance value of the
%                     output scaled patch
%   luminancefilter:  vector same length as patch that gives the patch's
%                     luminance by luminancefilter*patch
%   saturate:         saturation threshold for each measurement in a patch
%
%OUTPUTS:
%   patch:          scaled version of the input patch that has the desired
%                   luminance and does not have any values greater than
%                   the saturation threshold
%   centeroutput:   scaled version of centeroutput that is scaled by the
%                   same amount as the patch, but the centeroutput does not
%                   saturate
%
%  Effectively the illuminant is being scaled while the reflectances in
%  each patch remains the same.  The scaling is so that each patch has the
%  desired luminance.  For darker objects in the scene, the light must be
%  increased more than for brighter objects.  But for every patch in the
%  scene, there is always some amount of light that can result in the 
%  desired patch lumiannce.
%
% Copyright Steven Lansel, 2010


%General approach is to repeatedly find the scalar multiple needed to 
%multiply the unsaturated measurements in the patch to achieve the desired
%patch luminance.  Scale the patch and the centeroutput accordingly.  If
%no measurements in the patch saturate because of this, we are done.  But
%if something saturates because of the scaling, we have to threshold the
%measurements and try scaling again.


done=0;
saturated=false(size(patch));
while ~done
    luminancenonsaturated=luminancefilter(~saturated)*patch(~saturated);
    if luminancenonsaturated~=0
        luminancesaturated=luminancefilter(saturated)*patch(saturated);

        %Following is amount we need to scale the illuminant to get desired 
        %luminance.  Keep in mind that scaling the luminance does not change
        %the luminance component from the already saturated measurements.
        scale=(desiredluminance-luminancesaturated)/luminancenonsaturated;

        patch(~saturated)=scale*patch(~saturated);
        centeroutput=scale*centeroutput;
        newsaturated=(~saturated & (patch>saturate));   %measurements that just now becamse saturated
        if any(newsaturated)
            patch(newsaturated)=saturate;   %saturate each measurement above the threshold
            saturated=(saturated | newsaturated);   %update current list of saturated measurements
        else
            done=1;
        end
    else
        done = 1;
    end
end