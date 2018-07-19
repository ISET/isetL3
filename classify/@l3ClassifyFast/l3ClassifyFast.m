classdef l3ClassifyFast < l3ClassifyS
    % l3ClassifyFast Class
    %
    % This class holds the L3 classification process used for the training
    % and rendering processes.
    %
    % This class defines the local linear regions by segmenting local patch
    % mean, contrast and saturation type.
    %
    % HJ/QT/BW, Stanford VISTA Team, 2015
    
    % public properties
    % contains parameters for doing the classification
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
        
        p_center;                   % (r, c) for each patch 
    end
    
    properties (Dependent)
        nChannelOut  % number of output channels
        nLabels      % number of classes
        nPixelTypes  % number of different pixel types
        classCenters % center for each class
    end
    
    % public methods
    methods (Access = public)
        
        function obj = l3ClassifyFast(varargin)
            % l3Classify constructor
            %   l3ClassifyTree([l3d], varargin)
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
            p.addOptional('l3d', [], @(x) assert(isa(x, 'l3DataS'), ...
                'l3d must be of class l3DataS'));
            
            vFunc = @(x) validateattributes(x, {'char'}, {'nonempty'});
            p.addParameter('name', 'l3ClassifyFast instance', vFunc);
            
            vFunc = @(x) assert(isnumeric(x) && isscalar(x) ...
                && (x > 0), 'p_max must be positive integers');
            p.addParameter('pmax', 1e5, vFunc);
            
            p.addParameter('verbose', true);
            
            vFunc = @(x) assert(isvector(x) && numel(x) == 2, ...
                'patchSize must be 2-element array');
            p.addParameter('patchSize', [5 5], vFunc);
            
            val = {logspace(-3.2, -1.2, 20), []};
            vFunc = @(x) assert(iscell(x), 'cutPoints must be cell array');
            p.addParameter('cutPoints', val, vFunc);
            
            val = {'Luminance', 'Contrast'};
            vFunc = @(x) assert(iscell(x), 'statNames must be cell array');
            p.addParameter('statNames', val, vFunc);
            
            val = {@imagePatchMean, @imagePatchContrast};
            p.addParameter('statFunc', val);
            
            val = {{}, {}};
            p.addParameter('statFuncParam', val);
            p.addParameter('storeData', true);

            val = @(x) x; % Identity function
            p.addParameter('dataKernel', val);
            
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

            % if data class is provided, do classification
            if ~isempty(p.Results.l3d), obj.classify(p.Results.l3d); end
        end
        
        function labels = classify(obj, l3d, isNew, varargin)
            % Classify patches into different local linear groups
            % 
            %   labels = classify(obj, l3d, isNew, varargin)
            %
            % Inputs:
            %   l3d   - instance of l3 data calss (l3DataS)
            %   isNew - bool, whether to add to existing classify object
            %
            % Outputs:
            %   labels - labels for input data
            %
            % Fields update to object:
            %   obj.p_data - patch data of each class
            %   obj.p_indx - patch index of each class
            %   obj.p_out  - target patch output for each class
            %
            % General process
            %   1) For each input image, compute stastics, for example
            %      channel mean, patch mean voltage, patch contrast, patch
            %      saturation map, etc.
            %
            %   2) Create label maps using the computed statistics
            %
            % Example:
            %   t_l3Object_Stats
            %
            % HJ, VISTA TEAM, 2015
            
            % Check inputs and get the raw data and pType
            if notDefined('l3d'), error('data class required'); end
            if notDefined('isNew'), isNew = false; end
            assert(isa(l3d, 'l3DataS'), 'l3d should be of class l3DataS');
            
            % Get data
            [raw, tgt, pType] = l3d.dataGet(varargin{:});
            cfa = l3d.cfa;
            
            % check raw and target data size
            nImg  = length(raw); % number of images
            padSz = (obj.patchSize-1)/2;
            if ~isempty(tgt)
                for ii = 1 : nImg
                    target_sz = [size(tgt{ii}, 1) size(tgt{ii}, 2)];
                    if all(size(raw{ii}) == target_sz)
                        % crop target image
                        tgt{ii} = tgt{ii}(padSz(1)+1:end-padSz(1), ...
                                      padSz(2)+1:end-padSz(2), :);
                    end
                end
            end
            
            if obj.verbose
                cprintf('*Keywords', 'Classifying Patches:\n');
            end
            
            % allocate spaces
            labels = cell(nImg, 1);
            nc = numel(cfa); % number of channels
            n_lvls = nc * prod(cellfun(@(x) length(x), obj.cutPoints) + 1);
            
            % allocate spaces for the p_center
            if isNew || isempty(obj.p_data)
                obj.p_data = cell(n_lvls, 1);
                obj.p_out  = cell(n_lvls, 1);
            end
            
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
                % levels for mean and contrast as a column vector
                % We see whether the mean/cont is less than each entry in
                % the list of levels and contrast. Then we find the
                % largest index that the mean is less than and store it.
                pdSz = (obj.patchSize-1)/2;
                pTypeC = pType(pdSz(1)+1:end-pdSz(1), ...
                               pdSz(2)+1:end-pdSz(2));
                curLabel = patchLabels(obj.cutPoints, stat, pTypeC(:), nc);
                
                % compute overall label values
                labels{ii} = reshape(curLabel,size(pType)-obj.patchSize+1);
                
                if obj.verbose, fprintf('Done\n'); end
                
                % store patches according to labels
                if ~obj.storeData, return; end
                if obj.verbose, fprintf('\tRe-organizing patches: '); end
                
                % Group data by labels
                % For the unique labels, group the patch data that have the
                % same label into a class.  We will solve the kernels with
                % the rawdata from each class.
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
                    d = imagePatchData(raw{ii}, indx, obj.patchSize);
                    d = obj.dataKernel(d);
                    
                    % For each image, we allow obj.p_max/nImg patches
                    if size(d, 2) <= round(obj.p_max / nImg)
                        indx_d = 1 : size(d, 2);
                        obj.p_data{lv} = [obj.p_data{lv} d];
                    else
                        indx_d = randperm(size(d,2),round(obj.p_max/nImg));
                        obj.p_data{lv} = [obj.p_data{lv} d(:,indx_d)];
                    end
                    
                    % If we have target output, add data to obj.p_out
                    if ~isempty(tgt)
                        tgtD = RGB2XWFormat(tgt{ii});
                        tgtD = tgtD(indx, :)';
                        obj.p_out{lv} = [obj.p_out{lv} tgtD(:, indx_d)];
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
        
        function [c_data, c_grndTruth] = concatenateClassData(obj, cfa, varargin)
            % This function is used to concatenate different classes. Two
            % types of inputs are allowed for now: a)an array of indeces of
            % the classes that we want to concatenate and b) a certain
            % type of pixel (channel).
            
            assert(~isempty(varargin), 'Must give the index or the channel.');
            assert(length(varargin) == 1, 'Make sure give only index OR channel.');
            
            if isnumeric(varargin{1})
                idx = varargin{1};
                assert(max(idx) <= obj.nLabels, 'Index exceeds number of classes.');
                assert(min(idx) >= 1, 'Index should be equal or larger than 1.');
                       
            elseif ischar(varargin{1})
                channel = ieParamFormat(varargin{1});
                assert(length(channel) == 1, 'Please give only one channel');
                assert(channel == 'r' || channel == 'g' || channel == 'b' ||...
                        channel == 'w', 'Channels must be R, G, B, or W.');
                dictChannel = ['r', 'g', 'b', 'w'];
                pixType = find(dictChannel == channel);
                cfaChannel = find(cfa == pixType);
                idx = [];
                
                for ii = 1 : numel(cfaChannel)
                    idx = cat(1, idx, [cfaChannel(ii) : obj.nPixelTypes : length(obj.p_data)]);
                end
                idx = sort(idx);
            else
                error('Please enter indices(array) or a channel');
            end
            
            c_data = cell(size(idx, 1), 1); c_grndTruth = cell(size(idx, 1), 1);
            for ii = 1 : size(idx, 1)
                cur_data = []; cur_grndTruth = [];
                fprintf('Merging current channel: %c...\n', channel);
                for jj = 1 : size(idx, 2)
                    fprintf('Merging current class: %i... ', idx(ii, jj));
                    [X, y] = obj.getClassData(idx(ii, jj));
                    cur_data = cat(1, cur_data, X);
                    cur_grndTruth = cat(1, cur_grndTruth, y);
                    fprintf('Done.\n');
                end
                c_data{ii} = cur_data;
                c_grndTruth{ii} = cur_grndTruth;
            end
        end
        
        function labels = query(obj, varargin)
            % find classes that satisfy certain contraints
            %   labels = query(obj, [name-value pairs]);
            % 
            % Inputs:
            %   varargin - specify constraints with name-value pairs
            %      'pixelType'   - scalar or range, type of center pixel
            %      'label'       - 1x2 vector, the range for class ID
            %     ('statsName')  - 1x2 vector, the range for that stats
            %      'fHandle'     - function handle to be applied to judge
            %                      every class. function handle should
            %                      return only true or false
            % 
            % Outputs:
            %   labels - labels of classes that satisfy the specified
            %            criteria
            %
            % Notes:
            %   1) If no criterion is specified, all labels will be
            %      returned
            %   2) Might use Matlab table in the future. And by then, this
            %      function could be less useful
            %
            % See also:
            %   l3ClassifyFast.getlabelRange
            %
            % HJ, VISTA TEAM, 2015
            
            % check inputs
            assert(mod(length(varargin),2)==0, 'input must be in paris');
            
            % init labels
            labels = 1 : obj.nLabels;
            
            % get range for each label
            range = obj.getLabelRange(labels);
            
            % select labels 
            for ii = 1 : 2 : length(varargin)
                fn = ieParamFormat(varargin{ii}); % field name
                switch fn
                    case 'fhandle'
                        hf = varargin{ii+1};
                    case {'pixeltype', 'label'}
                        val = varargin{ii+1};
                        if isscalar(val), val = repmat(val, [1 2]); end
                        hf = @(x) x.(fn)>=val(1) & x.(fn)<=val(2);
                    otherwise
                        val = varargin{ii+1};
                        hf = @(x) x.(fn)(1)<=val(2) & x.(fn)(2)>=val(1);
                end
                indx = arrayfun(hf, range);
                labels = labels(indx);
                range = range(indx);
            end
        end
        
        function range = getLabelRange(obj, label, varargin)
            % get range of statistics for certain label
            %   range = getLabelRange(obj, label);
            %
            % The first entry in range is the index in the cfa, not the cfa
            % type directly
            %
            % Inputs:
            %   obj   - instance of l3ClassifyFast class
            %   label - vector of class ID to be queried
            % 
            % Outputs:
            %   range - structure array, each entry contains range for each
            %           statistics. The pixel type index is contained in
            %           .pixelType field. The range for other statistics is
            %           contained in field with names in l3c.statNames. We
            %           keep the label as .label field in the struct array
            %
            % Programming note:
            %   In the future, we might use table (introduced in Matlab
            %   2013b) instead of struct array.
            %
            % HJ, VISTA TEAM, 2015
            
            % check inputs
            if notDefined('label'), error('label required'); end
            
            % initialize label indx and range
            l_indx = cell(length(obj.cutPoints)+1, 1);
            range = struct('label', num2cell(label));
            
            % compute sub-index
            sz = [obj.nPixelTypes cellfun(@(x)length(x), obj.cutPoints)+1];
            [l_indx{:}] = ind2sub(sz, label);
            
            % set pixel types
            pixelTypes = num2cell(l_indx{1});
            [range(:).pixeltype] = deal(pixelTypes{:});
            
            % convert index to lower and upper bound of statistics
            for ii = 1 : length(obj.cutPoints)
                sName = ieParamFormat(obj.statNames{ii});  % stat names
                for jj = 1 : length(label)
                    indx = l_indx{ii+1}(jj);
                
                    % compute lower bound
                    if indx > 1
                        range(jj).(sName)(1) = obj.cutPoints{ii}(indx-1);
                    else
                        range(jj).(sName)(1) = -inf;
                    end
                
                    % compute upper bound
                    if indx > length(obj.cutPoints{ii})
                        range(jj).(sName)(2) = inf;
                    else
                        range(jj).(sName)(2) = obj.cutPoints{ii}(indx);
                    end
                end
            end
        end
        
        function pattern = getClassCFA(obj, classID, cfa, varargin)
            % get underlying cfa pattern for certain class
            %     pattern = getClassCFA(obj, classID, cfa)
            %
            % Inputs:
            %   obj     - instance of l3ClassifyFast class
            %   classID - the cfa of which class to be retrieved
            %   cfa     - color filter array pattern. If not given, we
            %             assume that every position in the color filter 
            %             array is different 
            %
            % Outputs:
            %   pattern - underlying cfa pattern for the class
            %
            % HJ, VISTA TEAM, 2016
            
            % Init
            if notDefined('classID'), error('class ID required'); end
            if notDefined('cfa')
                cfa_size = [sqrt(obj.nPixelTypes) sqrt(obj.nPixelTypes)];
                if any(cfa_size ~= round(cfa_size))
                    error('Cannot infer CFA, please specify CFA in input');
                end
                cfa = reshape(1:obj.nPixelTypes, cfa_size);
            else
                cfa_size = size(cfa);
            end
            
            % Compute CFA pattern for that class
            patchSz = obj.patchSize; % patch size
            [X, Y] = meshgrid(1:patchSz(2), 1:patchSz(1));
            patchType = obj.getLabelRange(classID).pixeltype;
            
            cIndx  = mod((patchSz+1)/2-1, cfa_size)+1;   % center index
            [cr, cc] = ind2sub(cfa_size, patchType); % desired index
            
            pattern = cfa(mod(X-1+cc-cIndx(2), cfa_size(2)) * ...
                cfa_size(1) + mod(Y-1+cr-cIndx(1), cfa_size(1))+1);
        end
    end
    
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
