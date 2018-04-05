function kernels = smoothKernels(obj, cfa, override, varargin)
% Adjust L3 kernels so that uniform scenes are rendered as uniform images
%
%  obj = smoothKernels(obj, [cfa], [override])
%
% This routine adjusts the kernels so that we are guaranteed that a uniform
% input image produces a uniform output image.
%
% This is necessary because L3 learns kernels for each pixel type
% independently. When the CFA patterns are large there can be cases where
% the learning produces an output with a nonuniform repeating pattern. The
% size of this repeating pattern matches the size of the super pixel. This
% routine adjusts the weights of the kernels in a way that eliminates that
% problem.
%
% The idea is to consider an output channel, say green.  Suppose the super
% pixel is covered by a uniform image.  We need the sum of the output
% weights for the red pixels to be the same, no matter which center pixel
% we are on.  That way, given that the input is uniform, as we shift from
% pixel-to-pixel in the super pixel the red pixels will contribute the
% same.  This is what we need to make sure that the output is uniform as we
% shift center pixels.  
%
% In this way, we need to match the sum of the kernel weights on the red
% pixels for the red output channel for each center pixel type.  Similarly
% for the green and blue pixels on the red output channel, and then keep
% going for the red/green/blue pixels on the different output channels.
% There are several combinations.
%
% The other thing to remember is that the response level is common to all
% of the pixel types, because we identify the response level as the mean of
% the patch, not the value of the center pixel itself.  If we ever get to
% that point, then this algorithm needs to change.
% 
% Inputs:
%   obj      - l3 train object, with kernels learned and stored
%   cfa      - optional, cfa pattern. Assume all pixel types are different 
%              if not given
%   override - logical, indicate whether or not to update kernels in obj
%              default is true
%
% Outputs:
%   kernels - The processed kernels
%
% HJ, VISTA TEAM, 2015

% Check inputs.  For a Bayer array, nPixelTYpes would be 4.  There are
% cameras with 25 or even 64 pixel types.
nPixelTypes = obj.l3c.nPixelTypes;
if notDefined('cfa')
    cfa_size = [sqrt(nPixelTypes) sqrt(nPixelTypes)];
    cfa = reshape(1:nPixelTypes, cfa_size);
end

if notDefined('override'), override = true; end

kernels = obj.kernels;       % kernels cell array

% Adjust weights in one group with only pixel type different.
for ii = 1 : nPixelTypes : length(kernels)
    % The fastest loop is through the pixel types (jj, below).
    
    % weights is a 3D matrix. The first dimension is center pixel type for
    % the patch (e.g., 4 types) The second is which input color channel The
    % third is which output color channel.
    % 
    % So, (1,2,1) means a center pixel 1 (red), input weights for 2
    % (green), and output color channel 1 (red).  The value that is stored
    % is the sum of the weights for the (u,v,w) condition.
    %
    weights = zeros(nPixelTypes, 1 + length(unique(cfa)), ...
        obj.nChannelOut); % plus 1 for the affine term
    toProcess = true;
    for jj = 0 : nPixelTypes-1
        % We build up the weights matrix here.
        %
        % For each of the pixel types in this luminance level and contrast
        % and saturation type.
        
        % if there is one class with no stored transform, we do not smooth
        % this group
        if isempty(kernels{ii+jj}), toProcess = false; break; end
        
        % aggregate weights of pixels of same type
        pixelType = obj.l3c.getClassCFA(ii+jj, cfa);
        weights(jj+1, 1, :) = kernels{ii+jj}(1, :);
        for c = unique(cfa)'
            k = kernels{ii+jj}(2:end, :);
            weights(jj+1, c+1, :) = sum(k(pixelType==c, :), 1);
        end
    end
    
    if ~toProcess, continue; end
    
    % Use the weight matrix to adjust the transforms
    for jj = 0 : nPixelTypes-1
        % take average of the affine terms.  Set the new affine terms to be
        % the average of the affine terms.
        kernels{ii+jj}(1, :) = mean(weights(:, 1, :));
        offset = weights(jj+1, :, :) - mean(weights);
        pixelType = obj.l3c.getClassCFA(ii+jj, cfa);
        
        % adjust the weights on the input channels. The scale is set so
        % that the condition needed for a uniform input maps to a uniform
        % output is met.  This requires that the sum of the weights be
        % equal.  When they differ, we scale the weights so that the sum
        % equals this mean.
        for c = unique(cfa)'
            k = kernels{ii+jj}(1+find(pixelType==c), :);
            k = bsxfun(@minus, k, reshape(offset(1, c+1, :), 1, []) / ...
                size(k, 1));
            kernels{ii+jj}(1+find(pixelType == c), :) = k;
        end
    end
end

% Write to obj if needed
if override, obj.kernels = kernels; end

end