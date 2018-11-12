classdef l3DataISET < l3DataS
    % Class for data generation using ISET camera simulator
    % 
    %  l3d = l3DataISET
    %
    % This class uses ISETCAM and scene radiance data to calculate the
    % ideal (noise-free XYZ) values of the scene at each point and the
    % corresponding camera sensor data (with noise).  
    %
    %  These image data are delivered to one of the training algorithms to
    %  develop the L3 lookup tables for rendering.
    % 
    % QT/HJ/BW, VISTA TEAM, 2015
    %
    % See also
    %   l3DataSimulation
    
    properties (Access = public)        
        % For ISET simulations we need camera, scenes, illuminant levels
        % (cd/m2), illuminantSPD, curves for the ideal color space
        camera;           % ISET camera structure
        scenes;           % ISET scene structure (cell array)
        nScenes;          % Number of training scenes (scalar)
        illuminantLev;    % Input illuminants levels (vector)
        inIlluminantSPD;  % Raw image illuminant SPD (string or vector)
        outIlluminantSPD; % Target image illuminant SPD (string or vector)
        idealCMF;         % Target color space (string or vector)
        verbose;          % Print progress information or not;
    end
    
    properties (Dependent)
        cfa;              % cfa pattern of the camera
    end
    
    methods (Access = public)
        % l3Data class constructor
        function obj = l3DataISET(varargin)
            % Initialize default parameter to perform ISET camera
            % simulation for L3
            
            % Fill up the parameters with the general defaults
            obj.camera = cameraCreate; % Use ISET default camera
            obj.nScenes = 7;
            obj.illuminantLev = [40, 10, 80]; % cd/m2
            obj.idealCMF = 'XYZQuanta.mat';
            obj.inIlluminantSPD = {'D65', 'Tungsten'};
            obj.outIlluminantSPD = {'D65', 'Tungsten'};
            obj.verbose = true;
            obj.scenes = {};
            
            % take care of user input
            for ii=1 : 2 : length(varargin)
                set(obj, varargin{ii}, varargin{ii+1});
            end
            
            % load multispectral scenes from remote server
            if isempty(obj.scenes)
                disp('Loading default scenes from RDT');
                obj.scenes = rdtScenesLoad('nScenes', obj.nScenes);
            end
        end        
        
        % Get method
        function val = get(obj, param, varargin)
            switch ieParamFormat(param)
                case 'name'
                    val = obj.name;
                case 'camera'
                    val = obj.camera;
                case 'scenes'
                    % Returns a cell array of scenes
                    % l3D.get('scenes', [1 2 4])
                    % l3D.get('scenes', 1)
                    if isempty(varargin)
                        val = obj.scenes;
                    else
                        val = obj.scenes(varargin{1});
                        if isscalar(varargin{1}), val = val{1}; end
                    end
                case 'nscenes'
                    val = length(obj.scenes);
                case {'scenewave', 'scenewavelength'}
                    val = sceneGet(obj.get('scenes', 1), 'wave');
                case 'illuminantlevels'
                    val = obj.illuminantLev;
                case 'idealcmf'
                    val = obj.idealCMF;
                    if ischar(val)
                        val = ieReadSpectra(val, obj.get('scene wave'));
                    end
                case 'nilluminants'
                    val = length(obj.inIlluminantSPD);
                    if length(obj.inIlluminantSPD) ~= length(obj.outIlluminantSPD)
                        error('Different number of in and out illuminants!');
                    end
                case 'inilluminantspd'
                    if isempty(varargin)
                        val = obj.inIlluminantSPD;
                    else  
                        val = obj.inIlluminantSPD{varargin{1}};
                        if ischar(val)
                            val = ieReadSpectra(val, obj.get('scene wave'));
                        end
                    end
                case 'outilluminantspd'
                    if isempty(varargin)
                        val = obj.outIlluminantSPD;
                    else    
                        val = obj.outIlluminantSPD{varargin{1}};
                        if ischar(val)
                            val = ieReadSpectra(val, obj.get('scene wave'));
                        end
                    end
                case {'scenefov', 'scenehfov'}
                    scene = obj.get('scenes', 1);
                    val = sceneGet(scene, 'h fov');
                otherwise
                    error('Unknown parameter');
            end
        end
        
        % Set method 
        function obj = set(obj, param, val, varargin)
            switch ieParamFormat(param)
                case 'name'
                    obj.name = val;
                case 'camera'
                    obj.camera = val;
                case 'scenes'
                    obj.scenes = val;
                case 'nscenes'
                    obj.nScenes = val;
                otherwise
                    error('Unknown parameter');
            end
        end
        
    end % public methods
    
    methods
        function val = get.cfa(obj)
            val = cameraGet(obj.camera, 'sensor cfa pattern');
        end
    end
end % classdef
