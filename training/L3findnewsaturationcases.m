function L3 = L3findnewsaturationcases(L3)
% Add any new saturation cases from data to list that need to be trained
%
% L3 = L3findnewsaturationcases(L3)
%
% During training, L3 structure keeps a list of what saturation cases need
% to be trained.  Originally this list only contains the case where no
% channels saturate.  While training each saturation case for each
% luminance value, if there is a new saturation case in the data, it is
% added to the list of saturation cases for training.


%% Load needed data
% List of saturation cases that have or will be trained
saturationlist = L3Get(L3,'saturation list');

% Each column gives the saturation case for the corresponding patch
[saturationcases, L3] = L3Get(L3,'sensor patch saturation');

%% Remove saturation cases that are contained in saturation list
for listindex = 1:size(saturationlist,2)
    % saturation case from list to look for
    desiredsaturationcase = saturationlist(:, listindex);    
    saturationindices = L3findsaturationindices(saturationcases, ...
                                        desiredsaturationcase);
    saturationcases(:, saturationindices) = [];  % delete matching entries
end

%% Add any saturation cases that remain to saturation list to train on
% Only add if there are more such patches than the following minimum
% threshold.  Otherwise, just delete them.
minthreshold = L3Get(L3,'n samples per patch');
while ~isempty(saturationcases)
    newsaturationcase = saturationcases(:, 1);
    saturationindices = L3findsaturationindices(saturationcases, ...
                                        newsaturationcase);
    if sum(saturationindices) > minthreshold
        L3 = L3addSaturationCase(L3, newsaturationcase);
    end                                    
    saturationcases(:, saturationindices) = [];  % delete matching entries        
end
