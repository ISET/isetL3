function [uData, g] = L3plot(L3,plotType,varargin)
% Gateway plotting routine for the L3 structure
%
%  [uData, g] = L3plot(L3,plotType,varargin)
%
% Example:
%   sensor = L3Get(L3,'design sensor'); plotSensor(sensor,'cfa block');
%   sensor = L3Get(L3,'design sensor'); plotSensor(sensor,'cfa full');
%
%   uData = L3plot(L3,'block pattern',[1,1]);
%
%   uData = L3plot(L3,'mean filter');  % Use current patch type
%   uData = L3plot(L3,'mean filter',[2,1]);
%
%   uData = L3plot(L3,'global filter');  % Use current patch type
%
%   uData  = L3plot(L3,'flat filter');  % Use current patch type
%   uData  = L3plot(L3,'flat filter',[2,1]);  
%   uData2 = L3plot(L3,'flat filter',[2,1],1);  
%
%   uData = L3plot(L3,'luminance filter',[2,1]);  
%  
% (c) Stanford VISTA Team, 2012


%% Programming TODO:
% Ideas.
%
% Classify pixels by type (texture, flat, and luminance, so forth)
%  L3plot(L3,'luminance levels')
%  L3plot(L3,'texture class')
%
%  L3plot(L3,'show the training data')
%
%  L3plot(L3,'illustrate patches')
%
% Scripts for metrics.


%%
if ieNotDefined('L3'), error('L3 structure required.'); end
if ieNotDefined('plotType'), error('plot type required.'); end

% Check if 'no fig' is final varargin.
g = [];
patchType = L3Get(L3,'patch type');   % Start with default patch type
lumType   = L3Get(L3,'lum type');   % Start with default luminance type

plotType = ieParamFormat(plotType);

switch plotType
    
    % Trained filter plots
    case {'meanfilter'}
        % L3plot(L3,'mean filter',[1,1]);
        if ~isempty(varargin), patchType = varargin{1}; end
        if isempty(patchType)
            patchType = [1,1];
            warning('No default patch type.  Using [1,1].')
        end
        [uData,g] = L3plotFilters(L3,'mean filter',patchType);
        
    case {'globalfilter'}
        % L3plot(L3,'global filter',[1,1],1);
        if ~isempty(varargin), patchType = varargin{1}; end
        if isempty(patchType)
            patchType = [1,1];
            warning('No default patch type.  Using [1,1].')
        end        
        if length(varargin) > 1, lumType = varargin{2}; end
        if isempty(lumType)
            lumType = 1;
            warning('No default luminance type.  Using 1.')
        end
        [uData,g] = L3plotFilters(L3,'global filter',patchType,lumType);
        
    case {'flatfilter'}
        if ~isempty(varargin), patchType = varargin{1}; end
        if isempty(patchType)
            patchType = [1,1];
            warning('No default patch type.  Using [1,1].')
        end        
        if length(varargin) > 1, lumType = varargin{2}; end
        if isempty(lumType)
            lumType = 1;
            warning('No default luminance type.  Using 1.')
        end                  
        [uData,g] = L3plotFilters(L3,'flat filter',patchType,lumType);
        
    case {'texturefilter'}
        % L3Plot(L3,'texture filter',patchType,lumType,textureType)
        if ~isempty(varargin), patchType = varargin{1}; end
        if isempty(patchType)
            patchType = [1,1];
            warning('No default patch type.  Using [1,1].')
        end        
        if length(varargin) > 1, lumType = varargin{2}; end
        if isempty(lumType)
            lumType = 1;
            warning('No default luminance type.  Using 1.')
        end                  
        if length(varargin) < 3, error('Texture type required');
        else textureType = varargin{3};
        end
        [uData,g] = L3plotFilters(L3,'texture filter',patchType,lumType,textureType);
        
    case {'luminancefilter'}
        if ~isempty(varargin), patchType = varargin{1}; end
        if isempty(patchType)
            patchType = [1,1];
            warning('No default patch type.  Using [1,1].')
        end        
        [uData,g] = L3plotFilters(L3,'luminance filter',patchType);
        
    % Sensor related plots
    case {'blockpattern'} 
        % L3 = L3Set(L3,'patch type',[1,1]);
        % [uData, g] = L3plot(L3,'block pattern',patchType);
        % See L3showpatchtypes for additional things we might do.
        if ~isempty(varargin), patchType = varargin{1}; 
        else patchType = [1,1];
        end
        bPattern = L3Get(L3,'block pattern',patchType);
        sensor   = L3Get(L3,'design sensor');
        sensor   = sensorClearData(sensor);
        sensor   = sensorSet(sensor,'size',size(bPattern));
        sensor   = sensorSet(sensor,'pattern',bPattern);
        
        % Tell this guy whether a figure is of interest.
%         [uData, g] = plotSensor(sensor,'cfa full');
        
        % Could implement this other way of showing the colors.
        % Should decide what we want in ISET, really.
        [uData, g] = plotSensor(sensor,'cfa block');
       
    case {'cfa','cfafull'}
        % L3plot(L3,'cfa full');
        % Shows the entire sensor CFA as an image
        sensor   = L3Get(L3,'design sensor');
        
        % Tell this guy whether a figure is of interest.
        [uData, g] = plotSensor(sensor,'cfa block');
        
    otherwise
        error('Unknown plot type: %s\n',plotType);
end

set(gcf,'userdata',uData);

end
