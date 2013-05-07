function L3=L3clustertexturepatches(L3)

%clustermembers=L3clustertexturepatches(patches,textureindices,pcas,thresholds)
% 
%L3CLUSTERTEXTUREPATCHES determines cluster for each texture patch
%
%clustermembers=L3clustertexturepatches(patches,textureindices,pcas,thresholds)
%
%INPUTS:
%   patches:    matrix with columns giving patches to process
%               (size(patches)=patchsize x numpatches)
%   textureindices:  vector giving indices of texture patches to cluster
%                   (variable length vector)
%   pcas:       matrix with columns giving the PCA directions for each
%               binary decision, these only exist for non-leaf nodes
%   thresholds: vector giving the threshold value for which branch to go
%               down, these only exist for non-leaf nodes
%               size(thresholds)=1 x (2^(treedepth-1)-1)
%OUTPUTS:
%   clustermembers:  vector giving the cluster index that each patch is in
%                    (size(clustermembers)=1 x numclusters)
%
% Copyright Steven Lansel, 2010

patches    = L3Get(L3,'spatches');
clustermembers = double(L3Get(L3,'texture indices'));
pcas = L3Get(L3,'cluster directions');
thresholds = L3Get(L3,'cluster thresholds');

for nodenum=1:size(pcas,2)
    oldclusterindices=find(clustermembers==nodenum);

    %Projection is not used currently.  The idea is that clustering might be
    %improved by first normalizing each patch to have a unit energy.  It might
    %be a good idea for certain applications, but in general testing it had
    %little effect.
    % projection = L3Get(L3,'projection');  %binary about whether to project

%     if projection
%         belowthreshold=(pcas(:,nodenum)'*patches(1:numPatchMeasurements,oldclusterindices)<thresholds(nodenum)*scales(oldclusterindices));
%     else
    belowthreshold=(pcas(:,nodenum)'*patches(:,oldclusterindices)<thresholds(nodenum));
%     end
        
    %patches below/above the threshold are assigned to the new cluster with the
    %smaller/larger index
    clustermembers(oldclusterindices(belowthreshold))=2*nodenum;    
    clustermembers(clustermembers==nodenum)=2*nodenum+1;
end

L3 = L3Set(L3,'cluster members',clustermembers);