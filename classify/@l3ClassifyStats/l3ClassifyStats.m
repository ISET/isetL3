classdef l3ClassifyStats < l3ClassifyS
    % l3ClassifyStats Class
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
        cutPoints@cell;           % cell array of cut points for stats
        statFunc@function_handle; % function handle of how to compute stats
        statFuncParam@cell;       % additional parameters for statFunc
        statNames@cell;           % cell array of statistics names
        verbose@logical scalar;   % print progress information or not
        storeData@logical scalar;   % whether or not to store p_data
        satChannels       % number of the saturation channels
        satVolt
    end
    
    properties (GetAccess = public, SetAccess = private)
        p_data;            % patch data
        p_out;             % patch target output
    end
    
    properties (Dependent)
        nChannelOut  % number of output channels
        nLabels      % number of classes
        nPixelTypes  % number of different pixel types
    end
    
    % public methods
    methods (Access = public)
        
        function obj = l3ClassifyStats(varargin)
            % l3Classify constructor
            %   l3ClassifyTree([l3d], varargin)
            %
            % Inputs:
            %   l3d - l3DataS class instance
            %   varargin - key value pairs of parameters, including
            %     {'name'}      - str, name of the instance
            %     {'pmax'}      - int, max number of patches per class
            %     {'verbose'}   - bool, whether in verbose mode
            %     {'cutPoints'} - cell, cut points for statistics
            %     {'patchSize'} - [row, col] of each patch
            %
            
            % Setup input parser
            p = inputParser;
            p.addOptional('l3d', [], @(x) assert(isa(x, 'l3DataS'), ...
                'l3d must be of class l3DataS'));
            
            vFunc = @(x) validateattributes(x, {'char'}, {'nonempty'});
            p.addParameter('name', 'l3ClassifyStats instance', vFunc);
            
            vFunc = @(x) assert(isnumeric(x) && isscalar(x) ...
                && (x > 0), 'p_max must be positive integers');
            p.addParameter('pmax', 1e5, vFunc);
            
            p.addParameter('verbose', true);
            
            vFunc = @(x) assert(isvector(x) && numel(x) == 2, ...
                'patchSize must be 2-element array');
            p.addParameter('patchSize', [5 5], vFunc);
            
            val = {logspace(-4, -1.2, 20), 1/16};
            vFunc = @(x) assert(iscell(x), 'cutPoints must be cell array');
            p.addParameter('cutPoints', val, vFunc);
            
            val = {'Luminance', 'Contrast'};
            vFunc = @(x) assert(iscell(x), 'statNames must be cell array');
            p.addParameter('statNames', val, vFunc);
            
            val = @patchMeanAndContrast;
            p.addParameter('statFunc', val);
            
            val = {};
            p.addParameter('statFuncParam', val);
            
            p.addParameter('satClassOption', 'individual');
            
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
            obj.satClassOption = p.Results.satClassOption;
            % if data class is provided, do classification
            if ~isempty(p.Results.l3d), obj.classify(p.Results.l3d); end
        end
        
        function labels = classify(obj, l3d, isNew, varargin)
            % Classify patches into different local linear groups
            % 
            %   obj = classify(obj, l3d, isNew, varargin)
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
            % Check if the varargin define how to classify saturate pixels
            % (For bayer and quadra)
            
%             if ~isempty(varargin)
%                 satClassOption = varargin{1};
%                 if length(varargin) > 1
%                     varargin = varargin{2:end};
%                 else
%                     varargin = {};
%                 end
%             else
%                 satClassOption = 'individual'; 
%             end
            satClassOption = obj.satClassOption;
            
            assert(isa(l3d, 'l3DataS'), 'l3d should be of class l3DataS');
            
            
            % Get data
            if ~isempty(length(varargin))
                [raw, tgt, pType] = l3d.dataGet(varargin{:});
            else
                [raw, tgt, pType] = l3d.dataGet();
            end
            
            if obj.verbose
                cprintf('*Keywords', 'Classifying Patches:\n');
            end
            
            % Allocate space
            nImg  = length(raw); % number of images
            labels = cell(nImg, 1);
            
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
            
            % Compute size of images accounting for the fact that the
            % patches must stay inside the image data.
            imgSz = size(pType); % input image size
            outSz = imgSz - obj.patchSize + 1; % output size
            
            % allocate spaces
            nc = length(unique(pType)); % number of channels
            satChannel = zeros(1, length(obj.cutPoints));
%             satChannel(1) = satClassNumber(pType(1:size(l3d.cfa, 1),...
%                             1:size(l3d.cfa, 2)), satClassOption);
            [satChannel(1), satType] = satClassNumber(l3d.cfa, satClassOption);
            obj.satChannels = satChannel;
            n_lvls = nc * prod(cellfun(@(x) length(x), obj.cutPoints) + 1 + satChannel);
            
            if isNew || isempty(obj.p_data)
                obj.p_data = cell(n_lvls, 1);
                obj.p_out  = cell(n_lvls, 1);
            end
            
            % Create pType for saturated pixels
            scaling = sqrt(nc/satType); 
            scaleFactor = [scaling, scaling];
            pTypeSat = cfa2ptype(size(l3d.cfa), size(l3d.inImg{1}), scaleFactor);
            
            % Loop for each image
            for ii = 1:nImg
                if obj.verbose
                    fprintf('  Processing Image %d/%d\n', ii, nImg);
                    fprintf('\tComputing Statistics...');
                end
                
                % Compute the statistics
                [pData, pTypeCol] = im2patch(raw{ii},obj.patchSize,pType);
                [~, pTypeSatCol] = im2patch(raw{ii},obj.patchSize,pTypeSat);
                stat = obj.statFunc(pData, pTypeCol, obj.statFuncParam{:});
                
                if obj.verbose
                    cprintf('Comments', 'Done\n');
                    fprintf('\tComputing label levels...');
                end
                
                % Compute labels
                %
                % levels for mean and contrast as a column vector
                % We see whether the mean/cont is less than each entry in
                % the list of levels and contrast. Then we find the
                % largest index that the mean is less than and store it.
                
                % We use the threshold saturate voltage to find for each
                % patch, and label them as which type.
                if isempty(obj.satVolt)
                    thresh = cameraGet(l3d.camera, 'sensor voltage swing') - 0.05;
                    obj.satVolt = thresh;
                else
                    thresh = obj.satVolt;
                end
                p_sat = patchSaturation(pData, pTypeSatCol, thresh);
                labelCol = obj.computeLabels(stat, pTypeCol, p_sat, satChannel);
                
                % compute overall label values
                labels{ii} = reshape(labelCol, outSz);
                
                if obj.verbose
                    cprintf('Comments', 'Done\n');
                end
                
                % store patches according to labels
                if obj.verbose
                    fprintf('\tRe-organizing patches: ');
                end
                
                % Compute p_data values
                % For the unique labels, group the patch data that have the
                % same label into a class.  We will solve the kernels with
                % the rawdata from each class.
                labelValue = unique(labelCol);
                for jj = 1 : length(labelValue)
                    if obj.verbose
                        str = sprintf('%d/%d', jj, length(labelValue));
                        cprintf('SystemCommands', str);
                    end
                    
                    % Shorten the name
                    lv = labelValue(jj);
                    
                    % Find the indices with that label value
                    indx = (labelCol == lv);
                    
                    % If we haven't exceeded the data from this class, add
                    % the data current image into the class
                    if isinf(obj.p_max) 
                        % Always add the data to the class, probably
                        % because we are rendering all the patches.
                        obj.p_data{lv} = [obj.p_data{lv} pData(:, indx)];
                        
                        % If we are rendering, there is no target to solve
                        % for.  So tgt will be empty.
                        if ~isempty(tgt)
                            % Empty during rendering case
                            tgtD = RGB2XWFormat(tgt{ii});
                            obj.p_out{lv} = [obj.p_out{lv} tgtD(indx, :)'];
                        end
                    else
                        % Include the data into the class
                        curSz = size(obj.p_data{lv}, 2);
                        newSz = sum(indx);
                        newData = pData(:, indx);
                        
%                         obj.p_data{lv} = [obj.p_data{lv} newData];
%                         
%                         if ~isempty(tgt)
%                             tgtD = RGB2XWFormat(tgt{ii});
%                             tgtD = tgtD';
%                             obj.p_out{lv} = [obj.p_out{lv} tgtD(:, indx)];
%                         end
                        
                        % Randomly resample the patches, but don't keep
                        % more than the maximum allowable.  We want the
                        % retention policy to keep the likelihood of
                        % retaining a recent or older sample as about the
                        % same.
                        n = round(curSz/(curSz+newSz)*obj.p_max);
                        idx1 = randperm(curSz, min(n, curSz));
                        curData = obj.p_data{lv}(:, idx1);
                        idx2 = randperm(newSz, min(obj.p_max-n, newSz));
                        newData = newData(:, idx2);
                        
                        obj.p_data{lv} = [curData newData];
                        
                        % store target patches in the output slot.  We use
                        % these to solve for the transform.
                        if ~isempty(tgt)
                            tgtD = RGB2XWFormat(tgt{ii});
                            tgtData = tgtD(indx, :)';
                            obj.p_out{lv} = [obj.p_out{lv}(:, idx1) ...
                                tgtData(:, idx2)];
                        end
                    end
                    
                    if obj.verbose
                        fprintf(repmat('\b', 1, length(str)));
                    end
                end
                if obj.verbose, cprintf('Comments', 'Done\n'); end
            end
        end
        
        function obj = clearData(obj, varargin)
            % clear data from the object
            obj.p_data = cell(length(obj.p_data), 1);
            obj.p_out = cell(length(obj.p_data), 1);
        end
        
        function [p_in, p_out] = getClassData(obj, label, varargin)
            % get patch data for certain class
            p_in  = obj.p_data{label}';
            p_out = obj.p_out{label}';
        end
        
        function [c_data, c_grndTruth] = concatenateClassData(obj, idx, varargin)
            assert(max(idx) <= obj.nLabels, 'Index exceeds number of classes.');
            assert(min(idx) >= 1, 'Index should be equal or larger than 1.');
            
            c_data = []; c_grndTruth = [];
            for ii = 1 : length(idx)
                fprintf('Merging class %i \n', idx(ii));
                [X, y] = obj.getClassData(idx(ii));
                c_data = [c_data; X];
                c_grndTruth = [c_grndTruth; y];
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
                    case 'pixeltype'
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
            %
            % Note that the first entry in range is the index in the cfa,
            % not the cfa type directly
            %
            % Inputs:
            %   obj   - instance of l3ClassifyStats class
            %   label - vector of class ID to be queried
            % 
            % Outputs:
            %   range - structure array, each entry contains range for each
            %           statistics. The pixel type index is contained in
            %           .pixelType field. The range for other statistics is
            %           contained in field with names in l3c.statNames
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
            range = struct('pixelType', cell(length(label), 1));
            
            % compute sub-index
            % Update: changed the sz
            sz = [obj.nPixelTypes cellfun(@(x)length(x), obj.cutPoints)+1 + obj.satChannels];
            [l_indx{:}] = ind2sub(sz, label);
            
            % set pixel types
            pixelTypes = num2cell(l_indx{1});
            [range(:).pixelType] = deal(pixelTypes{:});
            
            % convert index to lower and upper bound of statistics
            for ii = 1 : length(obj.cutPoints)
                sName = ieParamFormat(obj.statNames{ii});  % stat names
                for jj = 1 : length(label)
                    indx = l_indx{ii+1}(jj);
                
                    % compute lower bound
                    % Update: lower bound will be infinity when patches
                    % saturated
                    if indx > 1
                        if indx > length(obj.cutPoints{ii}) + 1
                            range(jj).(sName)(1) = inf;
                        else
                            range(jj).(sName)(1) = obj.cutPoints{ii}(indx-1);
                        end
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
        
        function val = get.nLabels(obj)
            val = length(obj.p_data);
        end
        
        function val = get.nPixelTypes(obj)
            % number of different pixel types
            val = obj.nLabels / prod(cellfun(@(x) length(x), ...
                            obj.cutPoints) + 1 + obj.satChannels);
        end
    end
    
    methods (Access = private)
        % private methods
        labels = computeLabels(obj, s, varargin)
    end
end
