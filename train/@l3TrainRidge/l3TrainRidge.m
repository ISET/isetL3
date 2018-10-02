classdef l3TrainRidge < l3TrainOLS
    % l3Train class with ridge-regression
    %
    % This class implements the L3 training process using ridge regression.
    %
    % See also:
    %   l3TrainOLS, l3TrainS
    %
    % HJ/BW (c) Stanford VISTA Team 2015
    
    properties (Access = public)
        lambda % ridge regression parameter
    end
    
    methods (Access = public)
        function obj = l3TrainRidge(varargin)
            % l3TrainRidge class constructor
            %
            % Inputs:
            %   varargin - name value pairs for this class
            %
            
            % Construct base class
            obj = obj@l3TrainOLS(varargin{:});
            
            % Init input parser
            p = inputParser;
            p.KeepUnmatched = true;
            p.addParameter('lambda', nan);
            
            vFunc = @(x) validateattributes(x, {'char'}, {'nonempty'});
            p.addParameter('name', 'l3 Train Ridge instance', vFunc);
            
            p.parse(varargin{:});
            
            obj.lambda = p.Results.lambda;
            obj.name = p.Results.name;
        end
    end
    
    methods (Access = protected)
        function [kernels, p_val] = learnClassKernel(obj, X, y, label)
            % Learn linear kernel by ridge regression
            %   [kernels, p_val] = learnClassKernel(obj, X, y, label)
            %
            % Inputs:
            %   X, y  - Input and output data matrix
            %   label - classID
            %
            % Output:
            %   kernels - learned linear transform kernel (beta)
            %   p_val   - p-val of kernel (not implemented for ridge)
            %
            % Notes:
            %   The ridge regession is defined as
            %       beta = argmin |y-X*beta|^2 + lambda*|beta|^2
            %
            %   The closed form solution is given as
            %       beta = inv(X'*X + lambda)*X'*y
            %
            %   By SVD, we can avoid the matrix inversion and estimate the
            %   coefficients as
            %       [U, D, V'] = svd(X); d = diag(D);
            %       beta = V * diag(d./(d.^2 + lambda))*U'*y
            % 
            %   When there are multiple channels in y, as for a color
            %   image, we process each channel independently
            %
            %   If lambda is unspecified, we choose lambda that minimizes
            %   the generalized cross-validation (GCV) error. See
            %   lambdaGCV for more details.
            % 
            % HJ, Stanford Vista Team, 2015
            
            % Get regularization parameter (lambda) for current class
            if size(obj.lambda, 1) == 1
                obj.lambda = repmat(obj.lambda, [obj.l3c.nLabels 1]);
            end
            if size(obj.lambda, 2) == 1
                obj.lambda = repmat(obj.lambda, [1 obj.l3c.nChannelOut]);
            end
            l = obj.lambda(label, :);
            
            % SVD of X
            kernels = zeros(size(X, 2), size(y, 2));
            [U, D, V] = svd(X, 0); d = diag(D); % svd of X            
            
            % Choose lambda if not specified
            for c = 1 : size(y, 2)
                if isnan(l(c))
                    l(c) = obj.lambdaGCV(X, y(:, c));
                    obj.lambda(label, c) = l(c);
                end
            end
            
            % Learn kernel
            for c = 1 : size(y, 2)
                % process for each channel
                kernels(:, c) =  V * diag(d./(d.^2 + l(c)))*(U'*y(:, c));
            end
            
            %{
                % Exam the linearity of the kernels
                y_pred  = X * kernels;
                thisChannel = 2;
                vcNewGraphWin; plot(y(:,thisChannel), y_pred(:,thisChannel), 'o');
                axis square;
                identityLine;
            %}
            
            p_val = nan(size(kernels));
        end
        
        function [lambda, lList, gcvErr] = lambdaGCV(~, X, y, lList)
            % Choose regularization parameter with GCV (generalized cross
            % validation).  Used for learning the kernel (see above).
            %
            %    [lambda, lambdaList, gcvErr] = lambdaGCV(X, [lambdaList])
            %
            % Inputs:
            %   X, y   - Input matrix and output vector
            %   lList  - list of lambda values to be tested
            %
            % Outputs:
            %   lambda - lambda value with smallest GCV error
            %   lList  - list of lambda values tested
            %   gcvErr - list of GCV error for each lambda tested
            %
            % Notes:
            %   GCV error is computed as
            %       (y_hat = S*y) 
            %       mean((y-S*y).^2)/(1-trace(S)/size(y,1))^2
            %   By using SVD, we can write S as
            %       S = U * diag(d.^2 ./ (d.^2 + lambda)) * U'
            %   The size of S can be large when we have many
            %   samples. To save memory, we compute yHat and trace(S) as
            %       yHat = U * diag(d.^2 ./ (d.^2 + lambda)) * (U' * y)
            %       traceS = sum(d.^2 ./ (d.^2 + l))
            %       
            % HJ, VISTA TEAM, 2015
            
            % Check inputs
            if notDefined('lList'), lList = [0 logspace(-3, -1, 20)]; end
            
            % SVD of X
            [U, D, ~] = svd(X, 0); d = diag(D);
            
            % Compute GCV for each lambda
            gcvErr = zeros(length(lList), 1);
            for ii = 1 : length(lList)
                l = lList(ii); % current lambda
                yHat = U * diag(d.^2 ./ (d.^2 + l)) * (U' * y);
                traceS = sum(d.^2 ./ (d.^2 + l));
                gcvErr(ii) = mean((y-yHat).^2)/(1-traceS/size(y,1))^2;
            end
            
            % Choose lambda that minimize GCV error
            [~, indx] = min(gcvErr);
            lambda = lList(indx);
        end
    end
end