function [newCP, str] = inspectCutPoints(obj, verbose, varargin)
% Find unused cut points from l3 training object
%   [obj, str] = inspectCutPoints(obj, [verbose])
%
% In l3 training object, some specified cut points for statistics could be
% infeasible. For example, if we have extremely large cut point on the
% luminance channel, the pixels could first saturate and can never reach
% that class.
%
% This function help detect if these situation exist and report those
% unreasonable cut points
%
% Inputs:
%   obj     - l3 training object with kernels learned and stored
%   verbose - logical, whether or not to print inspect informations
%
% Outputs:
%   newCP - suggested cut points to be used
%   str   - descriptive string, containing what to be done to cut points
%
% HJ, VISTA TEAM, 2015

% Init parameters
if notDefined('verbose'), verbose = obj.verbose; end
cutPoints = obj.l3c.cutPoints;
newCP = cutPoints;
str = '';

% Check cut points for every statistics
for ii = 1 : length(cutPoints)
    name = obj.l3c.statNames{ii};
    nRemoved = 0;  % number of cut points to be removed
    for jj = 1 : length(cutPoints{ii})
        % check if all kernels for cutPoints{ii}(jj-1) to jj are empty
        thresh = cutPoints{ii}(jj);
        labels = obj.l3c.query(name, [thresh-2*eps thresh-eps]);
        if all(cellfun(@isempty, obj.kernels(labels)))
            % thresh can be removed
            str = sprintf('%sRemove %s cut point %f\n', str, name, thresh);
            
            % remove thresh point
            newCP{ii}(jj-nRemoved) = [];
            nRemoved = nRemoved + 1;
        end
    end
    
    % we also need to inspect from the last cut point to infinity
    if ~isempty(newCP{ii}) && ~isempty(cutPoints{ii}) && ...
            newCP{ii}(end) == cutPoints{ii}(end)
        labels = obj.l3c.query(name, [thresh+eps thresh+2*eps]);
        if all(cellfun(@isempty, obj.kernels(labels)))
            % thresh can be removed
            str = sprintf('%sRemove %s cut point %f\n', str, name, thresh);
            newCP{ii}(end) = [];
        end
    end
end

% print info if needed
if verbose, fprintf(str); end

end