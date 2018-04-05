classdef l3DataSimulation < l3DataS
    % Class for data generation using ISETCAM
    % 
    %   l3C = l3DataSimulation()
    %
    % The raw and desired output (rgb) data are generated using camera
    % simulation. The data sources can be scenes or optical images (or
    % both). The dataGet method of this class returns the raw and target
    % pairs.
    %
    % There is no input / output illuminant support in this class. For
    % that functionality, see l3DataISET.
    % 
    % HJ, VISTA Team, 2015
    %
    % See also:
    %  t_L3DataISET
    
    properties (Access = public)
        % The commented out properties do actually exist. They are defined
        % in the parent class l3DataS. We put them in the comments here
        % hoping to make the users' life easier.
        
        % name;   % name of the instance
        % inImg;  % Cell array of sensor raw data
        % outImg; % Cell array of target output
        
        camera;    % ISET camera model
        sources;   % cell array of scenes and/or optical images
        expFrac;   % vector of scaling factor for exposure time and 1.0 
                   % corresponds to auto-exposure duration
        idealCMF;  % Target color space (string or vector)
        
        verbose;   % print progress or not
    end
    
    properties (Dependent)
        cfa;
    end
    
    methods (Access = public)
        % l3DataSimulation class constructor
        function obj = l3DataSimulation(varargin)
            % Init input parser
            p = inputParser;
            
            % add parameters
            p.addParameter('name', 'default');
            p.addParameter('camera', []);
            p.addParameter('sources', {});
            p.addParameter('expFrac', [1 0.6 0.3 0.1]);
            p.addParameter('idealCMF', 'XYZQuanta');
            p.addParameter('verbose', true);
            
            % parse and set to object properties
            p.parse(varargin{:});
            if ~isempty(p.Results.camera), obj.camera  = p.Results.camera;
            else obj.camera = cameraCreate; end
            obj.name = p.Results.name;
            obj.sources = p.Results.sources;
            obj.expFrac = p.Results.expFrac;
            obj.verbose = p.Results.verbose;
            
            % load color matching function is it's specified as string
            if ischar(p.Results.idealCMF)
                wave = cameraGet(obj.camera, 'sensor wave');
                obj.idealCMF = ieReadSpectra(p.Results.idealCMF, wave);
            else
                obj.idealCMF = p.Results.idealCMF;
            end
        end
    end
    
    methods
        function val = get.cfa(obj)
            val = cameraGet(obj.camera, 'sensor cfa pattern');
        end
    end
end