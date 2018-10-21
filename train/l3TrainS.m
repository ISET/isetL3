classdef l3TrainS < hiddenHandle
    % Abstract super class for L3 training and filter learning
    %
    % In general, no instance should be generated directly from this class.
    % This class contains some general properties (e.g. name) and abstract
    % method.
    %
    % Currently, we have two implementations. One is using OLS method and
    % another one is using Wiener filter
    %
    % To use other methods to learn the kernels, extends this class and
    % implement the abstract methods
    %
    % See also:
    %  l3TrainOLS, l3TrainWiener
    %
    % HJ/BW, Stanford VISTA Team, 2015
        
    properties (GetAccess = public)
        name @char;       % name of the object
        l3c @l3ClassifyS; % l3ClassifyS class, with data cleared
        
        kernels @cell;         % cell array of linear kernals
        outChannelNames @cell; % name of output channels
        
    end
    
    properties (Dependent)
        nChannelOut;  % number of output channels
    end
    
    methods (Abstract, Access = public)
        % Abstract method: train
        %   obj = train(obj, l3d, l3c, varargin)
        % This function learns linear kernel for each class
        %
        % Inputs:
        %   l3d - class instance of l3DataS (Required)
        %
        obj = train(obj, l3d, varargin)
    end
            
    methods (Access = public)
        function obj = l3TrainS(varargin)
            % constructor for l3TrainS class
        end
        
        function save(l3t, fname, keepData)
            % save l3Train object to file
            if notDefined('fname'), error('file name required'); end
            if notDefined('keepData'), keepData = false; end
            
            % clear data
            if ~keepData
                l3t = l3t.copy();
                l3t.l3c.clearData();
            end
            
            % save to file
            save(fname, 'l3t');
        end
    end
    
    methods (Static)
        function obj = load(fname)
            % load l3Train Object from file
            if ~exist(fname, 'file'), error('file not exist'); end
            tmp = load(fname);
            if isfield(tmp, 'l3t')
                obj = tmp.l3t;
            else
                error('Unknown file format');
            end
        end
    end
    
    methods (Access = protected)
        function cpObj = copyElement(obj)
            % Make a shallow copy of training class
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            
            % Make a deep copy of the classify object
            cpObj.l3c = copy(obj.l3c);
        end
    end
    
    methods
        % get function for dependent variable 'nChannelOut'
        function val = get.nChannelOut(obj)
            if ~isempty(obj.kernels)
                val = size(cell2mat(obj.kernels(:)), 2);
            elseif ~isempty(obj.l3c)
                val = obj.l3c.nChannelOut;
            end
        end
    end
end
