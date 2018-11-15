classdef l3DataS < hiddenHandle
    %% Abstract super class for L3 data generation
    % 
    % In general, no instance should be generated directly from this class.
    % This class contains some general properties (e.g. name) and abstract
    % method.
    %
    % Currently, we implement two different data generation methods:
    %   * ISET Simulation - see l3DataISET
    %   * Camera Data - see l3DataCamera
    % 
    % To use other methods in generating data, extends this class and
    % implement the abstract methods
    %
    % See also:
    %  l3DataISET, l3DataCamera 
    %
    % HJ/QT/BW, Stanford VISTA Team, 2015
    
    properties (Access = public)
        name = 'default';         % name used for the object (string)
        inImg;                    % Sensor raw image data (cell array)
        outImg;                   % Target image data (cell array)
    end
    
    properties (Abstract)
        cfa;                      % cfa pattern of the sensor
    end
    
    properties (Dependent)
        pType;  % index for each pixel inside cfa
    end
    
    methods (Access = public)
        function obj = l3DataS(varargin)
            % Constructor for l3DataS
        end
    end
    
    methods (Abstract, Access = public)
        % Abstract method
        %   [inImg, outImg, pType] = dataGet(nImg, varargin)
        %
        % Inputs:
        %   nImg - number of images to be generated
        %
        % Outputs:
        %  inImg - camera raw images in nImg cell arrays, each containing
        %           one MxNxp image (p=1 for camera raw case) 
        %  outImg - target output in nImg cell arrays, each containing one
        %           MxNxk image
        %  pType - pixel type in MxN matrix
        %
        [inImg, outImg, pType] = dataGet(obj, nImg, varargin)
    end
    
    methods
        function val = get.pType(obj)
            if ~isempty(obj.inImg)
                val = cell(1, length(obj.inImg));
                for ii = 1 : length(obj.inImg)
                    val{ii} = cfa2ptype(size(obj.cfa), size(obj.inImg{ii}));
                end
            else
                val = [];
            end
        end
    end
    
end
