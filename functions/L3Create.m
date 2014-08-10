function L3 = L3Create(L3name)
% Create an empty L3 structure
%
%  L3 = L3Create(L3name)
%
% L3 structure contains the data, filters, and related parameters for an L3
% experiment.  The L3 experiments begin with images obtained by a specific
% sensor under specific conditions.
%
%  * The sensor and scene descriptions, produce corresponding sets of
%    sensor patches and ideal patches for training.
%  * The training produces the filters.
%  * The filters can then be applied to data under similar conditions from
%    the original sensor.
%
%
% Examples:
%    L3 = L3Create;
%
% See also:   L3Initialize that sets default values
%
% (c) Stanford VISTA Team 2012

if ieNotDefined('L3name'), L3name = 'default'; end

% Book-keeping
L3.name = 'default';
L3.type = 'L3';
L3.patchType = [];    % Assumed entry to analyze in the CFA
L3.lumType = [];      % Index of desired patch luminance value
L3.saturationType = [];      % Index of desired saturation case
L3.contrastType = [];      % Index of desired contrast case, i.e global, flat and texture

% Common to all of the patch types (pixel positions in the cfa)

% Should we save scene, oi and sensor?
L3.scene = [];    % Should this be the scene, or just the name of a scene file?
L3.oi = [];       % For lens information?  Optics?
L3.sensor.idealFilters = [];
L3.sensor.design = [];   % Mosaic, noise, we are designing this one. Don't store data?

% Training parameters
L3.training.randomSeed  = [];
L3.training.saturation  = [];
L3.training.oversample  = [];
L3.training.flatPercent = [];
L3.training.minnonsatchannels = [];
L3.training.luminanceList = [];  % We should create filters for each luminance level
L3.training.saturationList = [];
L3.training.treeDepth  = [];
L3.training.weightColorTransform = [];
L3.training.weightBiasVariance = [];
L3.training.illuminant = [];

% Rendering parameters
L3.rendering.transition.low = [];
L3.rendering.transition.high = [];
L3.rendering.illuminant = [];

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


%%
% Set according to name?  Or just do parameter assignments?
L3name = ieParamFormat(L3name);
switch L3name
    case {'default'}
    otherwise
        error('Unknown L3 name %s',L3name);
end

end

        
