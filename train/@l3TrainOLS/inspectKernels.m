function [R2, pVal, str] = inspectKernels(obj, verbose, varargin)
% Inspect the quality of the l3 kernels
%   str = inspectKernels(obj, [verbose])
%
% In this function, we check the R^2 value for each class. If the R^2 value
% is significantly lower than other classes, we suggest to divide that
% class.
%
% Inputs:
%   obj     - l3 train obj with kernels and training data stored
%   verbose - logical, indicating whether to print inspect log
%
% Outputs:
%   R2   - R^2 (not adjusted R2) for each class channel
%   pVal - p value of hypothesis test that the kernel of current class is
%          the same as its neighboring class
%   str - inspection log
%
% HJ, VISTA TEAM, 2015

% Init parameters
if notDefined('verbose'), verbose = obj.verbose; end

% Compute R^2 for each class
R2 = zeros(length(obj.kernels), obj.nChannelOut);
for ii = 1 : length(obj.kernels)
    if isempty(obj.kernels{ii}), continue; end
    
    % get training data for that class
    [X, y] = obj.l3c.getClassData(ii);
    X = padarray(X, [0 1], 1, 'pre');
    
    % compute R^2
    R2(ii, :) = 1 - sum((y-X*obj.kernels{ii}).^2) ./ ...
        sum(bsxfun(@minus, y, mean(y)).^2);
end

% Check if there is some classes whose R2 values are significantly lower
% than others (NYI). Not sure if this checking makes sense (HJ)
R2_mean = sum(R2) ./ sum(R2>0);
R2_sd = sqrt((sum(R2.^2)-sum(R2)./sum(R2>0))./sum(R2>0));
str = sprintf('R2 mean: %f Standard Deviation: %f\n', R2_mean, R2_sd);

if verbose, fprintf(str); end
if nargout < 2, return; end

% Compute p value for hypothesis test that the kernel for current class is
% the same as its neighboring class. The neighboring class is defined as
% class with one step larger in one statistics
pVal = zeros(obj.l3c.nLabels, length(obj.l3c.cutPoints), obj.nChannelOut);
for ii = 1 : obj.l3c.nLabels
    % check if we have data in this class
    if isempty(obj.kernels{ii}), continue; end
    curK = obj.kernels{ii};
    
    % compute residue vector
    [X, y] = obj.l3c.getClassData(ii);
    X = padarray(X, [0 1], 1, 'pre');
    residue = y - X*curK;
    
    % compute mean and covariance matrix of current kernel
    for channel = 1 : obj.nChannelOut
        % Programming note: computing cdf for multidimensional Gaussian
        % with non diagnoal covariance matrix is not trival. At this point,
        % MATLAB (2015b) only supports up to 25 dimensions, which is not
        % enough for our case. Here, we assume that the covariance matrix
        % is diagnal, which is roughly true empirically.
        se = sqrt(diag(inv(X'*X)) * var(residue(:, channel)));
        
        % find neighboring class and compute p-val
        for jj = 1 : length(obj.l3c.cutPoints)
            neighbor = ii + obj.l3c.nPixelTypes * ...
                prod(cellfun(@(x) length(x), obj.l3c.cutPoints(1:jj-1))+1);
            if neighbor > obj.l3c.nLabels, break; end
            if isempty(obj.kernels{neighbor}), continue; end
            neiK = obj.kernels{neighbor};
            dist = abs(neiK(:,channel)-curK(:,channel));
            pVal(ii, jj, channel) = prod(2*qfunc(dist ./ se));
        end
    end
    

end

end