function [uData, g] = plot(obj, plotType, varargin)
% Visualize l3TrainOLS class
%
%    [uData, g] = plot(obj, pType, varargin)
%
% Inputs:
%   obj    - instance of l3TrainOLS class, with kernels stored
%   pType  - string of plot type
%
% Outputs:
%   uData - plot data
%   g     - figure handle
%
% plotTypes (example calls below):
%   'kernel image' - kernel image of one class
%   'kernel video' - one pixel type and one output channel         
%   'kernel mean'  - mean kernel for one pixel type
%   'cfa pattern'  - plot cfa pattern for one given class
%   'kernels heatmap'  - heatmap of flattened kernels for one pixel type
%   'class prediction' - predicted vs target value on training data
%                        for one class
%   'class residual'   - residue vs target value on training data for one
%                        class 
%   'class pvalue'     - p-value of coefficients of one class
%
% Examples:
%  First, train a data set
%   l3t = l3TrainOLS().train(l3DataISET());
%
%   [udata, g] = l3t.plot('kernel image', classID)
%   l3t.plot('kernel movie', pixel_type, outChannel, fps, colorMode)
%   l3t.plot('kernel mean', pixel_type) 
%   l3t.plot('class prediction', classID)
%   l3t.plot('class residual', classID)
%   l3t.plot('class p value', classID)
%
% See also:  Class properties
%
% HJ/BW, Stanford VISTA Team, 2015

% TODO - fix up the kernel video colorMode case, below

% check inputs
if ieNotDefined('plotType'), error('plot type required'); end
if isempty(obj.kernels), error('No kernels trained'); end

% make plot according to plotType
switch ieParamFormat(plotType)
    case {'kernel', 'kernelimage'}
        % show kernel image of one class
        %   [udata, g] = l3t.plot('kernel', classID, [sensor])
        %
        % If sensor is given, the kernel image is colored according to the
        % color filter array and spectral sensitivity of the sensor.
        % Otherwise, a grayscale image is generated
        %
        
        % check inputs and load parameters
        if isempty(varargin), error('class ID required'); end
        if length(varargin) > 1, sensor = varargin{2};
        else sensor = []; end
        if length(varargin) > 2, normalized = varargin{3};
        else normalized = false; end
        
        classID = varargin{1};
        patchSz = obj.l3c.patchSize;
        nOut = obj.nChannelOut;

        k = obj.kernels{classID};  % This is classID
        if isempty(k), error('kernel of that class is empty'); end
        if size(k, 1) ~= prod(patchSz)+1
            error('Data mapped to higher dimension cannot be visualized')
        end
        if normalized, k = bsxfun(@rdivide, abs(k), sum(abs(k))); end
        
        % make plots
        g = vcNewGraphWin([], 'wide');
        uData = reshape(k(2:end,:), [patchSz nOut]);
        if isempty(sensor)
            % sensor is not defined, generate a grayscale plot
            for ii = 1 : nOut
                subplot(1, nOut, ii); imagesc(uData(:,:,ii));
                if uData(:) >= 0
                    colormap('gray'); colorbar; axis off; axis equal;
                else
                    % What we really want is everything < 0 to be one color
                    % and everything > 0 to be another color.  
                    colormap('hot'); colorbar; axis off; axis equal;
                end
                str = sprintf('%s filter (class %d)', ...
                    obj.outChannelNames{ii}, classID);
                title(str)
            end
        else
            % sensor information is available, generate a colored image
            for ii = 1 : nOut
                % generate cfa color image
                cfa = sensorGet(sensor, 'pattern');
                [~, ~, mp] = sensorDetermineCFA(sensor);
                cfaImg = ind2rgb(obj.l3c.getClassCFA(classID, cfa), mp);
                
                % plot
                curK = uData(:, :, ii);
                if min(curK(:)) ~= max(curK(:))
                    curK = ieScale(curK, 0, 1);
                    img = bsxfun(@times, curK, cfaImg);
                    img = imageIncreaseImageRGBSize(img, 32);
                else
                    img = imageIncreaseImageRGBSize(cfaImg, 32);
                end
                subplot(1, nOut, ii); imshow(img);
            end
        end
    case {'kernelvideo', 'kernelmovie'}
        % make video for one pixel type and one output channel
        %   l3t.plot('kernel movie', pixel_type, outChannel, fps, [sensor])
        %
        
        % check inputs and init parameters
        if ~isempty(varargin), pType = varargin{1};
        else error('pixel type required'); end
        if length(varargin) > 1, outChannel = varargin{2};
        else error('output channel required'); end
        if length(varargin) > 2, fps = varargin{3};
        else fps = 10; end
        if length(varargin) > 3, sensor = varargin{4};
        else sensor = []; end
        
        nPixelTypes = obj.l3c.nPixelTypes;
        patchSz = obj.l3c.patchSize;
        
        % make a movie.  Maybe we should keep the figure visible?
        g = figure('Visible', 'Off');
        indx = pType : nPixelTypes : length(obj.kernels);
        
        % compute max and min of kernels
        k = cell2mat(obj.kernels(indx));
        v_max = max(k(:, outChannel));
        v_min = min(k(:, outChannel));
        
        uData(length(indx)) = struct('cdata', [], 'colormap', []);
        
        % Add user interface element here.
        nFrame = 1;
        for ii = indx
            if isempty(obj.kernels{ii})
                k = zeros(patchSz);
            else
                % The kernels also include an affine term that is not
                % shown, which is why this runs from 2:end.  The first
                % entry is the affine term.
                k = reshape(obj.kernels{ii}(2:end, outChannel), patchSz);
            end
            if isempty(sensor)
                % Gray scale
                imagesc(k); caxis([v_min, v_max]);
                colormap('gray'); colorbar; drawnow;
            else
                % Account for the CFA color properties
                k = k .* sensorImageColorArray(sensorDetermineCFA(sensor));
                k = imageIncreaseImageRGBSize(k,192);
                imagesc(k);
            end
            uData(nFrame) = getframe;
            nFrame = nFrame+1;
        end
        close(g); g = []; 
        implay(uData, fps);
        
    case {'kernelmean', 'meanfilter'}
        % plot mean kernel for one pixel type
        %   l3t.plot('kernel mean', pixel_type, [normalized])
        %
        
        % check inputs and init parameters
        if ~isempty(varargin), pType = varargin{1};
        else error('pixel type required'); end
        if length(varargin) > 1, normalized = varargin{2};
        else normalized = false; end
        
        nPixelTypes = obj.l3c.nPixelTypes;
        patchSz = obj.l3c.patchSize;
        nOut = obj.nChannelOut;
        
        % plot
        indx = pType : nPixelTypes : length(obj.kernels);
        
        g = vcNewGraphWin([], 'wide');
        mFilter = zeros([patchSz nOut]);
        for ii = indx
            if ~isempty(obj.kernels{ii})
                k = obj.kernels{ii}(2:end, :);
                if normalized
                    k = bsxfun(@rdivide, abs(k), sum(abs(k)));
                end
                mFilter = mFilter+reshape(k, [patchSz nOut]);
            end
        end
        mFilter = mFilter / length(indx);

        for ii = 1 : nOut
            subplot(1, nOut, ii); imagesc(mFilter(:, :, ii)); 
            colormap('gray'); colorbar; axis off; axis equal;
            title(['mean filter for ' obj.outChannelNames{ii}]);
        end
    case {'kernelsheatmap'}
        % plot heatmap of falttened kernels for one pixel type
        %   l3t.plot('kenerls heatmap', pixel_type);
        %
        
        % check inputs
        if isempty(varargin), error('pixel type required'); end
        pType = varargin{1};
        indx = pType : obj.l3c.nPixelTypes : length(obj.kernels);
        g = vcNewGraphWin([], 'wide'); uData = [];
        
        % plot for each channel
        nOut = obj.nChannelOut;
        k = cell2mat(obj.kernels(indx)')';
        for ii = 1 : nOut
            subplot(1, nOut, ii);
            imagesc(k(ii:nOut:end, :)); colormap(hot);
            axis off; axis equal;
        end
    case {'kernelsmesh'}
        % plot heatmap of falttened kernels for one pixel type
        %   l3t.plot('kenerls mesh', pixel_type);
        %
        
        % check inputs
        if isempty(varargin), error('pixel type required'); end
        pType = varargin{1};
        indx = pType : obj.l3c.nPixelTypes : length(obj.kernels);
        g = vcNewGraphWin([], 'wide'); uData = [];
        
        % plot for each channel
        nOut = obj.nChannelOut;
        k = cell2mat(obj.kernels(indx)')';
        for ii = 1 : nOut
            subplot(1, nOut, ii);
            surf(k(ii:nOut:end, :)); colormap(hot);
        end
        
    case {'classprediction'}
        % plot predicted vs target value on training data for one class
        %   l3t.plot('class prediction', classID)
        %
        
        % check inputs and init parameters
        if isempty(varargin), error('class id required'); end
        [X, y] = obj.l3c.getClassData(varargin{1});
        if isempty(y), error('no data in class'); end
        X = padarray(X, [0 1], 1, 'pre');
        
        k = obj.kernels{varargin{1}};
        
        % plot
        g = vcNewGraphWin([], 'wide');
        uData = X * squeeze(k);
        nOut = size(obj.kernels, 2);
        for ii = 1 : nOut
            subplot(1, nOut, ii);
            plot(y(:, ii), uData(:, ii), '.'); identityLine;
            xlabel('Target Value'); ylabel('Predicted Value');
            title([obj.outChannelNames{ii} 'Channel']);
        end
        
    case {'classresidual'}
        % plot the residue vs target value on training data for one class
        %   l3t.plot('class residual', classID)
        %
        
        % check inputs and init parameters
        if isempty(varargin), error('class id required'); end
        [X, y] = obj.l3c.getClassData(varargin{1});
        if isempty(y), error('no data in class'); end
        X = padarray(X, [0 1], 1, 'pre');
        
        k = obj.kernels{varargin{1}};
        
        % plot
        % g = vcNewGraphWin([], 'wide');
        uData = y - X * squeeze(k);
        for ii = 1 : obj.nChannelOut
            % subplot(1, obj.nChannelOut, ii);
            % ieHistImage([y(:,ii),uData(:,ii)],true,g);
            ieHistImage([y(:,ii),uData(:,ii)]);
            xlabel('Target Value'); ylabel('Residual error');
            title([obj.outChannelNames{ii} 'Channel']);
        end
    case {'classpvalue', 'pvalue', 'pval'}
        % plot the p-value of coefficients of one class
        %   l3t.plot('class p value', classID)
        if isempty(varargin), error('class id required'); end
        [X, y] = obj.l3c.getClassData(varargin{1});
        if isempty(y), error('no data in class'); end
        X = padarray(X, [0 1], 1, 'pre');
        patchSz = obj.l3c.patchSize;
        
        % plot
        g = vcNewGraphWin([], 'wide');
        [~, uData] = obj.learnClassKernel(X, y);
        for ii = 1 : obj.nChannelOut
            subplot(1, obj.nChannelOut, ii);
            imagesc(reshape(uData(2:end, ii), patchSz));
            colormap('gray'); colorbar;
            title(['p-val for ' obj.outChannelNames{ii}]);
        end
    case {'cfa', 'cfapattern'}
        % plot the cfa pattern for a given class
        %   l3t.plot('cfa pattern', classID, sensor);
        if isempty(varargin), error('class id required'); end
        if length(varargin) < 2, error('sensor required'); end
        sensor = varargin{2};
        cfa = sensorGet(sensor, 'cfa pattern');
        
        [~, ~, mp] = sensorDetermineCFA(sensor);
        cfaImg = ind2rgb(obj.l3c.getClassCFA(varargin{1}, cfa), mp);
        
        uData = imageIncreaseImageRGBSize(cfaImg, 32);
        g = vcNewGraphWin; imshow(uData);
    otherwise
        error('Unknown plot type');
end
