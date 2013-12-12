function L3=L3clustertexturepatches(L3, varargin)

%L3CLUSTERTEXTUREPATCHES determines cluster for each texture patch
%
%  L3=L3clustertexturepatches(L3)
%
% Copyright Steven Lansel, 2013

patches    = L3Get(L3,'spatches');
textureindices = L3Get(L3,'texture indices');
% Transition
low = L3Get(L3, 'transition contrast low');
high = L3Get(L3, 'transition contrast high');
if ~isempty(low) & ~isempty(high) & (low ~= high) 
    transitionindices = L3Get(L3,'transition indices');
    textureindices = textureindices | transitionindices;
end
clustermembers = double(textureindices);
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