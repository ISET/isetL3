function L3 = L3Set_il(L3,param,val)

%Set the parameters in an L3 structure
%
%   L3 = L3Set(L3,param,val)
%
% (c) Stanford VISTA Team

if ~exist('L3', 'var') || isempty(L3),        error('L3 struct required'); end
if ~exist('param','var') || isempty(param) , error('param required');     end
if ~exist('val','var'),                       error('val required');       end

% Used for setting the patch type dependent parameters which are filters
% and clusters
if isfield(L3,'patchType')
    pt = L3Get(L3,'patch type');
end

if isfield(L3,'lumType')
    lt = L3Get(L3,'lum type');
end

if isfield(L3,'saturationType')   % saturation type
    st = L3Get(L3,'saturation type');
end


param = ieParamFormat(param);

switch param
    
    % Book-keeping
    case {'name'}
        L3.name = val;
    case {'type'}
        L3.type = val;
    case {'patchtype'}
        L3.patchType = val;
        L3 = L3ClearIndicesData(L3);  % reset flat and saturation indices
        
        % ISET structures used to create data set
    case{'scene'};    % Maybe general scene conditions?
        L3.scene = val;
    case{'trainingilluminant'};  %Illuminant from first scene used for training
        %This is stored with the camera so incoming scenes can be set to
        %the correct illuminant.
        L3.training.illuminant = val;
    case{'renderingilluminant'}; % The target illuminant L3 tries to match.
        %Scenes can only be rendered under this illuminant with the corresponding filters. 
        L3.rendering.illuminant = val;
    case{'oi','opticalimage'};       % For lens information?  Maybe just optics?
        L3.oi = val;
    case{'sensordesign','designsensor'};   
        % ISET Sensor structure.  Adjust using sensorSet.
        L3.sensor.design = val;
        
    case {'idealfilters','idealsensorfilters'}
        % Structure for color filters used in front of monochrome sensor
        L3.sensor.idealFilters = val;
    case {'idealfiltername'}
        L3.sensor.idealFilters.name = val;
    case {'idealfiltertransmissivities'}
        L3.sensor.idealFilters.transmissivities = val;
    case {'idealfilternames'}
        L3.sensor.idealFilters.filterNames = val;
        
        % Data for training
    case{'sensorpatches','spatches'}   
        % Save training patches from sensor for a particular patch type and
        % luminance type
        L3.data.patches = val;
        L3 = L3ClearIndicesData(L3);  % reset flat and saturation indices
    case{'sensorpatchessaturationcase'}   
        % Same as above but only overwrite the patches for current
        % saturation indices
        saturationindices = L3Get(L3, 'saturation indices');
        L3.data.patches(:, saturationindices) = val;
    case{'nsaturationpatches'}
        % Number of saturation patches used when training this particular
        % type of patch (patch type, luminance type, saturation type)
        L3.filters{pt(1),pt(2),lt,st}.nsaturationpatches = val;

    case{'idealvector','ivector'}
        % The ideal (correct) values for the center pixel for this patch
        % type and luminance type
        L3.data.ideal = val;

        % Filters.  Format needs to be described.
    case {'filters'}  % Whole structure
        L3.filters = val;
    case {'globalfilter'}
        L3.filters{pt(1),pt(2),lt,st}.global = val;       
    case{'flatfilter','ffilter','flatfilters'}
        L3.filters{pt(1),pt(2),lt,st}.flat = val;
    case{'texturefilter','tfilter','texturefilters'}
        L3.filters{pt(1),pt(2),lt,st}.texture = val;
    case{'emptyfilter'}
        % val is ignored
        % Fill in empty matrix in filter structure at current patch type,
        % luminance, and saturation.  This is used if there are not enough
        % patches for training this case.
        L3.filters{pt(1),pt(2),lt,st} = [];
        
        

        % Other Patch training parameters
    case {'training'}
        % The whole structure.
        L3.training = val;
    case {'noversample'}
        % Controls over sampling.  Describe here
        L3.training.oversample = val;
    case {'saturationflag'}
        % Use saturation or not ... probably shouldn't be a flag.
        L3.training.saturation = val;
    case {'ntrainingpatches','npatches'}
        L3.training.nPatches = val;
    case {'maxtrainingpatches'}
        % Maximum number of training patches for patch type 
        % (see L3trainingPatches.m)
        L3.training.maxTrainingPatches = val;
    case {'randomseed','rinit'}
        L3.training.randomSeed = val;
    case {'flatpercent'}
        % Percentage of patches we want to treat as flat
        L3.training.flatPercent = val;
    case {'minnonsatchannels'}
        % Minimum number of non-saturated (good) channels in order to train
        % a filter.  For example if we want XYZ out, it is hopeless to
        % train filters that can only use 2 good input channels.
        L3.training.minnonsatchannels = val;
    case {'maxtreedepth','treedepth'}
        % When we cluster the textures, this is how many levels
        L3.training.treeDepth = val;
        % Cluster (Texture) analysis related
     case{'luminancelist'};  
        % We create filters for each luminance level in the list.
        L3.training.luminanceList = val;
    case{'luminancetype','lumtype'}
        %Integer giving the index into luminancelist for the current
        %luminance level.
        L3.lumType = val;
        % reset flat indices
        if isfield(L3.training, 'flatindices')
            L3.training.flatindices = [];
        end
     case{'saturationlist'};
        % We create filters for each saturation case in the list.
        % At end of training, list should contain all saturation cases that
        % occur in training data.
        L3.training.saturationList{pt(1),pt(2)} = val;
    case{'sattype','saturationtype'}
        %Integer giving the index into saturationlist for the current
        %saturation case.
        L3.saturationType = val;
        L3 = L3ClearIndicesData(L3);  % reset flat and saturation indices
        
    case {'blocksize'}
        % The size of the block (patch) used for training.
        % This should probably be a 2-vector in general.
        % But it could be a single number.  To decide and get clear.
        L3.training.patchSize = val;
        
    case {'clusters'}
        % The whole structure
        L3.clusters = val;
    case{'pca','clusterdirections'}
        % Principal component analysis structure
        L3.clusters{pt(1),pt(2),lt,st}.pca = val;
    case {'clustermembers'}
        L3.clusters{pt(1),pt(2),lt,st}.members = val;
    case {'clusterthresholds'}
        L3.clusters{pt(1),pt(2),lt,st}.thresholds = val;
    case {'clusterflatthreshold','flatthreshold'}
        L3.clusters{pt(1),pt(2),lt,st}.flat  = val;

        % Processing properties
    case {'saturationindices'}
        % These are the patches that match the desired saturation case.
        % When training, it is best to do L3Get(L3,'saturation indices')
        % which if saved properly, will also set the saturation indices.
        % When testing, the saturation case for a patch sometimes isn't in
        % the list of trained saturation cases.  Therefore, we need to
        % pick the best of the trained saturation cases even though it
        % doesn't match perfectly.  For this reason, it is possible to set
        % saturation indices instead of store the value automatically
        % calcualted from getting it (which is what happens during
        % training).  When you get saturation indices, if already in memory
        % it is returned and if not it is calculated.
        L3.training.saturationindices = logical(val);
        
    case {'luminanceindex'}
        % When we process an image, we can remember here which patch was
        % interpreted by which luminance training level.
        L3.processing.lumIdx = val;
    case {'saturationindex'}
        % When we process an image, we can remember here which patch was
        % interpreted by which saturation case.
        L3.processing.satIdx = val;
    case {'clusterindex'}
        % When we process an image, we can remember here which patch was
        % flat (0) or texture (positive number giving texture cluster)
        L3.processing.clusterIdx = val;          
    case {'xyzresult'}
        % When we process an image, we can remember here the xyz output.
        L3.processing.xyz = val;
        
    case {'weightcolortransform'}
        % Color transform used to weight cost of bias and variance errors.
        % If we want to choose different weights for bias/variance tradeoff
        % for each color channel, this matrix is needed to define the color
        % channels where the weighting is performed.  If this is not
        % desired, an identity matrix or a scalar of 1 can be used.
        % See L3findweightcolortransform
        L3.training.weightColorTransform = val;
            
    case {'globalweightbiasvariance'}
        L3.training.weightBiasVariance.global = val;

    case {'flatweightbiasvariance'}
        L3.training.weightBiasVariance.flat = val;
    
    case {'textureweightbiasvariance'}
        L3.training.weightBiasVariance.texture = val;
        
    case {'contrasttype'}
        L3.contrastType = val;
        
    case {'rendering'}
        % The whole structure.
        L3.rendering = val;
    
    case {'transitioncontrastlow'}
        L3.rendering.transition.low = val;
        
    case {'transitioncontrasthigh'}
        L3.rendering.transition.high = val;
        
    case {'globaltrm'}
        L3.filters{pt(1),pt(2),lt,st}.globaltrm = val;    
    case{'flattrm'}
        L3.filters{pt(1),pt(2),lt,st}.flattrm = val;
    case{'texturetrm'}
        L3.filters{pt(1),pt(2),lt,st}.texturetrm = val;
           
    otherwise
        error('Unknown %s\n',param);
end

