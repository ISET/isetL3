function kernels = interpolateKernels(l3t, cutPoints, weights, override, varargin)
% Interpolate kernels to grid
%   l3t = interpolateKernels(l3t, cutPoints, weights)
%
% Inputs:
%   l3t       - l3 training class object
%   cutPoints - new cut points to be interpolated to
%   weights   - nStatsx1 vector, indicating the weights for each stats in
%               interpolation
% Outputs:
%   l3t - l3 training class object with kernels updated. The training data
%         in its l3c property will be cleared
%
% TODO:
%   Now, we assume the distance function is linear in statistics space.
%   In the future, we would allow some arbitrary distance function as input
%
% See also:
%   l3TrainOLS.fillEmptyKernels
%
% HJ, VISTA TEAM, 2015

% Check inputs
if notDefined('cutPoints'), error('new cutPoints required'); end
if notDefined('weights'), weights = ones(length(l3t.l3c.cutPoints), 1); end
if notDefined('override'), override = true; end

% make a deep copy of l3t and inside the code, we manipulate the copied
% object. If the function get crashed/cancelled in the middle, the input
% l3t will not be changed. That is, we make this function atomic.
obj = l3t.copy();

% Fill in kernel values for classes with insufficient data
obj.fillEmptyKernels;

% set parameters
nPixelTypes = obj.l3c.nPixelTypes;
curCenter = obj.l3c.classCenters;
curD = cellfun(@length, curCenter); % current dimension

curK = cell2mat(reshape(obj.kernels, [1 1 length(obj.kernels)]));
sz = size(curK);
curK = reshape(curK, [prod(sz(1:end-1)) sz(end)]); % convert to 2D

% set new cut points to classify class
obj.l3c.cutPoints = cutPoints;
newCenter = obj.l3c.classCenters;
newD = cellfun(@length, newCenter);
newK = zeros([size(curK, 1) nPixelTypes * prod(newD)]);

% adjust centers by weights function - the larger the weights, the more
% important it is and the smaller the distance
for ii = 1:length(curCenter)
    curCenter{ii} = curCenter{ii} ./ weights(ii);
    newCenter{ii} = newCenter{ii} ./ weights(ii);
end

% remove dimension with no cut point
indx = ones(length(curCenter), 1);
for ii = 1 : length(curCenter)
    if length(curCenter{ii}) == 1
        assert(length(newCenter{ii}) == 1, ...
            'cannot interpolate for dimension with no cut point');
        indx(ii) = 0;
    end
end
curCenter = curCenter(indx>0); newCenter = newCenter(indx>0);

% Interpolate
inGrid = cell(length(curCenter), 1); outGrid = cell(length(newCenter), 1);
[inGrid{:}] = ndgrid(curCenter{:}); [outGrid{:}] = ndgrid(newCenter{:});

for pt = 1 : nPixelTypes
    for ii = 1 : size(curK, 1)
        V = reshape(curK(ii, pt:nPixelTypes:end), curD);
        Vq = interpn(inGrid{:}, V, outGrid{:}, 'spline');
        newK(ii, pt:nPixelTypes:end) = Vq(:);
    end
end

% Set interpolated kernels back to l3 training object
obj.kernels = cell(nPixelTypes * prod(newD), 1);
for ii = 1 : prod(newD) * nPixelTypes
    obj.kernels{ii} = reshape(newK(:, ii), sz(1:end-1));
end

% clear data in l3c
% here, we need to clear data manually. Using clearData will lead to
% inconsistent p_data and p_out size
obj.l3c.p_data = cell(length(obj.kernels), 1);
obj.l3c.p_out = cell(length(obj.kernels), 1);

% Now, we just need to copy back everything to l3t from object
kernels = obj.kernels;

if override
    l3t.kernels = obj.kernels;
    l3t.l3c = obj.l3c;
end

end