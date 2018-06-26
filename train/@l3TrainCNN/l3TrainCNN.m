classdef l3TrainCNN < l3TrainN2
    % l3Train class with Convolutional Neural Network
    %
    % This class holds the L3 training process for CNN.
    %
    % For now, we will use this class to generate the data and the
    % groudtruth (labels) that will be used for training.
    %
    % See also:
    %   l3TrainRidge, l3TrainOLS, l3TrainWiener,l3TrainS
    %
    % ZL/BW, VISTA Team, 2018
    
    % public properties
    properties (Access = public)
        verbose@logical;      % print out progress information
        p_min@double scalar;  % minimum number of patches for one class
    end
    
    methods (Access = public)
        function obj = l3TrainCNN(varargin)
            % l3TrainCNN class constructor
            %   obj = l3TrainOLS(name-val pairs)
            %
            % Inputs:
            %   varargin - name value pairs for the parameters
            %
            % Outputs:
            %   obj - l3 training class object
            %
            
            % Init input parser
            p = inputParser;
            p.KeepUnmatched = true;
            
            vFunc = @(x) validateattributes(x, {'char'}, {'nonempty'});
            p.addParameter('name', 'l3 Train CNN instance', vFunc);
            
            vFunc = @(x) assert(isa(x, 'l3ClassifyS'), ...
                'l3c must be of class l3ClassifyS (or its descendants');
            p.addParameter('l3c', l3ClassifyFast, vFunc);
            
            vFunc = @(x) validateattributes(x, {'numeric'}, ...
                         {'scalar', '>', 0});
            p.addParameter('pmin', 50,  vFunc);
            p.addParameter('verbose', true);
            p.addParameter('outChannelNames', {'red', 'green', 'blue'});
            
            % Parse input
            p.parse(varargin{:});
            
            % Set parameters to object
            obj.l3c = p.Results.l3c;
            obj.verbose = p.Results.verbose;
            obj.name = p.Results.name;
            obj.p_min = p.Results.pmin;
            obj.outChannelNames = p.Results.outChannelNames;
        end
        
        function obj = buildclass(obj, l3d, varargin)
            % The goal for this function is to build the class only and
            % save the class data into .classdata and .groundtrue property
            %
            %   obj = buildclass(obj, l3d)
            %
            % Inputs:
            %   l3d - l3 Data class object
            %   varargin - parameters for l3 classification
            %
            % Outputs:
            %   obj - l3 training class with blocks classified and the
            %   according groundtrue data stored in .classdata and
            %   .groudtrue property.
            %
            % See also:
            %   l3TrainRidge.train
            %
            % ZL/BW, VISTA TEAM, 2018
            
            % Check inputs
            l3c = obj.l3c;    % A method that classifies data
            if exist('l3d', 'var') && ~isempty(l3d)
                % Compute labels
                assert(isa(l3d, 'l3DataS'), 'Unsupported l3d type');
                l3c.classify(l3d, varargin{:});
            end
            
            % Allocate space for kernels
            n_labels = l3c.nLabels;
            fprintf('The total number of classes are: %i \n', n_labels);
            obj.classData = cell(n_labels, 1);
            obj.groundtrue = cell(n_labels, 1);
            
            % compute kernel for each class
            if obj.verbose
                cprintf('*Keywords', 'Storing data for class: ');
            end
            for ii = 1 : n_labels
                [X, y] = l3c.getClassData(ii);
                
                % check if we have enough samples for training
                if size(X, 1) < obj.p_min || size(X, 1) <= size(X, 2)
                    % fprintf('Insufficient data for %d.', cType(ii));
                    % fprintf('Patches Got: %d\n', size(X,1));
                    continue;
                end
                
                if obj.verbose
                    str = sprintf('%d/%d', ii, n_labels);
                    fprintf(str);
                end
                
                
                % Store for the block data and the groundtruth for this class
                obj.classData{ii} = X;
                obj.groundtrue{ii} = y;
                                
                if obj.verbose
                    fprintf(repmat('\b', 1, length(str)));
                end
            end
            
            % save classification parameters
            obj.l3c = l3c;
            
            if obj.verbose
                fprintf('Done\n');
            end
        end
        
        function [X, y] = merge(obj, idx, varargin)
            classData = obj.classData;
            groundTruth = obj.groundtrue;
            X = [];  y = [];
            for ii = 1 : length(idx)
                fprintf('Merging class %i \n', ii);
                X = [X; classData{ii}];
                y = [y; groundTruth{ii}];
            end
           
        end
        
    end
    
    
end