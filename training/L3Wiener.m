function filters=L3Wiener(inputs,outputs,noisevar)
% Calculates Wiener filters (best linear filters given noise power)
%
%       filters = L3Wiener(intputs,outputs,noisevar)
%
%INPUTS:
%   inputs:     matrix of noise-free measurements, each column is
%               independent observation (size(inputs) = number of input
%               variables x number of observations)
%   outputs:    matrix of desired outputs values, columns correspond with
%               columns of inputs (size(outputs) = number of output
%               variables x number of observations)
%   noisevar:   variance of noise added to each input variable, two forms: 
%                   -vector of variances assuming independent noise for each
%                    input variable (length=number of input variables)
%                   -square matrix that gives noise covariance
%
%OUTPUTS:
%   filters:     matrix giving Wiener filters, estimated output=filters*inputs
%               (size(filters)=number of output variables x number of input 
%               variables)
%
% Copyright Steven Lansel, 2010

if any(size(noisevar)==1), noisevar=diag(noisevar); end

filters=((inputs*inputs'+noisevar)\(inputs*outputs'))';

%  Above line is equivalent to the following:
%     A=inputs*inputs'+diag(noisevar);
%     b=inputs*outputs';
%     filters=(A\b)'=b'/A;
% There is an equivalent calculation using the pseudoinverse.  But the
% peudoinverse approach is much slower, and there are potential problems if
% the input matrix is not full rank.

end
