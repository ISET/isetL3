classdef l3RenderFast < hiddenHandle
    % l3RenderFast class
    % 
    % This class holds the L3 rendering process. 
    %
    %
    % HJ, Stanford VISTA Team, 2015
    
    properties (GetAccess = public, SetAccess = private)
        name = 'default';  % Name used for this object
    end % properties 
    
    methods (Access = public)
        
        function obj = l3RenderFast(varargin)
            % Constructor for l3Render class
            % Inputs
            %   varargin - name-value pairs for parameters
            %
            
            % check inputs
            error('This class is deprecated. Use l3Render instead');
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
            % Procedure:
            %   1) Classify input raw data
            %   2) For each class, compute output with linear kernel
            %
            % See also:
            %   l3Train, l3ClassifyS
            %
            
            % Check inputs
            if ieNotDefined('rawData'), error('raw data required'); end
            if ieNotDefined('pType'), error('pixel type required'); end
            if ieNotDefined('l3t'), error('trained l3t required'); end
            assert(isa(l3t, 'l3TrainS'), 'Unsupported l3t type');
            
            if iscell(rawData)
                if numel(rawData)>1, warning('Only process 1st cell'); end
                rawData = rawData{1};
            end
            
            % Set classify parameters
            l3c = l3t.l3c;
            assert(isa(l3c, 'l3ClassifyFast'), 'unsupported l3c type');
            
            l3c.p_max = inf; % keep all of the data
            l3c.storeData = false; % only compute labels
            
            l3d = l3DataCamera({rawData}, {}, pType);
            labels = l3c.classify(l3d, true); labels = labels{1};
            
            k = permute(l3t.kernels, [3 2 1]);
            % k = k(labels, :, :);
            outImg = k(labels, :, 1); indx = 2; % output row in k
            patchSz = l3c.patchSize;
            
            for c = 1 : patchSz(2)
                for r = 1 : patchSz(1)
                    curK = k(:,:,indx);
                    d = rawData(r:end-patchSz(1)+r, c:end-patchSz(2)+c);
                    outImg = outImg + curK(labels,:).*repmat(d(:), [1, 3]);
                    indx = indx + 1;
                end
            end
            
            outImg = reshape(outImg, [size(rawData)-patchSz+1 3]);
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







