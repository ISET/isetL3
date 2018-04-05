function kernels = fillEmptyKernels(obj, weights, override, varargin)
% Interpolate kernels for classes with insufficient training data
%   obj = fillEmptyKernels(obj, weights, varargin)
%
% Inputs:
%   obj     - l3 training object with kernels learned and stored
%   weights - nStats by 2 matrix, storing weights for interpolation. The
%             entry (ii,1) stores weights for class with stats ii one stop
%             smaller than current class. The matrix will be normalized
%             before interpolation. Use equal weight as default
%
% Outpus:
%   kernels - kenels cell array with empty slots filled
%
% Programming Note:
%   This function only fill in kernel values for classes with insufficient
%   data and will do nothing for classes with kernels learned.
%   For interpolation, use interpolateKernels function
%
% See also:
%   l3TrainOLS.interpolateKernels
%
% HJ, VISTA TEAM, 2015

% Init and check inputs
if notDefined('weights'), weights = ones(length(obj.l3c.cutPoints), 2); end
if notDefined('override'), override = true; end

% Make a copy of object
% There are two purpose of using this copy:
%   1) With this copy, the object will be the same as its input status If
%      the program crashes or stopped by user in the middle. Otherwise, it
%      could be in some undetermined status.
%   2) The filled in the value will not be used to infer kernel values for
%      other classes. That is, the filled kernels only depend on its
%      neighbors
%
l3t = obj.copy();

% Interpolate for classes with insufficient data
for ii = 1 : length(l3t.kernels)
    % check if kernels have been learned for current class
    if ~isempty(l3t.kernels{ii}), continue; end
    w = weights; % make a copy of the weight matrix
    l3t.kernels{ii} = zeros(prod(l3t.l3c.patchSize)+1, l3t.nChannelOut);
    
    % get label range
    range = l3t.l3c.getLabelRange(ii);
    
    % find neighbor of each 
    for jj = 1 : length(l3t.l3c.cutPoints)
        % find the neigbor with smaller stats
        name = ieParamFormat(l3t.l3c.statNames{jj});
        indx = ii - l3t.l3c.nPixelTypes * ...
                prod(cellfun(@(x) length(x), l3t.l3c.cutPoints(1:jj-1))+1);
        if ~isinf(range.(name)(1)) && ~isempty(obj.kernels{indx})
            l3t.kernels{ii} = l3t.kernels{ii} + w(jj,1)*l3t.kernels{indx};
        else
            w(jj, 1) = 0;
        end
        
        % find the neighbor with larger stats
        indx = ii + l3t.l3c.nPixelTypes * ...
                prod(cellfun(@(x) length(x), l3t.l3c.cutPoints(1:jj-1))+1);
        if ~isinf(range.(name)(2)) && ~isempty(obj.kernels{indx})
            l3t.kernels{ii} = l3t.kernels{ii} + w(jj,2)*l3t.kernels{indx};
        else
            w(jj, 2) = 0;
        end
    end
    
    % normalize for the weights
    if sum(w(:)) > 0
        l3t.kernels{ii} = l3t.kernels{ii} / sum(w(:));
    else
        warning('Unable to interpolate for class %d', ii);
    end
end

% copy back to object
kernels = l3t.kernels;
if override, obj.kernels = l3t.kernels; end
    
end