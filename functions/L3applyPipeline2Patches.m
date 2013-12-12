function [xhatL3, luminanceindex, saturationindex, clustermembers] = ...
            L3applyPipeline2Patches(L3,allpatches,L3Type)
%Perform the L^3 processing pipeline for the allPatches at single cfaPosition
%
%    [xhatL3, luminanceindex,saturationindex] = ...
%           L3applyPipeline2Patches(L3,allpatches,L3Type)
%
% INPUTS
%  L3:          structure is computed in s_L3TrainCamera.m, for an example
%  allpatches:  A matrix of CFA measurements from the image.  The patches
%               are stacked into blockSize^2 rows into a matrix
%  L3Type:      string that selects L3mode:
%                   'global'   no flat/texture classification
%                   'local'    flat/texture classification 
%
% OUTPUTS
%   xhatL3:          matrix of the L^3 estimates
%   luminanceindex:  Which luminance from list was used for each patch.
%   saturationindex: Which saturation case from list used for each patch
%   clustermembers:  Vector with an entry for each patch, entry is 0 if
%                    flat, positive number for texture where number is the
%                    specific texture cluster  (all 0 for global type)
%
% Copyright Steven Lansel, 2013


%% Find saturation cases
L3 = L3Set(L3,'sensor patches', allpatches);
saturationindex = L3FindSaturationIndex(L3);
neededsaturations = unique(saturationindex(:));

numpatches = size(allpatches,2);
luminanceindex = zeros(1, numpatches);
nideal = L3Get(L3,'nideal filters');
xhatL3 = zeros(nideal, numpatches);
xhatL3flat = zeros(nideal, numpatches);
xhatL3texture = zeros(nideal, numpatches);
clustermembers = zeros(1, numpatches);
for st = neededsaturations'    
    L3 = L3Set(L3,'sensor patches', allpatches);
    L3 = L3Set(L3,'Saturation Type',st);
    
    saturationindices = (saturationindex == st);
    L3 = L3Set(L3,'saturation indices', saturationindices);
    % store which patches should be processed with current saturation case
    
    %% Find closest luminance for each patch from the list of trained values
    luminanceindex(saturationindices) = L3FindLuminanceIndex(L3);
    % Below is all luminance indexes in luminance list that have patches
    usedluminanceindex = unique(luminanceindex(saturationindices));  
    
    %% Apply pipeline to each set of allPatches with the same patch luminance    
    for ll = usedluminanceindex
        % indexes into allpatches for the patches that match the current
        % saturation type and luminance level   (logical indexing is
        % probably better)
        currentpatches = find(saturationindices & (luminanceindex == ll));
        
        % Only put current patches into L3 structure.  Then we need to
        % update saturation indices in L3 structure because all patches in
        % the structure match the current saturation case.
        L3 = L3Set(L3,'sensor patches', allpatches(:,currentpatches));
        L3 = L3Set(L3,'saturation indices', true(1,length(currentpatches)));

        %Set current patch luminance index
        L3 = L3Set(L3,'luminance type',ll);

        switch L3Type
            case 'global'
                %% Global Linear Pipeline
                %maybe this can be done wih a single L3Get(L3,'xhatGlobal')
                globalpipelinefilter = L3Get(L3,'global filter');
                xhatL3(:,currentpatches) = globalpipelinefilter * allpatches(:,currentpatches);

            case 'local'
                %% L^3 Pipeline - more complex.

                %Apply flat filters
                flatfilters = L3Get(L3,'flat filters');
                [flatindices, L3] = L3Get(L3,'flat indices');
                % Transition
                low = L3Get(L3, 'transition contrast low');
                high = L3Get(L3, 'transition contrast high');
                if ~isempty(low) & ~isempty(high) & (low ~= high) 
                    [transitionindices, L3] = L3Get(L3,'transition indices');
                    flatindices = flatindices | transitionindices;
                end
                
                xhatL3flat(:,currentpatches(flatindices)) = flatfilters * allpatches(:,currentpatches(flatindices));
                
                %Flip texure patches into canonical form
                L3 = L3flippatches(L3);
                patches = L3Get(L3, 'sensor patches');
                
                %Perform texture clustering
                L3 = L3clustertexturepatches(L3);  
                
                %Apply texture filters
                texturefilters = L3Get(L3,'texture filters');
                currentclustermembers = L3Get(L3,'cluster members');                
                clustermembers(currentpatches) = currentclustermembers;
                treedepth      = L3Get(L3,'tree depth');
                numclusters    = L3Get(L3,'nclusters');
                % Following says to just use leaves of cluster tree
                clusterrange   = ceil(numclusters/2):numclusters;
                for clusternum = clusterrange
                    %clusterindices is vector of length equal to the number
                    %of curernt patches, each entry is 1 for each patch in
                    %the current cluster and 0 otherwise
                    clusterindices = ...
                        floor(currentclustermembers/2^(treedepth-floor(log2(clusternum))-1))==clusternum;

                    xhatL3texture(:,currentpatches(clusterindices)) = ...
                    texturefilters{clusternum} * patches(:,clusterindices);                                
                end              
                
                % Perform linear combination in flat and texture transition
%                 % regions
                flatindices = L3Get(L3,'flat indices');
                xhatL3(:,currentpatches(flatindices)) = xhatL3flat(:,currentpatches(flatindices));
                textureindices = L3Get(L3,'texture indices');
                xhatL3(:,currentpatches(textureindices)) = xhatL3texture(:,currentpatches(textureindices));
                
                if ~isempty(low) & ~isempty(high) & (low ~= high) 
                    weightsflat = L3Get(L3,'transition weights flat');
                    xhatL3(:,currentpatches(transitionindices)) = ...
                        xhatL3flat(:,currentpatches(transitionindices)) .* weightsflat + ...
                        xhatL3texture(:,currentpatches(transitionindices)) .* (1 - weightsflat);   
                end
        end
    end
end

return
