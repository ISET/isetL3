function labels = patchLabels(cutPoints, s, p_type, varargin)
% Compute labels based on statistics
%
%   labels = patchLabels(cutPoints, s, p_type, varargin)
%
% Inputs:
%   cutPoints - cell array containing cutPoints (luminance levels) for each one the level stat
%   s         - a nStats x nPatch matrix, each column contains stats from a patch
%               The nStats are usually mean level and contrast.  But
%               in fact, there are stats functions defined as part of
%               the classifier.  See ???
%   p_type    - center pixel type of each patch (as a 1 x nPatch)
%
% Optional
%   varargin{1} can be number of channels (default is length(p_type))
%
% Outputs:
%   labels - labels of each patch 
%
% HJ, VISTA TEAM, 2015

% Check inputs
if notDefined('cutPoints'), error('cut points required'); end
if notDefined('s'), error('stats matrix required'); end
if notDefined('p_type'), error('pixel type is not defined'); end

% number of channels
if ~isempty(varargin), nc = varargin{1}; 
else, nc = length(unique(p_type)); end

% Compute levels of each statistics
lvl = cell(size(s, 1), 1);
for ii = 1 : size(s, 1)
    cp = [cutPoints{ii}(:)' inf];
    
    % Check less than or equal on the statistics, and find the max of all
    % the returned indices, and store that max in lvl{ii}
    [~, lvl{ii}] = max(bsxfun(@le, s(ii, :)', cp), [], 2);
end

% Number of channel types x Number of classes for each statistic
% obj.cutPoints is a cell array with dimension equal to the number of
% statistics.  We add one because if there are N cutpoints we have N+1
% classes.
aSize = [nc, cellfun(@(x) length(x), cutPoints) + 1]; 

% The class labels take the vector
%  [channel, statClasses1, statClasses2 ...]
%  centerPixelTypes, Number of Levels for each statistic.  Matlab expands
%  lvl{:} to a list of dimension values.
labels = sub2ind(aSize, p_type, lvl{:});

end