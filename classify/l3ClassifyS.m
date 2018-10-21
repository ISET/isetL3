classdef l3ClassifyS < hiddenHandle
    % Abstract super class for L3 data classification
    % 
    % In general, no instance should be generated directly from this class.
    % This class contains some general properties (e.g. name) and abstract
    % method.
    %
    % Currently, we have one implementation with tree structure. See
    % l3ClassifyTree for more detail
    % 
    % To use other methods in classifying data, extends this class and
    % implement the abstract methods
    %
    % See also:
    %  l3ClassifyStats
    %
    % HJ/QT/BW, Stanford VISTA Team, 2015
    
    properties (Access = public)
        name @char;           % name used for the object
        patchSize @double;    % size of each patch
        p_max @double scalar; % max number of patches in each class
        satClassOption @char;
    end
    
    methods (Access = public)
        
        function obj = l3ClassifyS(varargin)
            % Constructor for l3ClassifyS
            % do nothing here
        end
    end
    
    methods (Abstract)
        % Abstract method: classify
        %   obj = classify(obj, varargin)
        labels = classify(obj, varargin)
        
        % Abstract method: clearData
        %   obj = clearData(obj, varargin)
        %
        % This function clears intermediate statistics (c_mean, p_mean,
        % etc.) and computed labels
        obj = clearData(obj, varargin)
        
        % Abstract method: getClassData
        %   [p_in, p_out] = getClassData(obj, label)
        %
        % This function returns the patches data of certain class in shape
        % of n * prod(patchSz) and their position (indx) in the original
        % image
        % 
        % For the render case, the p_out will simply be empty
        [p_in, p_out] = getClassData(obj, label, varargin)
        
        % This function is used to concatenate data from indicated classes
        [c_data, c_grndTruth] = concatenateClassData(obj, idx, varargin)
    end
end
