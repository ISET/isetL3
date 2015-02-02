function [val, L3] = L3Get(L3,param,varargin)
%Get function for L3 structure (linear, local, learned)
%
%   [val, L3] = L3Get(L3,param,varargin)
%
% The L3 structure contains data and parameters for training and applying
% the linear, local, learned algorithm to image data.
%
% Parameters can be specified with spaces and arbitrary case.  For example,
%
%   L3Get(L3,'n scenes') or L3Get(L3,'N scenes') or L3Get(L3,'nscenes')
%
% will all return the number of training scenes.
%
% It is also possible to retrieve parameters from the oi and sensor objects
% attached to the L3 structure using the syntax
%
%   L3Get(L3,'sensor exptime','ms'), or
%   L3Get(L3,'oi optics fnumber')
%
% Note:
% The L3 structure is returned in case the flat or saturation indices are
% changed by L3Get.  These indices are stored in a temporary location and
% recalculated whenever they are not present.  The reason is to eliminate
% duplicate computations in future.
% 
% This happens for following variables:  sensor patch saturation
%                                        flat indices
%                                        saturation indices
%
% Parameters (to expand and explain)
%    name
%    type
%    patch type
%    lum type
%
%    rendering illuminant
%
% (c) Stanford VISTA Team, 2014

% Should we check for L3, too?
if ~exist('param','var') || isempty(param), error('param must be defined.'); end

% Default is empty when the parameter is not yet defined.
val = [];


%% Set up for ieParameterOtype
%
[oType,p] = ieParameterOtype(param);

% Example calls
%  v = L3Get(L3,'sensor pixel height','um');
%  v = L3Get(L3,'sensor exptime','ms');
%  v = L3Get(L3,'oi optics/fnumber');
if isequal(oType,'sensor')
    if isempty(p), val = L3.sensor.design; return;
    else
        if isempty(varargin), val = sensorGet(L3.sensor.design,p);
        elseif length(varargin) == 1
            val = sensorGet(L3.sensor.design,p,varargin{1});
        elseif length(varargin) == 2
            val = sensorGet(L3.sensor.design,p,varargin{1},varargin{2});
        end
        return;
    end
elseif isequal(oType,'oi')
    if isempty(p), val = L3.oi; return;
    else
        if isempty(varargin), val = oiGet(L3.oi,p);
        elseif length(varargin) == 1
            val = oiGet(L3.oi,p,varargin{1});
        elseif length(varargin) == 2
            val = oiGet(L3.oi,p,varargin{1},varargin{2});
        end
        return;
    end
elseif isequal(oType,'scene')
    % carry on
elseif isempty(p)
    error('oType %s. Empty param.\n',oType);
end

%% Special handling of key L3 parameters to simplify code below

% The following are needed to access properties of filters, cluster, or
% saturation list.  Rather than pull them out separately below and repeat
% this checking, we get them all at once here.
if isfield(L3,'patchType'), pt = L3.patchType; end
if isfield(L3,'lumType'), lt = L3.lumType; end  % integer pointer for lum level
if isfield(L3,'saturationType'), st = L3.saturationType; end  % saturation type
if isfield(L3,'contrastType'), ct = L3.contrastType; end  % contrast type

%% Forces lower case and removes spaces
param = ieParamFormat(param);

%%
switch(param)
    % Book-keeping
    case {'name'}
        val = L3.name;
    case {'type'}
        val = L3.type;
    case {'patchtype'}
        % Which color pixel type within the array
        % [row,col]
        val = L3.patchType;
    case {'lumtype','luminancetype'}
        % Which luminance level for the local patch
        val = L3.lumType;
    case {'sattype','saturationtype'}
        % Which saturation case for the local patch
        val = L3.saturationType;
        
        % ISET structures used to create data set
    case{'scenes','scene'}
        % L3Get(L3,'scene')
        % L3Get(L3,'scene',2);
        % A cell array of scenes
        val = L3.scene;
        % Or a single scene
        if ~isempty(varargin), ii = varargin{1}; val = val{ii}; end
    case {'nscenes','nscene'}
        % L3Get(L3,'n scenes')
        val = L3Get(L3,'scene');
        val = length(val);
    case{'trainingilluminant'};  %Illuminant from first scene used for training
        %This is stored with the camera so incoming scenes can be set to
        %the correct illuminant.
        val = L3.training.illuminant;
    case{'renderingilluminant'}; % The target illuminant L3 tries to match. 
        %Scenes can only be rendered under this illuminant with the corresponding filters. 
        val = L3.rendering.illuminant;
    case{'oi','opticalimage'};       
        % The optical image is here mainly for lens information. 
        % Not sure what else. 
        val = L3.oi;
    case {'monochromesensor'}
        % ISET monochrome sensor structure. We only store the sensorD and
        % make a monochrome version of it.
        val = sensorMonochrome(L3.sensor.design, 'Monochrome');
    case {'idealfilters','idealsensorfilters'}
        % These are the filters used for the ideal sensor to create the
        % training data set.
        val = L3.sensor.idealFilters;
    case {'nidealfilters'}
        tmp = L3Get(L3,'ideal filters');
        if ~isempty(tmp)
            val = length(tmp.filterNames);            
        else  %this may be needed in case ideal filters are not stored
            tmp = L3Get(L3,'filters');
            val = size(tmp{1}.flat,1);
        end
    case {'idealfiltername'}
        tmp = L3Get(L3,'ideal filters');
        val = tmp.name;
    case {'idealfilterwave'}
        tmp = L3Get(L3,'ideal filters');
        val = tmp.wave;
    case {'idealfiltertransmissivities'}
        tmp = L3Get(L3,'ideal filters');
        val = tmp.transmissivities;
    case {'idealfilternames'}
        tmp = L3Get(L3,'ideal filters');
        val = tmp.filterNames;
        
    case{'designsensor'}
        % This is the sensor we are trying to design. It can have an
        % unusual CFA and color filters
        val = L3.sensor.design;
    case {'filtervals','designfiltervals'}
        sensor = L3Get(L3,'design sensor');
        cfaPattern = sensorGet(sensor,'cfa pattern');
        val = sort(unique(cfaPattern));    
    case {'ndesignfilters','nfilters'}
        sensor = L3Get(L3,'design sensor');
        val = sensorGet(sensor,'nfilters');
    case {'cfapattern','designcfapattern'}
        % Only the design sensor has a cfa pattern. The ideal is monochrome
        val = sensorGet(L3Get(L3,'sensor design'),'cfa pattern');
    case {'designfiltertransmissivities'}
        sensor = L3Get(L3,'design sensor');
        val = sensorGet(sensor,'spectral QE');
        
        % Data for training
    case{'sensorpatches','spatches'}
        % val= L3Get(L3,'sensor patches')
        % Design sensor training patches.
        %
        % If saturation indices has not yet been determined, return all
        % patches.  But if saturation indices has already been found, only
        % return the patches that match the current saturation type.
        % 
        % This change is easiest to adapt to multiple saturation cases, but
        % it might be a little risky.
        if isfield(L3.training,'saturationindices') & ...
                ~isempty(L3.training.saturationindices);
            % Return only patches for current saturation case
            val = L3.data.patches(:, L3.training.saturationindices);
            
            % Put 0 for all pixels that measure the saturated channel.
            % With this approach, there is no risk of using these
            % measurements.  This is specifically considered in
            % L3findfilters but otherwise all the code just runs and uses 0
            % values.
            saturationpixels = L3Get(L3, 'saturation pixels');
            val(saturationpixels,:) = 0;
        else  % Return all patches
            val = L3.data.patches;
        end

    case{'sensorpatchesno0'}
        % val= L3Get(L3,'sensor patches no 0')        
        % Patches but with measurements for saturated channels not replaced
        % with 0.  Getting sensor patches (above) returns 0 for all pixels
        % that measure a saturated channel for the current saturated index.
        % Sometimes we don't want that such as get 
        % 'sensor patch saturation'.
        if isfield(L3.training,'saturationindices') & ...
                ~isempty(L3.training.saturationindices)
            % Return only patches for current saturation case
            val = L3.data.patches(:, L3.training.saturationindices);
        else  % Return all patches
            val = L3.data.patches;            
        end
        
    case {'nsensorpatches','nspatches'}
        % L3Get(L3,'n sensorpatches');
        % How many patches currently stored
        % This has two modes - very similar to 'sensorpatches' above
        if isfield(L3.training,'saturationindices') & ...
                ~isempty(L3.training.saturationindices);
            % Count only patches for current saturation case
            val = sum(L3.training.saturationindices);
        else  % Counnt all patches
            val = size(L3.data.patches,2);
        end        
        
    case {'sensorpatchesnoisy','spatchesnoisy'}
        % L3Get(L3,'sensor patches noisy')
        %
        % We reset the random number generator to the initial configuration
        % here.  To think.
        patches = L3Get(L3,'sensor patches');
        sensorD = L3Get(L3,'sensor design');
        
        % For now, we also reset the random number generator before getting
        % the noisy patches
        rInit = L3Get(L3,'random seed');
        rand('state',rInit); randn('state',rInit);   
        val = patches + L3noisegenerate(patches,sensorD);

    case {'sensorpatchluminance','sensorpatchluminances'}
        % val = L3Get(L3,'sensor patch luminance');
        lFilter = L3Get(L3,'luminance filter');
        patches = L3Get(L3,'sensor patches');
        val = lFilter*patches;
        
    case {'sensorpatchmeans'}
        % val = L3Get(L3,'sensor patch means');
        % Mean in each color channel for each patch
        meansFilter = L3Get(L3,'means filter');
        patches     = L3Get(L3,'sensor patches');
        val = meansFilter*patches;

    case {'sensorpatcheszeromean'}
        % val = L3Get(L3,'sensor patch zero mean')
        patches = L3Get(L3,'sensor patches');
        means   = L3Get(L3,'sensor patch means');
        blockPattern = L3Get(L3,'block pattern');
        val = L3adjustpatchmean(patches,-means,blockPattern);

    case {'sensorpatchcontrast','sensorpatchcontrasts'}
        % val = L3Get(L3,'sensor patch contrasts');
        val = L3Get(L3,'sensor patches zero mean');
        val = mean(abs(val));
        
    case {'sensorpatchcontrastnoisy','sensorpatchcontrastsnoisy'}
        % val = L3Get(L3,'sensor patch contrasts noisy');
        %
        meansFilter = L3Get(L3,'means filter');
        spNoisy     = L3Get(L3,'sensor patches noisy');
        means = meansFilter*spNoisy;
        blockPattern = L3Get(L3,'block pattern');
        val = L3adjustpatchmean(spNoisy,-means,blockPattern);
        val = mean(abs(val));
        
    case {'voltagemax'}
        % maximum voltage after deleting analog gain/offset
        % Actual voltage swing of pixel is higher.  But after we delete the
        % offset, the maximum voltage is reduced to this value.
        %
        % For example original data is in interval [ao/ag, voltageswing]
        % but new range is [0, voltageswing-ao/ag]
        sensorD = L3Get(L3,'sensordesign');
        pixel = sensorGet(sensorD,'pixel');
        voltageSwing = pixelGet(pixel,'voltage swing');  % pixel's actual voltage swing
        ao = sensorGet(sensorD,'analogOffset');
        ag = sensorGet(sensorD,'analogGain');
        val = voltageSwing - ao/ag;       % maximum voltage for L3 train & render
        
    case {'sensorpatchsaturation','sensorpatchsaturationcase'}
        % matrix giving the saturation case for each patch
        voltagemax = L3Get(L3,'voltage max');
        blockPattern = L3Get(L3,'block pattern');
        nfilters = L3Get(L3, 'n filters');        
        patches = L3Get(L3,'sensor patches no 0'); % saturated colors are not 0ed
        saturated = (patches >= voltagemax-.001);
        val = zeros(nfilters,size(patches,2));
        for filternum = 1:nfilters
            patchindices = (blockPattern(:) == filternum);
            val(filternum, :) = any(saturated(patchindices,:));
        end
        
        % Since we have already done most of the calculation, let's find
        % and save saturation indices (see L3Get 'saturationindices').
        % This prevents us from needing to run this calculation again.
        saturationtype = L3Get(L3,'saturation type');
        if ~isempty(saturationtype)
            desiredsaturationcase = L3Get(L3,'saturation list',saturationtype);
            saturationindices = L3findsaturationindices(val, ...
                                                 desiredsaturationcase);
            L3.training.saturationindices = saturationindices;
        end
        
    case {'texturepatches'}
        % L3Get(L3,'texture patches')
        % Retrieve the textured patches (i.e., patches with a contrast
        % exceeding the threshold.  These are just the patches for the
        % current patch type.
        textureIndices = L3Get(L3,'texture indices');
        allPatches = L3Get(L3,'spatches');
        val = allPatches(:,textureIndices);
    case{'idealvector','ivector'};
        % L3Get(L3,'ivector')
        % These are number of colors x number of samples
        % These are the ideal (correct) values for the center pixel.
        % This has two modes - very similar to 'sensorpatches' above
        if isfield(L3.training,'saturationindices') & ...
                ~isempty(L3.training.saturationindices);
            % Count only patches for current saturation case
            val = L3.data.ideal(:,L3.training.saturationindices);
        else  % Count all patches
            val = L3.data.ideal;
        end   
        

    case {'blockwidth'}
        % Fix this.
        val = L3.training.patchSize;
    case{'blockrowcol','blocksize'}
        val = [L3.training.patchSize, L3.training.patchSize];
    case {'nsamplesperpatch','npixelsperpatch','npixelsperblock','nblocksamples'}
        % Number of samples in the block used for training
        val = prod(L3Get(L3,'blocksize'));
        
        % Filters.  Format needs to be described.
    case {'filters'}
        % Whole structure
        val = L3.filters;
    case {'globalfilter'}                
        if ~isempty(varargin), pt = varargin{1}; end
        if length(varargin) > 1, lt = varargin{2}; end
        if length(varargin) > 2, st = varargin{3}; end
        val = L3.filters{pt(1),pt(2),lt,st}.global;
    case{'luminancefilter','lfilter'};
        % lFilter = L3Get(L3,'luminance filter',patchType,satType)
        % luminancefilter is a vector that is used to calculate the patch
        % luminance.
        % We take the inner product of this vector and the patch to
        % calculate the luminance level of the patch.  By luminance we mean
        % really the weighted average voltage.  We call this
        % patchluminance.
        %
        % patchluminance is calculated as follows:
        %   1.  find mean of each measured color channel
        %   2.  patchluminance is the mean of these values
        %
        % This is not quite the same as averaging all because there may not
        % be the same number of color samples in each patch.
        %
        if ~isempty(varargin), pt = varargin{1}; end
        if length(varargin) > 1, st = varargin{2}; end
        blockpattern   = L3Get(L3,'block pattern',pt);
        saturationcase = L3Get(L3,'saturation list',st);
        
        % Line immediately following counts a completely black color
        % filter, X, when finding the luminance.  This can cause problems.
        % We can ignore the X pixels by checking if the filter has any
        % positive values.  (Similar to L3Get(L3,'X pixels'))
%         measuredColors   = L3Get(L3,'filter vals');
        transmissivities = L3Get(L3,'design filter transmissivities');
        measuredColors = find(sum(transmissivities)>0 & ~saturationcase');
        
        val = zeros(1,L3Get(L3,'n samples per patch'));
        for ii = 1:length(measuredColors)
            cfaindices = find(blockpattern == measuredColors(ii));
            val(:,cfaindices) = 1/length(cfaindices)/length(measuredColors);
        end
        
    case{'meansfilter','meanfilter','mfilter','meanfilters'}
        % L3Get(L3,'mean filters',patchType)
        %
        % Create vectors to multiply by the patch data and calculate the
        % average value for each color type.
        if ~isempty(varargin), pt = varargin{1}; end
        val = zeros(L3Get(L3,'n filters'),L3Get(L3,'n pixels per block'));
        measuredColors  = L3Get(L3,'filter vals');
        blockpattern = L3Get(L3,'block pattern',pt);
        for ii=1:length(measuredColors)
            cfaindices = find(blockpattern== measuredColors(ii));
            val(ii,cfaindices) = 1/length(cfaindices);
        end

    case{'flatfilter','ffilter','flatfilters'}
        % L3Get(L3,'flat filters',patchType,lumType)
        if ~isempty(varargin), pt = varargin{1}; end
        if length(varargin) > 1, lt = varargin{2}; end
        val = L3.filters{pt(1),pt(2),lt,st}.flat;
        
    case{'texturefilter','tfilter','texturefilters'}
        % L3Get(L3,'texture filters',patchType,lumType,textureType)
        if ~isempty(varargin), pt = varargin{1}; end
        if length(varargin) > 1, lt = varargin{2}; end
        if length(varargin) > 2
            % Return a specific texture
            val = L3.filters{pt(1),pt(2),lt,st}.texture{varargin{3}};
        else
            % Return the whole cell array of textures
            val = L3.filters{pt(1),pt(2),lt,st}.texture;
        end
        
        % Patch classification parameters
    case {'flip'}
        % L3Get(L3,'flip')
        %
        % A structure indicating whether or not to flip the patch,
        % depending on the presence of symmetry in the block pattern over
        % each direction.
        blockpattern = L3Get(L3,'block pattern');
        % Horizontal
        val.h = all(all(all(blockpattern==blockpattern(end:-1:1,:,:))));
        % Vertical
        val.v = all(all(all(blockpattern==blockpattern(:,end:-1:1,:))));
        % Main diagonal
        val.t = all(all(all(blockpattern==permute(blockpattern,[2,1,3]))));

    case {'blockpattern'}
        % L3Get(L3,'block pattern',[r,c])
        % Returns the cfa values in the block centered at a pixel in
        % position (r,c) of the design sensor
        if ~isempty(varargin), rowcol = varargin{1};
        else rowcol = L3Get(L3,'patch type');
        end
        blockWidth = L3Get(L3,'blockrowcol');
        cfaPattern = L3Get(L3,'cfa pattern');
        val = L3TrainBlockPattern(rowcol,blockWidth,cfaPattern);
    
    case {'saturationpixels'}
        % L3Get(L3, 'saturation pixels')
        % Binary vector indicating which pixels belong to saturated color
        % channels for current saturation case  (Format is same as a
        % column of patches)
        blockpattern = L3Get(L3, 'block pattern');
        saturationcase = L3Get(L3,'saturation list',st);
        satblockpattern = saturationcase(blockpattern);
        satblockpattern = logical(satblockpattern);
        val = satblockpattern(:);
        
    case {'xpixels'}
        % L3Get(L3, 'X pixels')
        % Binary vector indicating which pixels do not have a measurement
        % In reality they probably have a measurement that should not be
        % used for the current application.  (Format is same as a
        % column of patches)
        sensitivities = L3Get(L3, 'design filter transmissivities');
        xfilters = sum(sensitivities)==0;
        
        blockpattern = L3Get(L3, 'block pattern');
        xblockpattern = xfilters(blockpattern);
        xblockpattern = logical(xblockpattern);
        val = xblockpattern(:);    

    case {'flatindices'}
        % L3Get(L3,'flat indices');
        % These patches have low contrast

        % The first time flat indices is gotten it is calculated and
        % stored. Subsequent times it is loaded and not calculated.
        % These indices are cleared each time the patch type, luminance
        % type, or saturation type change.
        if isfield(L3.training,'flatindices') & ...
                ~isempty(L3.training.flatindices);
            % Just load previously saved flat indices
            val = L3.training.flatindices;
        else       
            % Find flat indices and then save them
            flatThreshold = L3Get(L3,'flat threshold');
            contrasts     = L3Get(L3,'sensor patch contrasts');
            val = (flatThreshold >= contrasts);
            L3.training.flatindices = val;
        end

    case {'textureindices'}
        % L3Get(L3,'texture indices');
        % These are the patches with enough contrast to be declared texture
        flatIndices = L3Get(L3,'flat indices');
        val = logical(1 - flatIndices);
        
    case {'saturationindices'}
        % L3Get(L3,'saturation indices');
        % These are the patches that match the desired saturation case
        
        % The first time saturation indices is gotten it is calculated and
        % stored (also stored for L3Get 'sensorpatchsaturation'. Subsequent
        % times it is loaded and not calculated. These indices are cleared
        % each time the patch type, luminance type, or saturation type
        % change.
        if isfield(L3.training,'saturationindices') & ...
                ~isempty(L3.training.saturationindices);
            % Just load previously saved saturation indices
            val = L3.training.saturationindices;
        else
            % Find saturation indices and then save them
            saturationcases = L3Get(L3,'sensor patch saturation');
            saturationtype = L3Get(L3,'saturation type');
            desiredsaturationcase = L3Get(L3,'saturation list',saturationtype);            
            saturationindices = L3findsaturationindices(saturationcases, ...
                                                 desiredsaturationcase);
            val = saturationindices;
            L3.training.saturationindices = val;   % store to avoid repeat calculation
        end
        
    case {'nclusters'}
        % Binary tree, I guess.
        val = 2^L3Get(L3,'tree depth') - 1;
        
        % Training parameters
    case {'training'}
        % The whole structure.
        val = L3.training;
    case {'noversample'}
        val = L3.training.oversample;
    case {'saturationflag'}
        val = L3.training.saturation;
    case {'ntrainingpatches'}        
        val = L3.training.nPatches;
    case {'maxtrainingpatches'}
        % Maximum number of training patches for patch type 
        % (see L3trainingPatches.m)
        if isfield(L3.training,'maxTrainingPatches')
            val = L3.training.maxTrainingPatches;
        else
            val = [];
        end
    case {'randomseed','rinit'}
        val = L3.training.randomSeed;
    case {'maxtreedepth','treedepth'}
        % When we cluster the textures, this is how many levels
        val = L3.training.treeDepth;
    case {'flatpercent'}
        val = L3.training.flatPercent;
    case {'minnonsatchannels'}
        % L3Get(L3,'min non sat channels');
        % Minimum number of non-saturated (good) channels in order to train
        % a filter.  For example if we want XYZ out, it is hopeless to
        % train filters that can only use 2 good input channels.
        val = L3.training.minnonsatchannels;
    case{'luminancelist'};  % We create filters for each luminance level
        % L3Get(L3,'luminance list',whichLum);
        % This can be a vector, and without an argument the whole vector is
        % returned.  If a number is passed in, then that entry of the
        % vector is returned.
        val = L3.training.luminanceList;
        if ~isempty(varargin)
            val = val(varargin{1});
        end 
    case{'luminancesaturationcase'}
        % For the current patch type and saturation case, which of the
        % entries in the luminance list were actually trained (For each
        % patch type and saturation case, any luminance value that did not
        % have enough training patches was not trained.)
        % This returns indices to the luminance list.  The actual luminance
        % values are obtained from the luminance list.    
        lumsamplelength = size(L3.filters, 3);  % lenght of luminancelist
        val = false(1, lumsamplelength);
        for lumsample = 1:lumsamplelength
            val(lumsample) = ~isempty(L3.filters{pt(1),pt(2),lumsample,st});
        end
        
    case{'saturationlist'};  % We create filters for each saturation case        
        % L3Get(L3,'saturation list',whichSat);        
        % Without an argument the whole matrix is returned.  If a number is
        % passed in, then that column of the matrix is returned.
        % Each column is a binary vector with length equal to the number of
        % color channels in the CFA.  The entry is 1 if the corresponding
        % color channel is saturated.
        % Only the saturation cases that occur for the training data are
        % trained and stored.
        if isempty(L3.training.saturationList) | ...
                size(L3.training.saturationList,1) < pt(1) | ...
                size(L3.training.saturationList,2) < pt(2)
            val = [];
        else
            val = L3.training.saturationList{pt(1),pt(2)};
            if ~isempty(varargin) & ~isempty(varargin{1})
                val = val(:, varargin{1});
            end
        end
    case{'lengthsaturationlist'};  % Number of saturation cases in list      
        val = size(L3.training.saturationList{pt(1),pt(2)},2);  % each column is a case
        
    case{'desiredpatchluminance'}
        val = L3Get(L3,'luminance list',lt);
        
        % Cluster (Texture) analysis related
    case {'clusters'}
        % The whole structure
        val = L3.clusters;
    case{'pca','clusterdirections'}
        % Principal component analysis structure
        val = L3.clusters{pt(1),pt(2),lt,st}.pca;
    case {'clustermembers'}
        val = L3.clusters{pt(1),pt(2),lt,st}.members;
    case {'clusterthresholds'}
        val = L3.clusters{pt(1),pt(2),lt,st}.thresholds;
    case {'flatthreshold'}
        val = L3.clusters{pt(1),pt(2),lt,st}.flat;
        
        % Processing properties
    case {'luminanceindex'}
        % When we process an image, we can remember here which patch was
        % interpreted by which luminance training level.
        if checkfields(L3,'processing','lumIdx')
            val = L3.processing.lumIdx;
        end
    case {'saturationindex'}
        % When we process an image, we can remember here which patch was
        % interpreted by which saturation case.
        if checkfields(L3,'processing','satIdx')
            val = L3.processing.satIdx;
        end     
    case {'clusterindex'}
        % When we process an image, we can remember here which patch was
        % flat (0) or texture (positive number giving texture cluster)
        if checkfields(L3,'processing','clusterIdx')
            val = L3.processing.clusterIdx;
        end
        
    case{'borderwidth'}
        %Tells how many pixels wide the black border is around an image.
        %The border is caused by the inability to fit an entire patch
        %centered at a pixel near the edge of the image.
        blockWidth = L3Get(L3,'block width');
        val = floor(blockWidth/2);
        
    case {'xyzresult'}
        % When we process an image, we can remember here the xyz output.
        val = L3.processing.xyz;
    
    case {'weightcolortransform'}
        % Color transform used to weight cost of bias and variance errors.
        % If we want to choose different weights for bias/variance tradeoff
        % for each color channel, this matrix is needed to define the color
        % channels where the weighting is performed.  If this is not
        % desired, an identity matrix or a scalar of 1 can be used.
        % See L3findRGBWcolortransform        
        val = L3.training.weightColorTransform;
        
    case {'weightbiasvariance'}
        % Weights for bias and variance tradeoff when finding filters.
        % Larger value means variance (noise) is more costly and should be
        % avoided. Value of 1 implies minimum squared error is desired 
        % (equal weight to bias and variance). See L3findfilters.  
        % It's a length 3 vector with each component corresponding to the 
        % desired weight for output channels. In luminance channel, large
        % weight blurs images. In chromance channel, large weight
        % desaturats color. 
        % Flat and texture regions have different weights setting. In this
        % way, we can blur the flat regions more to decrease noise while
        % keeping the sharpness of the texture regions. 
        % It's used across the full range of luminance levels. It mainly
        % works for low light condition, and has neglectable influence when
        % it's bright. 
        if ct == 1
            val = L3.training.weightBiasVariance.global;
        elseif ct == 2
            val = L3.training.weightBiasVariance.flat;
        else
            val = L3.training.weightBiasVariance.texture;
        end
        
    case {'contrasttype'}
        val = L3.contrastType;
        
    case {'rendering'}
        % The whole structure.
        val = L3.rendering;
        
    case {'transitioncontrast'}
        val = L3.rendering.transition;
    
    case {'transitioncontrastlow'}
        val = L3.rendering.transition.low;
        
    case {'transitioncontrasthigh'}
        val = L3.rendering.transition.high;
        
    case {'transitionindices'}
        if isfield(L3.rendering,'transitionindices') & ...
                ~isempty(L3.rendering.transitionindices);
            % Just load previously saved transition indices
            val = L3.rendering.transitionindices;
        else       
            % Find transition indices and then save them
            flatThreshold = L3Get(L3,'flat threshold');
            contrasts     = L3Get(L3,'sensor patch contrasts');
            transitionContrastHigh = L3Get(L3, 'transition contrast high');
            transitionContrastLow = L3Get(L3, 'transition contrast low');
            val = (contrasts <= flatThreshold * transitionContrastHigh) & ...
                  (contrasts >= flatThreshold * transitionContrastLow);
            L3.rendering.transitionindices = val;
        end
        
    case {'transitionweightsflat'}
        flatThreshold = L3Get(L3,'flat threshold');
        contrasts = L3Get(L3,'sensor patch contrasts');
        upper = flatThreshold * L3Get(L3, 'transition contrast high');
        lower = flatThreshold * L3Get(L3, 'transition contrast low');
        transitionindices = L3Get(L3,'transition indices');
        val = (contrasts(transitionindices) - lower) / (upper - lower);
        val = repmat(val, [L3Get(L3,'nideal filters'), 1]);
                    
    otherwise
        error('Unknown %s\n',param);    
end


%% Not sure why this is here ... explain further.  
function sensor = sensorMonochrome(sensor,filterFile)
%
%   Create a default monochrome image sensor array structure. This
%   functions is a nested function extracted from sensorCreate.m. See
%   snesorCreate.m
%
sensor = sensorSet(sensor,'name',sprintf('monochrome-%.0f', vcCountObjects('sensor')));

[filterSpectra,filterNames] = sensorReadColorFilters(sensor,filterFile);
sensor = sensorSet(sensor,'filterSpectra',filterSpectra);
sensor = sensorSet(sensor,'filterNames',filterNames);

sensor = sensorSet(sensor,'cfaPattern',1);      % 'bayer','monochromatic','triangle'

end

end