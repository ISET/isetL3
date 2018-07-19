function labels = patchLabelsChannel(cutPoints, s, p_type, varargin)
% Compute labels based on statistics
%
%   labels = computeLabels(obj, s, varargin)
%
% Inputs:
%   cutPoints - cell array containing cutPoints for each stats
%   s         - stats matrix, each column contains stats from one patch
%   p_type    - center pixel type of each type as a 1xN vector
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
else nc = length(unique(p_type)); end

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
% labels = sub2ind(aSize, p_type, lvl{:}); % COMMENT OUT. Origin Version
labels = [lvl{1}, p_type];
end