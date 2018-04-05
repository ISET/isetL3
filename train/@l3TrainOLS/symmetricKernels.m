function kernels = symmetricKernels(obj, cfa, override, varargin)
% Make the L3 learned kernels symmetric about the center
%
%  obj = symmetricKernels(obj, [cfa], [override])
%
% The CFA pattern around the kernel is checked for up/down and right/left
% symmetry.  The kernel is made  up/down or right/left symmetric if the CFA
% is symmetric in that dimension.
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

% Check inputs
if notDefined('cfa')
    cfa_size = [sqrt(obj.l3c.nPixelTypes) sqrt(obj.l3c.nPixelTypes)];
    cfa = reshape(1:obj.l3c.nPixelTypes, cfa_size);
end
if notDefined('override'), override = true; end

kernels = obj.kernels;       % kernels cell array
patchSz = obj.l3c.patchSize; % patch size

% Make kernel symmetric up/down (left/right) symmetric if the CFA pattern
% is up/down (left/right) symmetric 
for ii = 1 : length(kernels)
    if isempty(kernels{ii}), continue; end
    pixelType = obj.l3c.getClassCFA(ii, cfa);
    
    % check if pixel pattern is up-down symmetric around center
    k = reshape(kernels{ii}(2:end, :), [patchSz obj.nChannelOut]);
    if all(all(pixelType == flipud(pixelType)))
        % Older versions of Matlab need this loop.  More modern versions
        % will flip the 3D object like this.
        for jj = 1:size(k,3)
            k(:,:,jj) = (k(:,:,jj) + flipud(k(:,:,jj)))/2;
        end
        kernels{ii}(2:end, :) = RGB2XWFormat(k);
    end
    
    % check if pixel pattern is left-right symmetric around center
    if all(all(pixelType == fliplr(pixelType)))
        for jj = 1:size(k,3)
            k(:,:,jj) = (k(:,:,jj) + fliplr(k(:,:,jj)))/2;
        end
        kernels{ii}(2:end, :) = RGB2XWFormat(k);
    end
end

% Write to obj if needed
if override, obj.kernels = kernels; end
