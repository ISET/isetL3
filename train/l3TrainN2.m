classdef l3TrainN2 < hiddenHandle
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
    % ZL/BW, Stanford VISTA Team, 2018
        
    properties (GetAccess = public)
        name @char;       % name of the object
        l3c @l3ClassifyS; % l3ClassifyS class, with data cleared
        
        kernels @cell;         % cell array of linear kernals
        classData @cell;       % cell array of data for different classes
        groundtrue @cell;      % cell array of data for groundtruth of classes
        outChannelNames @cell; % name of output channels
    end
    
    properties (Dependent)
        nChannelOut;  % number of output channels
    end
    
    methods (Access = public)
        % Abstract method: buildclass
        %   obj = buildclass(obj, l3d, varargin)
        % This function builds data for each classes
        %
        % Inputs:
        %   l3d - class instance of l3DataS (Required)
        %
        obj = buildclass(obj, l3d, varargin)
    end
    
    methods (Access = public)
        % Abstract method: merge
        %   obj = merge(obj)
        % This function merge the data and groundtruth for different
        % classes
        %
        % Inputs:
        %   l3d - class instance of l3DataS (Required)
        %
        function [X, y] = merge(obj, idx, varargin)
            X = 0;
            y = 0;
        end
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
