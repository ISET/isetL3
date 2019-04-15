classdef l3DataSuperResolution < l3DataS
    % Class for super resolution data generation.  Subclass of l3DataS
    % 
    %  l3d = l3DataSuperResolution()
    % 
    % The class loads either a set of scenes or optical images.  These
    % are then used to generate the higher and lower resolution sensor
    % data for training.
    % 
    % ZL/BW, 2019
    
    properties (Access = public)
        
        % The commented out properties are defined in the parent class
        % l3DataS.  We list them here to be helpful.
        %
        % name;   % name of the instance
        % inImg;  % Cell array of sensor raw data
        % outImg; % Cell array of target output
        
        camera;             % ISETCam camera model
        sources;            % cell array of scenes and/or optical images
        idealCMF;           % Target color space (string or vector)
        upscaleFactor;      % The upscaleFactor for the images
        verbose;            % Print progress information or not
        refPType;           % A reference for quad pattern
    end
    
    
    properties (Dependent)
        % Why this cfa and the camera/sensor cfa?
        cfa;
    end
    
    % Public methods
    methods (Access = public)
        function obj = l3DataSuperResolution(varargin)
            % Init input parser
            p = inputParser;
                        
            % add parameters
            p.addParameter('name', 'default');
            p.addParameter('camera', []);
            p.addParameter('sources', {});
            p.addParameter('idealCMF', 'XYZQuanta');
            p.addParameter('verbose', true);
            p.addParameter('upscaleFactor', 1);
            p.addParameter('refPType', []);
            % parse and set to the obj properties
            p.parse(varargin{:});
            
            if ~isempty(p.Results.camera), obj.camera  = p.Results.camera;
            else, obj.camera = cameraCreate; end
            
            if ~isempty(p.Results.sources), obj.sources = p.Results.sources;
            else, obj.sources = {sceneCreate}; end
            
            obj.name = p.Results.name;
            obj.verbose = p.Results.verbose;
            obj.upscaleFactor = p.Results.upscaleFactor;
            
            % load alternative color matching function if it is specified
            % as a string
            if ischar(p.Results.idealCMF)
                wave = cameraGet(obj.camera, 'sensor wave');
                obj.idealCMF = ieReadSpectra(p.Results.idealCMF, wave);
            else
                obj.idealCMF = p.Results.idealCMF;
            end
        end
        
        function val = get(obj, param, varargin)
            switch ieParamFormat(param)
                case 'name'
                    val = obj.name;
                case 'camera'
                    val = obj.camera;
                case 'sources'
                    val = obj.sources;
                case 'idealcmf'
                    val = obj.idealCMF;
                    if ischar(val)
                        val = ieReadSpectra(val, obj.get('scene wave'));
                    end
                case 'upscaleFactor'
                    val = obj.upscaleFactor;
                case 'verbose'
                    val = obj.verbose;           
            end
        end
        
        function obj = set(obj, param, val, varargin)
            switch ieParamFormat(param)
                case 'name'
                    obj.name = val;
                case 'camera'
                    obj.camera = val;
                case 'sources'
                    obj.sources = val;
                case 'idealcmf'              
                    if ischar(val)
                        val = ieReadSpectra(val, obj.get('scene wave'));
                    end
                    obj.idealCMF = val;
                case 'upscaleFactor'
                    obj.upscaleFactor = val;
                case 'verbose'
                    obj.verbose = val;
                otherwise
                    error('Unknown parameter');
            end
        end
    end
    
    methods
        % Required Matlab format
        function val = get.cfa(obj)
            val = cameraGet(obj.camera, 'sensor cfa pattern');
        end
    end
end