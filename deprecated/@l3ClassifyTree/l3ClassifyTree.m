classdef l3ClassifyTree < l3ClassifyS
    % Constructor for the l3Classify class.
    %
    % This class holds the L3 classification process used for the training
    % and rendering processes.
    %
    %
    % QT/HJ/BW (c) Stanford VISTA Team 2015
    
    % public visible properties
    % contains parameters for doing the classification
    % can be modified with set function
    properties (GetAccess = public, SetAccess = private)
        lum_levels;        % mean pixel response levels (volts)
        sat_thresh;        % saturation threshold (volts)
        contrast_levels;   % contrast threshold levels ()
        labels;            % patch labels
        verbose;           % print progress information or not
    
        % intermediate computing results
        % Not sure if these should be stored
        % (HJ)
        p_type;     % cell array containing center pixel type of patch
        c_mean;     % cell array containing channel means of each patch
        p_mean;     % cell array containing patch mean luminance
        p_cont;     % cell array containing patch contrast
        p_sat;      % cell array containing patch saturation
        
        p_data;     % cell array of patch data matrices for each class
        p_indx;     % cell array of patch indices for the members of each 
                    % class which points to the position of this patch 
                    % in the original image
        
        pixel_type; % types of different pixels (e.g., R,G1,B,G2; or R,G,B,C)
    end
    
    % public methods
    methods (Access = public)
        % l3Classify constructor
        function obj = l3ClassifyTree(l3d, varargin)
            if isodd(length(varargin))
                error('Param-value pair required');
            end
            
            % Should initialize parameter to more reasonable defaults
            obj.lum_levels = logspace(-2,-.1,10); 
            obj.sat_thresh = 0.95;      
            obj.contrast_levels = inf;  % [0.8 1.5];
            obj.patchSize = [5 5];      % row col of the patch
            obj.p_max     = 1e5;        % Max no. of patches for any training class
            obj.verbose   = true;
            
            % set additional user-defined parameters
            for ii = 1 : 2 : length(varargin)
                obj.set(varargin{ii}, varargin{ii+1});
            end
            
            % if data class is provided, do classification
            if exist('l3d', 'var') && ~isempty(l3d)
                assert(isa(l3d, 'l3DataS'), 'Unkown input type for l3d');
                obj.classify(l3d);
            end
        end
        
        function labels = classify(obj, varargin)
            % General process
            %   1) For each input image, compute stastics, including
            %      channel mean, patch mean voltage, patch contrast, patch
            %      saturation map, etc.
            %
            %   2) Create label maps using the computed statistics
            %
            % This function can accept two sets of inputs
            %   1) varargin{1} is a l3Data class
            %   2) varargin{1} is cell array of rawData and varargin{2} is
            %      the pixel type (pType) matrix that indicates the
            %      position of each pixel within the cfa repeating pattern.
            %
            % The outputs are stored in obj.p_data and obj.p_indx
            %
            % Output label Dimension order:
            %    pType -> mean response -> contrast -> saturation class
            %  
            % We will use this kind of function for figuring out the class
            % number.
            %   aSize=[numel(cfa), nLevels, nContrasts, nSatClass=2^nchan];
            %   idx = sub2ind(aSize, pType, meanLevel, contrast, satClass)
            %   obj.p_data{idx}
            %
            
            % Check inputs and get the raw data and pType
            if isempty(varargin), error('not enough input'); end
            if isa(varargin{1}, 'l3DataS')
                l3d = varargin{1};
                if length(varargin) > 1
                    [rawData, ~, pType] = l3d.dataGet(varargin{2:end});
                else
                    [rawData, ~, pType] = l3d.dataGet();
                end
            elseif length(varargin) > 1 && iscell(varargin{1})
                rawData = varargin{1};
                pType = varargin{2};
            else
                error('Unkown input format');
            end
            
            if obj.verbose
                cprintf('*Keywords', 'Classifying Patches:\n');
            end
            
            % Allocate space
            nImg  = length(rawData); % number of images
            obj.pixel_type = unique(pType);
            nChannel = length(obj.pixel_type); % number of pixel types
            
            obj.c_mean = cell(nImg, 1);
            obj.p_type = cell(nImg, 1);
            obj.p_mean = cell(nImg, 1);
            obj.p_cont = cell(nImg, 1);
            obj.p_sat  = cell(nImg, 1);
            obj.labels = cell(nImg, 1);
            
            % Convert patches of pType to columns in a matrix
            pTypeCol = im2col(pType, obj.patchSize, 'sliding');
            
            % Compute size of images accounting for the fact that the
            % patches must stay inside the image data.
            imgSz = size(pType); % input image size
            outSz = imgSz - obj.patchSize + 1; % output size
            
            % Mean response level and contrast level parameters
            ml = [obj.lum_levels(:)' inf];
            cl = [obj.contrast_levels(:)' inf];
            
            nc = length(obj.pixel_type);
            n_lvls = nc * length(ml) * length(cl)*2^nc;
            obj.p_data = cell(n_lvls, 1);
            obj.p_indx = cell(n_lvls, 1);
            
            % Loop for each image
            for ii = 1:nImg
                if obj.verbose
                    fprintf('  Processing Image %d/%d\n', ii, nImg);
                end
                
                % Set up the raw data into the patches
                curImg = im2col(rawData{ii}, obj.patchSize, 'sliding');
                if obj.verbose
                    fprintf('\tComputing Statistics...');
                end
                
                % Compute the statistics here
                s = obj.computeStatistics(curImg, pTypeCol);
                
                % Store the statistics for this image
                obj.c_mean{ii} = reshape(s.c_mean, [outSz nChannel]); % Channel mean
                obj.p_cont{ii} = reshape(s.cont, outSz);              % Contrast
                obj.p_sat{ii}  = reshape(s.sat,  outSz);              % Saturations
                obj.p_mean{ii} = reshape(s.p_mean, outSz);            % Patch mean
                
                if obj.verbose
                    cprintf('Comments', 'Done\n');
                end
                
                % Compute labels
                if obj.verbose
                    fprintf('\tComputing label levels...');
                end
                
                % levels for mean and contrast as a column vector
                % We see wither the mean/cont is less than each entry in
                % the list of levels and contrast.  Then we find the
                % largest index that the mean is less than and store it.
                [~, m_lvl] = max(bsxfun(@le, s.p_mean(:), ml), [], 2);
                [~, c_lvl] = max(bsxfun(@le, s.cont(:), cl), [], 2);
                
                % compute labels for each pixel as a column vector
                c_pos  = (obj.patchSize + 1)/2;
                c_indx = sub2ind(obj.patchSize, c_pos(1), c_pos(2));
                pTypeOut = pTypeCol(c_indx, :)';
                obj.p_type{ii} = pTypeOut;
                aSize = [max(pType(:)),length(ml),length(cl),2^nChannel];
                labelCol = sub2ind(aSize,pTypeOut, m_lvl, c_lvl, s.sat(:));
                %
                %   labelCol2 = (((pTypeOut - 1) * length(ml)+m_lvl-1) * ...
                %             length(cl) + c_lvl-1) * 2^nChannel + s.sat(:) + 1;
                
                % compute overall label values
                obj.labels{ii} = reshape(labelCol, outSz);
                % vcNewGraphWin; imagesc(obj.labels{ii})

                if obj.verbose
                    cprintf('Comments', 'Done\n');
                end
                
                % store patches according to labels
                if obj.verbose
                    fprintf('\tRe-organizing patches: ');
                end
                
                % Compute p_data and p_indx values
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
                    if size(obj.p_data{lv}, 2) < obj.p_max
                        % add more data to class
                        obj.p_data{lv} = [obj.p_data{lv}, curImg(:, indx)];
                        
                        % store indx
                        indx = [find(indx) ii * ones(sum(indx), 1)];
                        obj.p_indx{lv} = [obj.p_indx{lv}; indx];
                        
                        % discard data beyond the p_max limit
                        curSz = min(obj.p_max, size(obj.p_data{lv}, 2));
                        obj.p_data{lv} = obj.p_data{lv}(:, 1:curSz);
                        obj.p_indx{lv} = obj.p_indx{lv}(1:curSz, :);
                    end
                    
                    if obj.verbose
                        fprintf(repmat('\b', 1, length(str)));
                    end
                end
                if obj.verbose, cprintf('Comments', 'Done\n'); end
            end
            labels = obj.labels;
        end
        
        function obj = set(obj, param, val, varargin)
            % set method for l3Classify class
            % param can be chosen from
            %   {lum levels, mean levels} - mean luminance levels
            %   {sat thresh} - saturation threshold
            %   {contrast levels} - threshold for contrast levels
            %   {patchsize} - patch size
            %   {maxpatchesperclass} - max number of patches per class
            %   {verbose} - whether or not to print progress info
            %
            
            if ieNotDefined('param'), error('parameter required'); end
            if ~exist('val', 'var'), error('value required'); end
            
            switch ieParamFormat(param)
                case {'lumlevels', 'meanlevels'}
                    obj.lum_levels = val;
                case 'satthresh'
                    obj.sat_thresh = val;
                case 'contrastlevels'
                    obj.contrast_levels = val;
                case 'verbose'
                    obj.verbose = val;
                otherwise
                    obj = set@l3ClassifyS(obj, param, val, varargin{:});
            end
        end
        
        function val = get(obj, param, varargin)
            % get method for l3Classify class
            % param can be chosen from
            %   -- classification parameters --
            %   {'lum levels', 'mean levels'} - mean luminance levels
            %   {'sat thresh'} - saturation threshold
            %   {'contrast levels'} - threshold for contrast levels
            %   {'patchsize'} - patch size
            %
            %   -- patch statistics --
            %   {'channel mean'} - mean response of each channel in patches
            %   {'patch mean'}   - mean response for all patches
            %   {'patch contrast'} - contrast for all patches
            %   {'patch saturation'} - saturation for all patches
            %
            %   -- labels --
            %   {'labels', 'patch labels'} - labels for patches
            %
            %   -- Other --
            %   {'verbose'} - whether or not to print progress info
            %
            
            if ieNotDefined('param'), error('param required'); end
            
            switch ieParamFormat('param')
                case {'lumlevels', 'meanlevels'}
                    val = obj.lum_levels;
                case 'satthresh'
                    val = obj.sat_thresh;
                case 'labels'
                    val = obj.labels;
                case 'contrastlevels'
                    val = obj.contrast_levels;
                case {'channelmean', 'cmean'}
                    val = obj.c_mean;
                case {'patchmean', 'mean'}
                    val = obj.p_mean;
                case {'patchcontrast', 'contrast'}
                    val = obj.p_cont;
                case {'patchsaturation', 'saturation'}
                    val = obj.p_sat;
                case {'patchlabels', 'labels'}
                    val = obj.labels;
                case {'verbose'}
                    val = obj.verbose;
                otherwise
                    val = get@l3ClassifyS(obj, param, varargin{:});
            end
        end
        
        function obj = clearData(obj, varargin)
            % clear intermediate statistics (c_mean, p_mean, etc.) and
            % computed labels
            obj.c_mean = {};
            obj.p_mean = {};
            obj.p_cont = {};
            obj.p_sat  = {};
            obj.labels = {};
            
            obj.p_data = {};
            obj.p_indx = {};
        end
        
        function [data, indx] = getClassData(obj, label, varargin)
            % get patch data for certain class
            data = obj.p_data{label}';
            indx = obj.p_indx{label};
        end
    end
    
    methods (Access = private)
        function s = computeStatistics(obj, p_data, pType)
            % Compute statistics for patches
            %
            % Inputs:
            %   p_data - patch data, each column represents one patch
            %   pType  - pixel type, same shape as p_data
            %
            % Output:
            %   s - structure containing statistics
            %     .c_mean - channel mean
            %     .p_mean - patch mean
            %     .cont - patch contrast
            %     .sat  - patch saturation
            %
            
            % Check inputs
            if ieNotDefined('p_data'), error('patch data required'); end
            if ieNotDefined('pType'), error('pixel type required'); end
            
            % compute unique pixel types
            pValue = obj.pixel_type;
            
            % compute channel mean, contrast and saturation
            s.c_mean = zeros(length(pValue), size(p_data, 2));
            s.cont = zeros(1, size(p_data, 2));
            s.sat  = zeros(1, size(p_data, 2));
            sat_indx = p_data > obj.sat_thresh;
            
            
            for ii = 1 : length(pValue)
                % index of data columns with current pixel type
                indx = (pType == pValue(ii));
                
                % compute channel mean
                val = bsxfun(@rdivide, sum(p_data.*indx), sum(indx));
                s.c_mean(ii, :) = val;
                
                % compute contrast
                s.cont = s.cont+sum(abs(bsxfun(@minus,p_data,val).*indx));
                
                % compute saturation indicator.
                % The saturation is encoded as a binary value.  Suppose
                % there are 4 channels.  Then we set a bit when that
                % channel is saturated.  There can be 2^4 possible patterns
                % for the case with 4 channels, so s.sat is between 0 and
                % 15.  Later, we use it for indexing and increment by 1.
                s.sat = 2*s.sat + any(sat_indx .* indx);
            end
            % We use this for indexing, so we move it to Matlab [1/N]
            % indexing range.
            s.sat = s.sat + 1;
            % compute mean voltage response for each patch
            s.p_mean = mean(s.c_mean);
        end
    end
end
