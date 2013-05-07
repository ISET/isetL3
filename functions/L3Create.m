function L3 = L3Create(L3name,varargin)
% Create an L3 structure
%
%  L3 = L3Create(L3Name,varargin)
%
% An L3 (l-cubed) structure contains the data, filters, and related
% parameters for an L3 experiment.  The L3 experiments begin with images
% obtained by a specific sensor under specific conditions.
%
%  * The sensor and scene descriptions, produce corresponding sets of
%  sensor patches and ideal patches for training.
%  * The training produces the filters.
%  * The filters can then be applied to data under similar conditions from
%  the original sensor.
%
%
% Examples:
%    L3 = L3Create;
%
% See also:
%
% (c) Stanford VISTA Team 2012

if ieNotDefined('L3name'), L3name = 'default'; end

% Book-keeping
L3.name = 'default';
L3.type = 'L3';
L3.patchType = [];    % Assumed entry to analyze in the CFA
L3.lumType = [];      % Index of desired patch luminance value
L3.saturationType = [];      % Index of desired saturation case

% Common to all of the patch types (pixel positions in the cfa)

% Should we save scene, oi and sensor?
L3.scene = [];    % Should this be the scene, or just the name of a scene file?
L3.oi = [];       % For lens information?  Optics?
L3.sensor.ideal = [];        % Monochrome, no noise.  Don't store data?
L3.sensor.idealFilters = [];
L3.sensor.design = [];   % Mosaic, noise, we are designing this one. Don't store data?

% Training parameters
L3.training.randomSeed  = [];
L3.training.saturation  = [];
L3.training.oversample  = [];
L3.training.sigmaFactor = [];
L3.training.flatPercent = [];
L3.training.luminanceList = [];  % We should create filters for each luminance level
L3.training.saturationList = [];
L3.training.treeDepth  = [];


% These will become cell arrays of structures of
% [cfaSize(1),cfaSize(2),length(patchLuminanceLevels)]
% Ordinarily, they are allocated in L3Train.  We should worry about
% clearing them when we do certain L3Sets.
L3.filters = [];
L3.clusters= [];

% Data used for training
% The training data are the target value (often XYZ) for the center pixel.
% These are usually 3 x nPatches
L3.data.patches =   [];   % Save training patches from sensor?
L3.data.ideal = [];   % These are the ideal (correct) values.

% % These are cell arrays, one array for each color filter type in the CFA.
% for rr=1:cfaSize(1)
%     for cc = 1:cfaSize(2)
%         % Filter structure
%         L3.filters{rr,cc}.flat = [];
%         L3.filters{rr,cc}.texture = [];
%         
%         % Clusters (Texture) related
%         L3.clusters{rr,cc}.pca = [];
%         L3.clusters{rr,cc}.thresholds = [];
%         
%         % Special status for threshold  contrast that defines a flat texture
%         L3.clusters{rr,cc}.flat       = [];
%         L3.clusters{rr,cc}.members    = [];
%     end
% end

%% Set numerical default parameters

% Set according to name?  Or just do parameter assignments?
L3name = ieParamFormat(L3name);
switch L3name
    case {'default'}
    otherwise
        error('Unknown L3 name %s',L3name);
end

L3 = L3Set(L3,'n oversample',0);
L3 = L3Set(L3,'saturation flag', 1);
L3 = L3Set(L3,'sigma factor',1);
L3 = L3Set(L3,'random seed',0);
L3 = L3Set(L3,'max tree depth',3);
L3 = L3Set(L3,'flat percent',0.6);

end

        
