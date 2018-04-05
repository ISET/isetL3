function testKernelUniform(testCase)
% L3 Unittest: test l3TrainOLS.smoothKernels method
%
% To run this test, call
%    run(L3Test, 'testKernelUniform')
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
l3t.l3c.patchSize = [3 3];
l3t.l3c.cutPoints = {[], []}; % only differentiate by pixel type
l3t.l3c.p_data = cell(4, 1);  % four pixel types
l3t.l3c.p_out = cell(4, 1);

% randomize the kernels
l3t.kernels = cell(4, 1);
l3t.kernels{1} = rand(10, 3);
l3t.kernels{2} = rand(10, 3);
l3t.kernels{3} = rand(10, 3);
l3t.kernels{4} = rand(10, 3);

% apply uniform constraints
k = l3t.smoothKernels([], false);

% test whether uniform goes to uniform
testCase.verifyEqual(sum(k{1}), sum(k{2}), ...
    'absTol', 1e-10, 'Potential bugs in smoothKernels');

end