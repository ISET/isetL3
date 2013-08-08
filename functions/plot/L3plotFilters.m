function [uData, f] = L3plotFilters(L3,plotType,patchType,lumType,satType,textureType)
% Make images of the various L3 trained filters 
%
%   [uData, f] = L3plotFilters(L3,plotType,patchType,satType,lumType,textureType)
%   
% These should be called from L3plot rather than directly here.
%
% See: L3plot 
%
% Copyright Steven Lansel, 2010

%%
if ieNotDefined('L3'),        error('L3 structure required'); end
if ieNotDefined('plotType'),  error('plot type required'); end
if ieNotDefined('patchType'), patchType = L3Get(L3,'patch type'); end
if ieNotDefined('satType'), satType = L3Get(L3,'saturation type'); end
if ieNotDefined('lumType'), lumType = L3Get(L3,'lum type'); end

%%
% Check if a figure is needed
f = vcNewGraphWin;
set(f,'name',sprintf('%s filters',plotType));

nColors = L3Get(L3,'n ideal filters');
sz      = L3Get(L3,'blocksize'); r = sz(1); c = sz(2);
 
plotType = ieParamFormat(plotType);

%%
switch plotType

    case {'meanfilter'}
        % Mean filter for patch type
        nColors = L3Get(L3,'n design filters');
        filters = L3Get(L3,'mean filter',patchType);
        for ii=1:nColors
            subplot(1,nColors,ii)
            imagesc(reshape(filters(ii,:),r,c)), 
            axis image; colormap(gray)
        end

    case {'globalfilter','flatfilter','texturefilter'}
        if strcmp(plotType,'texturefilter')
            if ieNotDefined('textureType'), error('Texture tree depth required'); end
            filters = L3Get(L3,plotType,patchType,lumType, satType, textureType);
        else            
            filters = L3Get(L3,plotType,patchType,lumType,satType);
        end
        
        for ii=1:nColors
            subplot(1,nColors,ii)
            imagesc(reshape(filters(ii,:),r,c)), axis image
            colormap(gray)
        end        
        
    case {'luminancefilter'}
        % Luminance filter for patch type
        filters = L3Get(L3,'luminance filter',patchType);
        imagesc(reshape(filters,r,c)),
        axis image; colormap(gray)
        
    otherwise
        error('Unknown filter type %s\n',showType);
end

uData.filters = filters;
uData.sz = [r,c];
uData.nColors = nColors;

return

%% End
