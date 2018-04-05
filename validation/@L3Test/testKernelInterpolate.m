function testKernelInterpolate(testCase)
% L3 Unittest: test l3TrainOLS.interpolateKernels method
%
% To run this test, call
%    run(L3Test, 'testKernelInterpolate')
% 
% This function tests:
%   1) l3TrainOLS initialization
%   2) interpolate kernels to new cut points
%   3) extrapolate kernels
%
% See also:
%   L3Test
%
% HJ, VISTA TEAM, 2016

% Initialize l3TrainOLS class
l3t = l3TrainOLS('name', 'test');
l3t.verbose = false;
l3t.l3c.verbose = false;
l3t.l3c.cutPoints = {[1 3], []};
l3t.l3c.p_data = cell(3, 1);
l3t.l3c.p_out = cell(3, 1);

% randomize the kernels
data = rand(26, 3);
l3t.kernels{1} = data;
l3t.kernels{2} = data + 1;
l3t.kernels{3} = data + 2;

% interpolate
k = l3t.interpolateKernels({[1 2 3], []}, [], false);

% test interpolation results
msg = 'Potential bugs in interpolateKernels';
testCase.verifyEqual(k{1}, l3t.kernels{1}, 'absTol', 1e-8, msg);
testCase.verifyEqual(k{4}, l3t.kernels{3}, 'absTol', 1e-8, msg);
testCase.verifyLessThan(k{1}, k{2}, msg);
testCase.verifyLessThan(k{2}, k{3}, msg);

end