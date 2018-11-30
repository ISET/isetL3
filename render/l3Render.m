classdef l3Render < hiddenHandle
    % Constructor for the l3Render class.
    %
    % This class holds the L3 rendering process.
    %
    %
    % QT/HJ/BW (c) Stanford VISTA Team 2015
    
    properties (GetAccess = public, SetAccess = private)
        name = 'default';  % Name used for this object
    end % properties
    
    methods (Access = public)
        
        function obj = l3Render(varargin)
            % Constructor for l3Render class
            % Inputs
            %   varargin - name-value pairs for parameters
            %
            
            % check inputs
            assert(~isodd(length(varargin)), 'name value pair required');
            
            % set user defined parameters
            for ii = 1 : 2 : length(varargin)
                obj.set(varargin{ii}, varargin{ii+1});
            end
        end
        
        function outImg = render(~, rawData, pType, l3t, varargin)
            % Render method for l3Render class
            % Inputs:
            %   rawData - camera raw image data (2D matrix)
            %   pType   - pixel type matrix (2D matrix), optionally just
            %             the cfa block
            %   l3t     - learned L3 model of class l3Train
            %
            %   varargin{1} - bool, use .mex file for fast rendering. Fast
            %                 rendering does not support data kernel
            %                 feature
            %
            %
            % Procedure:
            %   1) Classify input raw data
            %   2) For each class, compute output with linear kernel
            %
            % See also:
            %   l3Train, l3ClassifyS
            %
            
            % Check inputs
            if notDefined('rawData'), error('raw data required'); end
            if notDefined('pType'), error('pixel type required'); end
            if notDefined('l3t'), error('trained l3t required'); end
            if ~isempty(varargin), useMex=varargin{1}; else useMex=1; end
            
            assert(isa(l3t, 'l3TrainS'), 'Unsupported l3t type');
            
            if iscell(rawData)
                if numel(rawData)>1, warning('Only process 1st cell'); end
                rawData = rawData{1};
            end
            rawData = double(rawData);
            
            % Get classify parameters
            l3c = l3t.l3c.copy(); % make a copy of classify class
            l3c.p_max = inf; % for rendering, store all patches
            
            l3d = l3DataCamera({rawData}, {}, pType);
            pType = l3d.pType;
            
            if useMex && exist('l3ApplyFilters', 'file') == 3
                l3c.storeData = false;
                labels = l3c.classify(l3d, true);
                outImg = l3ApplyFilters(rawData, l3t.kernels, ...
                    labels{1}, l3c.patchSize);
            else
                labels = l3c.classify(l3d, true);
                labels = labels{1};
                
                % Get unique labels
                labelV = unique(labels);
                
                imgSz = size(pType{1});
                outImgSz = imgSz - l3c.patchSize + 1;
                outImg = zeros([prod(outImgSz) l3t.nChannelOut]);
                for ii = 1 : length(labelV)
                    % get kernel from training class
                    kernel = l3t.kernels{labelV(ii)};
                    if isempty(kernel), continue; end
                    
                    % get data for this class
                    [classData, ~] = l3c.getClassData(labelV(ii));
                    
                    % pad classData with a column of one for constant term
                    classData = padarray(classData, [0 1], 1, 'pre');
                    
                    % compute output values
                    indx = (labels(:) == labelV(ii));
                    outImg(indx, :) = classData * kernel;
                end
                
                % reshape to output image size
                outImg = XW2RGBFormat(outImg, outImgSz(1), outImgSz(2));
            end
        end
        
        function obj = set(obj, param, val, varargin)
            % set method for l3Render class
            %
            % param can be chosen from
            %   'name' - name of the object
            %
            
            % check input
            if notDefined('param'), error('param required'); end
            if ~exist('val', 'var'), error('val required'); end
            
            switch ieParamFormat(param)
                case 'name'
                    obj.name = val;
                otherwise
                    error('Unknown parameter %s', param);
            end
        end
        
        function val = get(obj, param, varargin)
            % get method for l3Render class
            %
            % param can be chosen from
            %   'name' - name of the object
            %
            
            % check input
            if ieNotDefined('param'), error('param required'); end
            
            switch ieParamFormat(param)
                case 'name'
                    val = obj.name;
                otherwise
                    error('Unknown parameter %s', param);
            end
        end
        
    end
end