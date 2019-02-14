classdef l3DataSuperResolution < l3DataS
    % Class for super resolution data generation
    % 
    %  l3d = l3DataSuperResolution()
    % 
    % The class will load either scene or optical image as the start point
    % of the lower resolution sensor(with noise) and higher noise free higher
    % resolution ideal (XYZ) data generation with a certain upscale factor.
    % 
    % ZL/BW, 2019
    
    properties (Access = public)
        % The commented out properties do actually exist. They are defined
        % in the parent class l3DataS. We put them in the comments here
        % hoping to make the users' life easier.
        
        % name;   % name of the instance
        % inImg;  % Cell array of sensor raw data
        % outImg; % Cell array of target output
        
        camera;             % ISET camera model
        sources;             % cell array of scenes and/or optical images
        idealCMF;           % Target color space (string or vector)
        upscaleFactor;      % The upscaleFactor for the images
        verbose;            % Print progress information or not
 
    end
    
    
    properties (Dependent)
        cfa;
    end
    
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
        function val = get.cfa(obj)
            val = cameraGet(obj.camera, 'sensor cfa pattern');
        end
    end
end