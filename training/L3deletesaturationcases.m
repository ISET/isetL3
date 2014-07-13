function L3 = L3deletesaturationcases(L3)
% Delete saturation type that has no filters trained. 
%
% During training, we put an empty matrix to fill out the space if there
% are not enough training patches for a specific cluster type. For some bad
% saturation type, none filters are trained for any of the luminace type.
% This causes bugs in the rendering process. This functions deletes those
% problematic saturation type. 
%
%
%
%
% (c) Stanford VISTA Team 2014

saturationlist = L3Get(L3, 'saturation list');
pt = L3Get(L3, 'patch type');

%% Find saturation cases with no trained filters
badsatindexes = zeros(1, size(saturationlist, 2));

for st = 1 : size(saturationlist, 2) %all sat case
   L3 = L3Set(L3,'saturation type', st);
   if sum(L3Get(L3,'luminance saturation case')) == 0
       % no filters stored for this saturation case, delete it
       badsatindexes(st) = 1;
   end   
end

if sum(badsatindexes) > 0 % if there is any bad saturation type
    
    badsatindexes = logical(badsatindexes); % convert to logical
    
    % delete bad saturation from saturation list
    saturationlist(:, badsatindexes) = [];
    L3 = L3Set(L3, 'saturation list', saturationlist);
    
    % delete space filling filters (empty filters) of bad saturation  
    filters = L3Get(L3, 'filters');
    ptfilters = permute(filters(pt(1), pt(2), :, :), [3, 4, 1, 2]);
    squeezedptfilters = cell(size(ptfilters));
    squeezedptfilters(:, 1:sum(~badsatindexes)) = ptfilters(:, ~badsatindexes);
    filters(pt(1), pt(2), :, :) = permute(squeezedptfilters, [3, 4, 1, 2]);
    L3 = L3Set(L3, 'filters', filters);
    
    % delete clusters components (flat/texture threshold etc.) of bad saturation 
    clusters = L3Get(L3, 'clusters');
    ptclusters = permute(clusters(pt(1), pt(2), :, :), [3, 4, 1, 2]);
    squeezedptclusters = cell(size(ptclusters));
    squeezedptclusters(:, 1:sum(~badsatindexes)) = ptclusters(:, ~badsatindexes);
    clusters(pt(1), pt(2), :, :) = permute(squeezedptclusters, [3, 4, 1, 2]);
    L3 = L3Set(L3, 'clusters', clusters); 
end