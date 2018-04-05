classdef l3TrainWiener < l3TrainRidge
    % l3Train class by Wiener filter
    %
    % This class holds the L3 training process
    %
    % There will be additional training methods (e.g., OLS, Ridge, and
    % so forth)
    %
    % See also:
    %   l3TrainOLS, l3TrainS, l3TrainRidge
    %
    % HJ/BW (c) Stanford VISTA Team 2015
    
    properties (Access = public)
        noiseEstFunc = @(x) 0; % noise estimation function
    end
    
    methods (Access = protected)
        function [kernel, p] = learnClassKernel(obj, X, y, label)
            % Learn kernel beta for y = X * beta
            %
            % In this class, the kernel solves beta by ridge regression
            % with covariance estimation
            
            % estimate noise covariance
            % Estimating noise variance directly from data is a hard task
            % If we are using ISET simulation, we could use l3findnoisevar
            % to estimate the variance. However, if we are using real
            % camera data, a lot of parameters are unknown (e.g. conversion
            % gain, dsnu, prnu, etc.)
            %
            % Currently, for simulation data (l3DataISET), we estimate
            % noise variance (see L3findnoisevar). Otherwise, noise
            % variance is assumed to be zero.
            %
            % HJ
            noisevar = obj.noiseEstFunc(mean(X));
            
            % esitmate covariance
            obj.lambda = noisevar;
            
            % esitmation with ridge method
            [kernel, p] = learnClassKernel@l3TrainRidge(obj, X, y, label);
        end
        
    end
    
    methods (Access = public)
        function obj = l3TrainWiener(varargin)
            % class constructor
            obj = obj@l3TrainRidge(varargin{:});
            
            % Init input parser
            p = inputParser;
            p.KeepUnmatched = true;
            
            vFunc = @(x) validateattributes(x, {'char'}, {'nonempty'});
            p.addParameter('name', 'l3 Train Wiener instance', vFunc);
            
            p.parse(varargin{:});
            obj.name = p.Results.name;
        end
        
        function obj = train(obj, l3d, varargin)
            % train method for l3TrainWiener
            %
            % Before using the code in parent class, we should set the
            % noise estimation function if l3d is of class l3DataISET
            %
            
            % check inputs
            if ieNotDefined('l3d'), error('data required'); end
            assert(isa(l3d, 'l3DataS'), 'Unsupported l3d type');
            
            % if l3d is of class l3DataISET, we set the noise estimation
            % function to the object
            % See also:
            %   L3findnoisevar
            if isa(l3d, 'l3DataISET')
                c = l3d.get('camera');
                
                dv = cameraGet(c, 'sensor/pixel/dark voltage'); % volts/sec
                et = cameraGet(c, 'sensor/exposure time'); % sec
                cg = cameraGet(c,'sensor/pixel/conversion gain');
                rn = cameraGet(c,'sensor/pixel/read NoiseVolts');
                prnu = cameraGet(c,'sensor/prnu sigma')/100; % percent
                dsnu = cameraGet(c, 'sensor/dsnu sigma'); % volts
                
                % set noise estimation function
                obj.noiseEstFunc = ...
                    @(x) ((dv*et)^2+cg*(x+dv*et)+rn^2)*(prnu^2+1) + ...
                         prnu^2 * x.^2 + dsnu^2 + ...
                         2*dv*et * x * prnu^2;
            end
            
            % use training code in parent class
            obj = train@l3TrainRidge(obj, l3d, varargin{:});
        end
        
    end
end