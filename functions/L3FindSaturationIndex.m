function saturationindex = L3FindSaturationIndex(L3)

% Find saturation case for each training patch
%
% saturationindex = L3FindSaturationIndex(L3)
%
% From the list of trained saturation cases, pick one for each patch.  In
% the rare case where a patch's saturation case was not trained on, pick
% the best one we can.
%
% saturationindex:  Vector containing index to matched saturation case in
%                   the list of saturation cases stored in L3
%
% This is generally called by L3applyPipeline2Patches.m

%% Load Data
saturationlist = L3Get(L3,'saturation list');
saturationcases = L3Get(L3,'sensor patch saturation');
nsensorpatches = L3Get(L3,'n sensor patches');

%% Deal with all patches that have a trained saturation case
saturationindex = zeros(1, nsensorpatches);
for listindex = 1:size(saturationlist,2)
    % saturation case from list to look for
    desiredsaturationcase = saturationlist(:, listindex);   
    
    matchedindices = L3findsaturationindices(saturationcases, ...
                                        desiredsaturationcase);
    saturationindex(matchedindices) = listindex;
end

%% Deal with any patches with no trained saturation case
unfinished = (saturationindex==0);  % which patches do not have a match

if any(unfinished)    
    means = L3Get(L3,'sensor patch means');
end
while any(unfinished)
    % for each unfinished patch, pretend the saturated channel with the
    % lowest mean is not saturated

    unfinishedindex = find(unfinished);  % convert from logical to direct indexing    
    for channel = 1:size(saturationcases,1)
        % if the channel is not saturated, make its mean inf so it cannot
        % be chosen to be changed to not saturated
        unsaturated = saturationcases(channel,unfinished)==0;

        means(channel,unfinishedindex(unsaturated)) = inf;
    end
      
    [~,dropchannel] = min(means(:,unfinished));  
    for channel = unique(dropchannel)
        saturationcases(channel,unfinishedindex(dropchannel==channel)) = 0;
    end
    
    % check if patches now have a match
    for listindex = 1:size(saturationlist,2)
        % saturation case from list to look for
        desiredsaturationcase = saturationlist(:, listindex);   

        matchedindices = L3findsaturationindices(...
                    saturationcases(:,unfinished), desiredsaturationcase);
        saturationindex(unfinishedindex(matchedindices)) = listindex;
    end

    unfinished = (saturationindex==0);  % which patches do not have a match
end
