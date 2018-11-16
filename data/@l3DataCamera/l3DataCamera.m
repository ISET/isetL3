classdef l3DataCamera < l3DataS
    % Class for data generation using real camera data
    % 
    % The raw and desired output (rgb) data are directly extracted from
    % a real camera. The camera does not need to be calibrated. The only
    % thing we need to know is the cfa type of each pixel in the raw data.
    % 
    % Examples:
    %  l3C = l3DataCamera(inImg, outImg, cfa)
    %  l3C.classify(l3D); % Classify sensor images
    %
    % HJ/QT/BW, Stanford VISTA Team, 2015
    
    properties (Access = public)
        % The commented out properties do actually exist. They are defined
        % in the parent class l3DataS. We put them here hoping that it
        % could make the users' life easier.
        
        % name;   % name of the instance
        % inImg;  % Cell array of sensor raw data
        % outImg; % Cell array of target output
        
        cfa;      % cfa pattern
    end
    
    methods (Access = public)
        % l3DataCamera class constructor
        function obj = l3DataCamera(inImg, outImg, cfa, varargin)
            % Init input parser
            p = inputParser;
            
            vFunc = @(x) validateattributes(x, {'cell'}, {'nonempty'});
            p.addRequired('inImg', vFunc);
            p.addRequired('outImg');
            
            vFunc = @(x) assert(ismatrix(x), 'cfa must be 2D matrix');
            p.addRequired('cfa', vFunc);
            
            vFunc = @(x) validateattributes(x, {'char'}, {'nonempty'});
            p.addParameter('name', 'l3 Camera Data Class Instance', vFunc);
            
            % Parse inputs
            p.parse(inImg, outImg, cfa, varargin{:});
            
            % set parameters to object
            obj.cfa = cfa;
            obj.inImg = inImg;
            obj.outImg = outImg;
            obj.name = p.Results.name;
        end
        
        function [inImg, outImg, pType] = dataGet(obj, nImg, varargin)
        % Get camera raw image and corresponding rendered target image
        % stored in the object structure
        %   [inImg, outImg, pType] = dataGet(obj, [nImg])
        %
        % Inputs:
        %   obj  - l3DataCamera object
        %   nImg - number of image pairs to be retrieved
        %
        % Outpust:
        %   inImg  - cell array of camera raw images
        %   outImg - cell array of target output image
        %   pType  - underlying pixel index in cfa for each position in 
        %            camera raw image data
        %
        % See also:
        %   l3DataISET.dataGet
        %
        % HJ/BW, VISTA TEAM, 2015
        
            if ieNotDefined('nImg'), nImg = length(obj.inImg); end
            
            inImg  = obj.inImg(1:nImg);
            if isempty(obj.outImg)
                outImg = {};
            else
                outImg = obj.outImg(1:nImg);
            end
            pType  = obj.pType;
        end
        
        function obj = dataAdd(obj, inImg, outImg, pType, varargin)
        % dataAdd method for l3DataCamera
        %   append more data for current l3DataCamera object
        %   Inputs:
        %     inImg  - 2D matrix or cell array of input raw data
        %     outImg - 3D matrix or cell array of desired output image
        %     pType  - 2D matrix of pixel type map
        %   If obj.pType is not empty, pType is not used
        %
        
            % check input
            if notDefined('inImg'), error('inImg required'); end
            if notDefined('outImg'), error('outImg required'); end
            
            % make sure inImg and outImg are cell array
            if ~iscell(inImg), inImg = {inImg}; end
            if ~iscell(outImg), outImg = {outImg}; end
            
            % check pType and the size of inImg
            if isempty(obj.pType)
                assert(~ieNotDefined('pType'), 'pType required');
                if any(size(pType) ~= size(inImg{1}))
                    % input pType is actually cfa
                    obj.pType = cfa2ptype(size(ptype), size(inImg{1}));
                else
                    obj.pType = pType;
                end
            end
            assert(all(size(inImg{1})==size(obj.pType)), 'bad inImg size')
            
            % append them to current object
            obj.inImg = cat(1, obj.inImg, inImg(:));
            obj.outImg = cat(1, obj.outImg, outImg(:));
        end
    end
end
