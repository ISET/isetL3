function L3 = L3Train_illum(L3)
% Train the L3 processing pipeline based on the calibrated and sensor
% design images
%
%    L3 = L3Train(L3)
%
% Take input patches from the sensor and the noise-free desired XYZ values
% as inputs.  Also, a description of the data (e.g., the cfaPattern, and so
% forth).
%
% * Segment the patches according to type.
% * Add noise to the input.
% * Solve for the kernel for each type of patch and each color pixel type
%   using the Wiener method.
%
% The training is automatically run over a series of patch luminance values.
% This is needed to process bright/dark images/regions of images. A patch's
% luminance is a scalar given by luminancefilter*patch that describes the
% overall brightness of the patch.  Filters for different patch luminance
% values are different due to differing SNR and possibly saturation.
%
% The training is automatically run for each patchtype.  In general, there
% are n*m patchtypes for an n x m CFA.  The patchtype string 'nm' describes
% the center of the patch as the (n,m) location in the CFA.
%
% (c) Stanford VISTA Team

%% Compute sensor volts for a monochrome sensor
[desiredIm, inputIm] = L3SensorImageNoNoise(L3);

%% Delete any offset
sensorM = L3Get(L3,'sensor monochrome');
ao = sensorGet(sensorM,'analogOffset');
ag = sensorGet(sensorM,'analogGain');
for ii = 1 : length(inputIm)
    inputIm{ii} = inputIm{ii} - ao/ag;
    % above is because    volts = (volts + ao)/ag (see sensorCompute)
end

%% Derive global correction matrix 
trM = L3ComputeClusterIndependentTrM(desiredIm);
L3.globaltrM = trM;

%% Load texture tree variables
numclusters    = L3Get(L3,'n clusters');
lumList    = L3Get(L3,'luminance list');

%% Main loop
cfaPattern = sensorGet(L3Get(L3,'sensor design'),'cfa pattern');
for rr=1:size(cfaPattern,1)
    for cc=1:size(cfaPattern,2)
        disp('**********Patch Type**********');
        disp([rr,cc]);
        
        L3 = L3Set(L3,'patch type',[rr,cc]);   % Refers to CFA pattern position

        % The blockpattern tells you what color is measured at each pixel
        % of the patch.
        
        % blockpattern = L3Get(L3,'block pattern');
        % vcNewGraphWin; imagesc(blockpattern); colormap(gray)

        % Add no saturation case to saturation list
        nfilters = L3Get(L3, 'n filters');
        saturationcase = zeros(nfilters, 1);
        L3 = L3addSaturationCase(L3, saturationcase);

        saturationtype = 0;
        L3 = L3Set(L3, 'saturation type', saturationtype); % next work on 1st saturation case
        
        
        while saturationtype < L3Get(L3, 'length saturation list')  % not done with all cases

            % move on to next saturation type
            saturationtype = 1 + L3Get(L3, 'saturation type');
            L3 = L3Set(L3, 'saturation type', saturationtype);
            
            saturationcase = L3Get(L3,'saturation list', saturationtype);
            disp('****Saturation Type****');
            disp(saturationcase);
            
            % Let's try to move this outside of the saturation loop.  That
            % way we only will have to load once per patch type.
            [sensorPatches, idealVec] = L3trainingPatches(L3, inputIm, desiredIm);

            % Store the answer.
            L3 = L3Set(L3,'sensor patches',sensorPatches);
            L3 = L3Set(L3,'ideal vector',idealVec);

            for ll=1:length(lumList)
                %Set current patch luminance index for training
                L3 = L3Set(L3,'luminance type',ll);
                disp(ll);

                % Scale the light so that each patch has desired luminance
                L3 = L3AdjustPatchLuminance(L3);
                
                % Check and add to list any new saturation cases from data
                L3 = L3findnewsaturationcases(L3);
                
                % Find saturation indices  (which patches match the desired
                % saturation case)
                [saturationindices, L3] = L3Get(L3,'saturation indices');
                % Saturation indices should have been found and stored in
                % L3 structure by L3findnewsaturationcases.  If so, they
                % are just retrieved from memory.
                
                % Skip current luminance type if there are at least a
                % minimal number of patches for current saturation case.
                nsaturationpatches = sum(saturationindices);
                if nsaturationpatches > L3Get(L3,'n samples per patch')
                    % Record how many patches will be used for training
                    % this case
                    L3 = L3Set(L3, 'n saturation patches', nsaturationpatches);
                    
                    %% Global pipeline
                    % First find the globalpipelinefilter.
                    %
                    % This is a linear filter computed with the Wiener estimation process.
                    % globalpipelinefilter is used to calculate the outputs in the case when we
                    % do not separate the inputs into different categories of patches (e.g.,
                    % flat/texture). This is an alternative to the L^3 algorithm, which
                    % includes segmentation of the patch types.

                    %Variable oversample controls how the noise optimization is built into the
                    %optimized filters
                    % oversample=0 means optimize for the variance of the expected measurement
                    %    noise and find Wiener filter
                    % oversample=n (positive integer) means for each noise-free patch, generate
                    %    n noisy copies of the patch and find pseudoinverse filter
                    %    (total number of noisy patches is trainpatches*oversample)
                    oversample = L3Get(L3,'n oversample');
                    % oversample is used to distinguish the noise-free (no extra samples) and
                    % noisy case (oversample extra samples).  When there are no extra samples,
                    % we are computing the noise-free case.  We use the value of oversample to
                    % create additional noise samples and compute in the noisy case.
                    if oversample == 0
                        % Wiener filter:  Don't add noise to patches. But when finding filter
                        % in L3findfillters use Wiener filter so filter is robust to noise.
                        noiseFlag = 2;
                    else
                        %Pseudoinverse filter:  Add noise to patches. Then when finding filter
                        %just use the pseudoinverse.  Resultant filter is best for that
                        %particular noisy sample.
                        noiseFlag = 0;

                        % Upsample number of patches
                        L3 = L3PatchesOversample(L3,oversample);
                    end
                    
                    L3 = L3Set(L3, 'contrast type', 1);
                    [globalpipelinefilter, globaltrM] = L3findfilters_illum(L3,noiseFlag);
                    L3 = L3Set(L3,'global filter',globalpipelinefilter);
                    L3 = L3Set_illum(L3,'global trm',globaltrM);

                    % Visualization
                    % L3showfilters('global',globalpipelinefilter,blockSize);
                    % meansfilter = L3Get(L3,'means filter');
                    % L3showfilters('means',meansfilter,blockSize);

                    %% Split patches into flat and texture
                    %Determine which patches are flat or textured based on the contrast
                    contrasts =  L3Get(L3,'sensor patch contrasts');
                    sortedcontrasts = sort(contrasts);

                    %If oversample~=0, the flatthreshold value found here was
                    %calculated assuming there is no noise.  It is used to ideally 
                    %classify the training patches into flat and texture.  Later 
                    %flaththreshold is calculated again to give apporixmately the same
                    %classification when there is noise.  The value needs to be
                    %increased in order to account for the increase in contrast that
                    %noise causes.
                    flatpercent = L3Get(L3,'flat percent');
                    if flatpercent == 0,         flatthreshold = -1;
                    elseif flatpercent == 1,     flatthreshold = inf;
                    else
                        flatthreshold = sortedcontrasts(round(length(contrasts)*flatpercent));
                    end
                    L3 = L3Set(L3,'flat threshold',flatthreshold);

                    % These indices identify which are the flat patches.
                    % flatindices=(flatthreshold>=contrasts);

                    % sum(flatindices)/length(flatindices)
                    % This should be flatpercent

                    %% Find filters for flat patches
                    [flatindices, L3] = L3Get(L3,'flat indices');
                    % This call stores flat indices in L3 structure so
                    % that it won't need to be computed again.              

                    %enforce symmetry for flat filters
                    symmetryflag = 1; 
                    L3 = L3Set(L3, 'contrast type', 2);
                    [flatfilters, flattrM] = L3findfilters_illum(L3,noiseFlag,flatindices,symmetryflag);

                    % This is set for a particular cfaPosition (could be the current default)
                    L3 = L3Set(L3,'flat filters',flatfilters);
                    L3 = L3Set_illum(L3,'flat trm',flattrM);

                    % Visualize
                    % L3showfilters('flat',flatfilters,blockSize,meansfilter,blockpattern);

                    %% Adjust thresholds for noise
                    % If thresholds were calculated on noise-free patches0 (oversample==0),
                    % they need to be increased to work when there is noise.  So we run the
                    % noise case to determine the threshold.
                    if oversample == 0
                        contrastsNoise = L3Get(L3,'sensor patch contrast noisy');
                        contrastsNoise = sort(contrastsNoise);

                        %Adjust contrast thresholds
                        if flatpercent==0,        noisyflatthreshold=-1;
                        elseif flatpercent==1,    noisyflatthreshold=inf;
                        else
                            noisyflatthreshold = ...
                                contrastsNoise(round(length(contrastsNoise)*flatpercent));
                        end

                    else
                        %oversample is positive indicating noisy samples were trained on
                        %and no adjustment needed
                        noisyflatthreshold = flatthreshold;
                    end

                    % This is the threshold we use in practice
                    L3 = L3Set(L3,'flat threshold',noisyflatthreshold);


                    %% Flip texture patches into canonical form
                    L3 = L3flippatches(L3);

                    %% Perform clustering on texture patches
                    L3 = L3findclusterstree(L3);

                    %% Create the texture filters
                    texturefilters = cell(1,numclusters);
                    texturetrM = cell(1,numclusters);

                    trainclustermembers = L3Get(L3,'cluster members');
                    % vcNewGraphWin; hist(trainclustermembers(:))

                    % texturefreqs   = zeros(1,numclusters);
                    %maxtreedepth determines the number of clusters of texture patches,
                    %maxtreedepth-1 branching operations are required to determine the cluster for a patch
                    %2^(maxtreedepth-1) is the number of clusters (leaves of the tree)
                    %maxtreedepth of 1 gives only one texture cluster
                    maxtreedepth = L3Get(L3,'max tree depth');

                    % Find the filter for each cluster
                    L3 = L3Set(L3, 'contrast type', 3);
                    for clusternum = 1:numclusters
                        clusterindices = ...
                            floor(trainclustermembers/2^(maxtreedepth-floor(log2(clusternum))-1))==clusternum;

                        % texturefreqs(clusternum)=sum(clusterindices)/nPatches;

                        %don't enforce symmetry for texture patches because they
                        %are oriented
                        symmetryflag=0; 
                        [texturefilters{clusternum}, texturetrM{clusternum}] = ...
                            L3findfilters_illum(L3,noiseFlag,clusterindices,symmetryflag);

                    end
                    L3 = L3Set(L3,'texture filters',texturefilters);
                    L3 = L3Set_illum(L3,'texture trm',texturetrM);

                else   % if not enough patches for luminance value
                    L3 = L3Set(L3,'empty filter',[]);  % place empty in filters structure
                    
                end % end if statement that skips luminance values with not enough patches
            end % end loop over luminance values            
        end   % end while statement for all saturation cases
        
        % delete saturation cases with no trained filters
        L3 = L3deletesaturationcases(L3);
        
    end  % end loop for patch type col
end  % end loop for patch type row

end