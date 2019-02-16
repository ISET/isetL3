classdef l3ClassifySR < l3ClassifyS
    % l3ClassifySR Class
    % The class holds the L3 classification especially for the super
    % resolution application. 
    %
    % The class defines the local linear regions by segmenting local patch
    % mean, contrast and saturation types (although not sure if the
    % contrast and saturation type are working now, but will make sure them
    % eventually functional).
    %
    % ZL/BW, 2019
    
    properties (Access = public)
        cutPoints@cell;             % cell array of cut points for stats
        statFunc@cell;              % cell of functions for stats computing
        statFuncParam@cell;         % additional parameters for statFunc
        statNames@cell;             % cell array of statistics names
        verbose@logical scalar;     % print progress information or not
        storeData@logical scalar;   % whether or not to store p_data
        dataKernel@function_handle; % data kernel function
        
        p_data;                     % patch data
        p_out;                      % patch target output 
        
        satThreshold                % saturation porpotion of voltage swing
    end
    
    properties (Dependent)
        nChannelOut  % number of output channels
        nLabels      % number of classes
        nPixelTypes  % number of different pixel types
        classCenters % center for each class
    end
    
    % public methods
    methods (Access = public)
        
        function obj = l3ClassifySR(varargin)
            % l3Classify constructor
            %   l3ClassifySR([l3d], varargin)
            %
            % Inputs:
            %   l3d - l3DataS class instance
            %   varargin - key value pairs of parameters, including
            %     {'name'}       - str, name of the instance
            %     {'pmax'}       - int, max number of patches per class
            %     {'verbose'}    - bool, whether in verbose mode
            %     {'cutPoints'}  - cell, cut points for statistics
            %     {'patchSize'}  - [row, col] of each patch
            %     {'dataKernel'} - function handle of data mapping kernel
            %
            
            % Setup input parser
            p = inputParser;
            
            % Set the l3Data class if existed
            p.addOptional('l3d', [], @(x) assert(isa(x, 'l3DataS'), ...
                'l3d must be of class l3DataS'));
            
            
            vFunc = @(x) validateattributes(x, {'char'}, {'nonempty'});
            p.addParameter('name', 'l3ClassifySR instance', vFunc);
            
            % Set the max number of patches per class
            vFunc = @(x) assert(isnumeric(x) && isscalar(x) ...
                && (x > 0), 'p_max must be positive integers');
            p.addParameter('pmax', 1e5, vFunc);
            
            % Set the verbose (true/false)
            p.addParameter('verbose', true);
            
            % Set the patch size
            vFunc = @(x) assert(isvector(x) && numel(x) == 2, ...
                'patchSize must be 2-element array');
            p.addParameter('patchSize', [5 5], vFunc);  
            
            % Set the cut point
            val = {logspace(-3.2, -1.2, 20), [], [1:15]};
            vFunc = @(x) assert(iscell(x), 'cutPoints must be cell array');
            p.addParameter('cutPoints', val, vFunc);
            
            % Set the stat names
            val = {'Luminance', 'Contrast', 'Saturation condition'};
            vFunc = @(x) assert(iscell(x), 'statNames must be cell array');
            p.addParameter('statNames', val, vFunc);
            
            % Set the stat function
            val = {@imagePatchMean, @imagePatchContrast, @imagePatchSaturation};
            p.addParameter('statFunc', val);
            
            % Set the additional stat function parameter
            val = {{}, {}, {}};
            p.addParameter('statFuncParam', val);
            
            % Set the flag indicating store data or not
            p.addParameter('storeData', true);
            
            
            % Set the function operated on the data
            val = @(x) x; % Identity function
            p.addParameter('dataKernel', val);
            
            p.addParameter('satClassOption', 'none');
            
            p.addParameter('satThreshold', 0.95);
            
            % Parse inputs
            p.parse(varargin{:});
            
            % Set object fields
            obj.name = p.Results.name;
            obj.patchSize = p.Results.patchSize;
            obj.p_max = p.Results.pmax;
            obj.verbose = logical(p.Results.verbose);
            obj.cutPoints = p.Results.cutPoints;
            obj.statNames = p.Results.statNames;
            obj.statFunc = p.Results.statFunc;
            obj.statFuncParam = p.Results.statFuncParam;
            obj.storeData = p.Results.storeData;
            obj.dataKernel = p.Results.dataKernel;
            obj.satClassOption = p.Results.satClassOption;
            obj.satThreshold = p.Results.satThreshold;
            
            % if data class is provided, do classification
            if ~isempty(p.Results.l3d), obj.classify(p.Results.l3d); end
        end
        
        function labels = classify(obj, l3d, isNew, varargin)
            % Classify patches into different local linear groups.
            %
            %   labels = classify(obj, l3d, isNew, varargin)
            % Inputs:
            %   l3d     - Instance of l3 data class(l3DataS)
            %   isNew   - bool, whether to add existing classify object
            % 
            % Outputs:
            %   labels  - labels for input data
            % 
            % Fields update to the object:
            %   obj.p_data  - patch raw data of each class
            %   obj.p_indx  - patch index of each class
            %   obj.p_out   - target patch output for each class
            % General process
            %   1) For each input image, compute statistics, for example,
            %      channel mean, patch mean voltage, patch contrast, patch
            %      saturation map, etc.
            %   2) Create label maps using the computed statistics
            % 
            % Example:
            %   TBD
            % ZL/BW, VISTA TEAM, 2019
            
            % Check inputs are properly given
            if notDefined('l3d'), error('data class required'); end
            if notDefined('isNew'), isNew = false; end
            assert(isa(l3d, 'l3DataS'), 'l3d should be of class l3DataS');
            
            % Get data
            [raw, tgt, pType] = l3d.dataGet(varargin{:})
            %{
                thisImg = 1;
                vcNewGraphWin; imshow(raw{thisImg});
                vcNewGraphWin; imshow(xyz2srgb(tgt{thisImg}));
            %}
            % Set the cfa pattern
            cfa = l3d.cfa;
            
            % Get the upscale factor
            upscaleFactor = l3d.upscaleFactor;
            
            % Check the raw and target data size
            nImg = length(raw);
            padSzRaw = (obj.patchSize-1)/2;
            padSzTgt = padSzRaw * upscaleFactor;
            if ~isempty(tgt)
                for ii = 1 : nImg
                    target_sz = [size(tgt{ii}, 1), size(tgt{ii}, 2)];
                    
                    if all(size(raw{ii}) * upscaleFactor == target_sz)
                        % crop target image
                        tgt{ii} = tgt{ii}(padSzTgt(1)+1:end-padSzTgt(1), ...
                                     padSzTgt(2)+1:end-padSzTgt(2), :);
                    end
                end
            end
            
            % Print the information
            if obj.verbose
                cprintf('*Keywords', 'Classifying Patches:\n');
            end
            
            % allocate spaces
            labels = cell(nImg, 1);
            nc = numel(cfa); % number of channels
            
            % The defination of the n_lvls: it contains several average 
            % signal levels S for sure. And for each signal levels S(i), it
            % will have subclasses with the number of 2^nc. 
            % That means we will give saturated classes for cutPoints
            % and an additional one without any saturated pixels.
            
            % n_lvls = computeLvlNumbers(obj.cutPoints, nc);
            n_lvls = nc * prod(cellfun(@(x) length(x), obj.cutPoints) + 1);
            
            % allocate spaces for the p_center
            if isNew || isempty(obj.p_data)
                obj.p_data = cell(n_lvls, 1);
                obj.p_out = cell(n_lvls, 1);
            end
            
            % Set the pixel saturation threshold
            obj.statFuncParam{3} = {obj.satThreshold * cameraGet(l3d.camera,...
                                                    'sensor voltage swing')};
            
            % Loop for each image
            for ii = 1:nImg
                if obj.verbose
                    fprintf('  Processing Image %d/%d\n', ii, nImg);
                    fprintf('\tComputing Statistics...');
                end
                
                % Compute the statistics
                stat = [];
                for jj = 1 : length(obj.statFunc)
                    stat = cat(1, stat, obj.statFunc{jj}(raw{ii}, ...
                         cfa, obj.patchSize, obj.statFuncParam{jj}{:}));
                end
                
                if obj.verbose
                    fprintf('Done\n\tComputing label levels...');
                end
                
                % Compute labels
                %
                % Some comments here.
                pTypeC = pType{ii}(padSzRaw(1)+1:end-padSzRaw(1), ...
                                   padSzRaw(2)+1:end-padSzRaw(2));
                % ALWAYS remember: curLabel is labeled as column -> row
                curLabel = patchLabels(obj.cutPoints, stat, pTypeC(:),...
                                        nc, obj.satClassOption);
                                    
                 % compute overall label values
                labels{ii} = reshape(curLabel,size(pType{ii})-obj.patchSize+1);               
                
                if obj.verbose, fprintf('Done\n'); end
                
                % store patches according to labels
                if ~obj.storeData, return; end
                if obj.verbose, fprintf('\tRe-organizing patches: '); end
            
                % Group data by labels
                % For the unique labels, group the patch data that have the
                % same label into a class. We will solve the kernels with
                % the rawdata from each class
                labelValue = unique(curLabel);
                for jj = 1 : length(labelValue)
                    if obj.verbose
                        str = sprintf('%d/%d', jj, length(labelValue));
                        fprintf(str);
                    end
                    
                    % Shorten the name
                    lv = labelValue(jj);
                    
                    % Find the indices with that label value
                    indx = find(curLabel == lv);
                    
                    if isempty(indx), continue; end
                    
                    % Get patch data of current class
                    pData = imagePatchData(raw{ii}, indx, obj.patchSize);
                    pData = obj.dataKernel(pData);
                    
                    % For each image, we allow obj.p_max/nImg patches
                    if size(pData, 2) <= round(obj.p_max / nImg)
                        indx_d = 1 : size(pData, 2);
                        obj.p_data{lv} = [obj.p_data{lv} pData];
                    else
                        indx_d = randperm(size(pData,2), round(obj.p_max/nImg));
                        obj.p_data{lv} = [obj.p_data{lv} pData(:,indx_d)];
                    end
                    
                    % If we have target output, add data to obj.p_out
                    if ~isempty(tgt)
                        tData = imagePatchTgt(tgt{ii}, l3d.upscaleFactor); 
                        tData = tData(indx, :)';
                        obj.p_out{lv} = [obj.p_out{lv} tData(:, indx_d)];
                    end
                    
                    if obj.verbose
                        fprintf(repmat('\b', 1, length(str)));
                    end
                end
                if obj.verbose, fprintf('Done\n'); end
                
            end
        end

        function obj = clearData(obj, varargin)
            % clear data from the object
            obj.p_data = cell(length(obj.p_data), 1);
            obj.p_out = cell(length(obj.p_data), 1);
        end
        
        function [p_in, p_out] = getClassData(obj, label, varargin)
            % get patch data for certain class
            if isempty(obj.p_data), error('No data stored in object'); end
            p_in  = obj.p_data{label}';
            p_out = obj.p_out{label}';
        end
        
        function [c_data, c_grndTruth] = concatenateClassData(obj, varargin)
        end
    end
    
    % MIGHT NEED TO CHANGE
    methods
        % get /set methods for dependent variables
        function val = get.nChannelOut(obj)
            % number of output channels
            val = nan;
            for ii = 1 : length(obj.p_out)
                if ~isempty(obj.p_out{ii})
                    val = size(obj.p_out{ii}, 1);
                    return
                end
            end
        end
        
        function val = get.classCenters(obj)
            % compute class centers from cutPoints
            %
            % Note:
            %   1) Now we just compute center as mean of the two end-point
            %      of the class. In the future, we might change it as the
            %      mean of the patch statistics of the training data
            %   2) Because we don't know the min and max for each
            %      statistics, we set them to be the cut point values plus
            %      / minus a small constant
            %
            val = cellfun(@(x) (x(1:end-1)+x(2:end))/2, obj.cutPoints, ...
                'UniformOutput', false);
            
            % extrapolate for leftmost and rightmost class
            for ii = 1 : length(val)
                if isempty(obj.cutPoints{ii})
                    val{ii} = 0;
                elseif isempty(val{ii})
                    val{ii} = [obj.cutPoints{ii}/2 obj.cutPoints{ii}*3/2];
                else
                    if obj.cutPoints{ii}(1) > 0
                        % All cut point are positive
                        % choose left as the mean of 0 and first cut point
                        left = obj.cutPoints{ii}(1)/2;
                    else
                        % first cut point is negative
                        % choose left as 2*first cut point
                        left = obj.cutPoints{ii}(end) * 2;
                    end
                    
                    if obj.cutPoints{ii}(end) > 0
                        % last cut point is positive
                        % choose right as 2*last cut point
                        right = 2 * obj.cutPoints{ii}(end);
                    else
                        % all cut points are negative
                        % choose right as mean of 0 and last cut point
                        right = obj.cutPoints{ii}(end) / 2;
                    end
                    val{ii} = [left val{ii} right];
                end
            end
        end
        
        function val = get.nLabels(obj)
            val = nan;
            if ~isempty(obj.p_data), val = length(obj.p_data); end
        end
        
        function val = get.nPixelTypes(obj)
            % number of different pixel types
            val = obj.nLabels / prod(cellfun(@(x) length(x), ...
                            obj.cutPoints) + 1);
        end
    end
    
    methods (Access = private)
        % private methods
        labels = computeLabels(obj, s, varargin)
    end
end