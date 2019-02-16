classdef l3RenderSR < hiddenHandle
    % Constructor for the l3Render class for super resolution.
    %
    % This class holds the L3 rendering process for super resolution.
    %
    %
    % ZL/BW (c) Stanford VISTA Team 2019
    
    properties (GetAccess = public, SetAccess = private)
        name = 'default'; % Name used for this object
    end % properties
    
    methods (Access = public)
        function obj = l3RenderSR(varargin)
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
        
        function outImgRGB = render(~, rawData, pType, l3t, l3dSR, varargin)
            % Render method for l3RenderSR class
            % Inputs:
            %   rawData     - camera raw image data (2D matrix)
            %   pType       - pixel type matrix (2D matrix), optionally
            %                 just the cfa block
            %   l3t         - learned L3 model of class l3Train
            %
            %   varargin{1} - bool, use .mex file for fast rendering. Fast
            %                 rendering does not support data kernel
            %                 feature.
            %
            % Procedure:
            %   1) Classify input raw data
            %   2) For each class, compute output with linear kernel
            
            % Check inputs
            if notDefined('rawData'), error('raw data required'); end
            if notDefined('pType'), error('pixel type required'); end
            if notDefined('l3t'), error('trained l3t required'); end
            if notDefined('l3dSR'), error('L3 data instance required'); end
            
            if ~isempty(varargin), useMex = varargin{1}; else useMex=0; end
            
            assert(isa(l3t, 'l3TrainS'), 'Unsupported l3t type');
            if iscell(rawData)
                if numel(rawData)>1, warning('Only process the 1st cell');end
                rawData = rawData{1}
            end
            
            % Convert the data to be double format
            rawData = double(rawData);
            l3c = l3t.l3c.copy();
            l3c.p_max = inf; % for rendering, store all patches
            
            l3d = l3DataCamera({rawData}, {}, pType);
            l3d.upscaleFactor = l3dSR.upscaleFactor;
            upscaleFactor = l3dSR.upscaleFactor;
            l3d.camera = l3dSR.camera;
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
                labelU = unique(labels);
                
                % Define the size of the out image
                inImgSz = size(pType{1});
                inImgSzCrped = inImgSz - l3c.patchSize + 1;
%                 outImgSz = inImgSz * upscaleFactor;
                outImg = zeros([prod(inImgSzCrped) l3t.nChannelOut]);
                
                % 
                for ii = 1: length(labelU)
                    % Get kernel from training class
                    kernel = l3t.kernels{labelU(ii)};
                    if isempty(kernel), continue; end
                    
                    % Get data for this class
                    [classData, ~] = l3c.getClassData(labelU(ii));
                    
                    % pad classData with a column of one for constant term
                    classData = padarray(classData, [0 1], 1, 'pre');
                    
                    % compute output values
                    indx = (labels(:) == labelU(ii));
%                     effPos = find(indx == 1);
%                     indxStart = (effPos - 1) * upscaleFactor^2 + 1;
%                     indxEnd = indxStart + upscaleFactor^2 - 1;
                    outImg(indx,:) = classData * kernel;
                    
                end
                
                % rearrange to output image size
                outImgRGB = XWSR2RGBFormat(outImg, inImgSzCrped(1), inImgSzCrped(2), upscaleFactor);
            end
        end
    end
end