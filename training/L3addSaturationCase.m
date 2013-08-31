function L3 = L3addSaturationCase(L3, saturationcase)

% Adds a saturation case to the list of saturation cases to train on
%
% L3 = L3addSaturationCase(L3, saturationcase)
%
% saturationcase:   Binary vector with length equal to the number of color
%                   channels in the CFA.  The entry is 1 if the
%                   corresponding color channel is saturated.
%
% The passed in saturation case will be added as the last column of the
% saturation list stored in L3 structure.  All of the saturation cases in
% the L3 structure will be trained on.
%
% The saturation list starts as all 0's aka no saturation.  During training
% when pixels saturate, any new saturation case will be added to the
% list to later be trained.

if mean(saturationcase)<1   % ignore the case where all channels are saturated
    saturationlist = L3Get(L3, 'saturation list');
    saturationlist(:, end+1) = saturationcase;
    L3 = L3Set(L3, 'saturation list', saturationlist);
end