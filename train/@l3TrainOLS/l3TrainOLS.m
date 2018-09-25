classdef l3TrainOLS < l3TrainS
    % l3Train class with ordinary least square solver
    %
    % This class holds the L3 training process for ordinary least squares.
    %
    % There will be additional training methods (e.g., Wiener, Ridge, and
    % so forth)
    %
    % See also:
    %   l3TrainRidge, l3TrainS
    %
    % HJ/BW, VISTA Team, 2015
    
    % public properties
    properties (Access = public)
        verbose@logical;      % print out progress information
        p_min@double scalar;  % minimum number of patches for one class
    end
    
    methods (Access = public)
        function obj = l3TrainOLS(varargin)
            % l3TrainOLS class constructor
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
            p.addParameter('name', 'l3 Train OLS instance', vFunc);
            
            vFunc = @(x) assert(isa(x, 'l3ClassifyS'), ...
                'l3c must be of class l3ClassifyS (or its descendants');
            % Changed the function used instead of l3ClassifyFast to
            % l3Classifystats.
            p.addParameter('l3c', l3ClassifyStats, vFunc);  
            
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
        
        function obj = train(obj, l3d, varargin)
            % learn linear kernel for every class with ordinary least
            % square method
            %   obj = train(obj, l3d)
            %
            % Inputs:
            %   l3d - l3 Data class object
            %   varargin - parameters for l3 classification
            %
            % Outputs:
            %   obj - l3 training class with kernels learned and stored in
            %         the .kernels property
            %
            % See also:
            %   l3TrainRidge.train
            %
            % HJ/BW, VISTA TEAM, 2015
            
            % Check inputs
            l3c = obj.l3c;    % A method that classifies data
            if exist('l3d', 'var') && ~isempty(l3d)
                % Compute labels
                assert(isa(l3d, 'l3DataS'), 'Unsupported l3d type');
                l3c.classify(l3d, varargin{:});
            end
            
            % Allocate space for kernels
            n_labels = l3c.nLabels;
            obj.kernels = cell(n_labels, 1);
            
            % compute kernel for each class
            if obj.verbose
                cprintf('*Keywords', 'Training for class: ');
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
                
                % adding a column of ones to X for constant term (affine)
                X = padarray(X, [0 1], 1, 'pre');
                
                % Solve for the kernel for this class
                obj.kernels{ii} = obj.learnClassKernel(X, y, ii);
                                
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
    end
    
    methods (Access = protected)
        function [kernels, p_val] = learnClassKernel(~, X, y, varargin)
            % Learn kernel with ordinary least square method 
            %   [kernels, p_val] = learnClassKernel(obj, X, y)
            %
            % The function solves beta for equation y = X * beta with
            % ordinary least square. The close form solution is given by
            %   beta = inv(X'*X)*X'*y;
            % In this function, we call lscov to solve for beta more
            % efficiently (using SVD of X)
            % 
            % Inputs:
            %   X - Nxp data matrix with each data instance stored in rows
            %   y - target output data matrix
            % 
            % Outputs:
            %   kernels - kernel matrix (beta) solved with OLS method
            %   p_val   - probability of beta equals zero (point wise)
            % 
            % See also:
            %   l3TrainRidge.learnClassKernel
            %
            % HJ/BW, VISTA TEAM, 2015
            if nargout == 1
                kernels = lscov(X, y);
            else
                [kernels, std_err] = lscov(X, y);
                try
                    df = size(X, 1) - size(kernels, 1);
                    p_val = 2 * tcdf(-abs(kernels./std_err), df);
                catch
                    warning('error occured, might missing stat toolbox');
                end
            end
        end
    end
end