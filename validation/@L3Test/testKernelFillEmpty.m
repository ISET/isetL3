function testKernelFillEmpty(testCase)
% L3 Unittest: test l3TrainOLS.fillEmptyKernels method
%
% To run this test, call
%    run(L3Test, 'testKernelFillEmpty')
% 
% This function tests:
%   1) l3TrainOLS initialization
%   2) fillEmptyKernels override flag
%   3) fillEmptyKernels weigths
%   4) fillEmptyKernels linearity
%
% See also:
%   L3Test
%
% HJ, VISTA TEAM, 2016

% Initialize l3TrainOLS class
l3t = l3TrainOLS('name', 'test');
testCase.verifyEqual(l3t.name, 'test', 'initialize l3t name failed');

% set/get fundamental parameters
l3t.verbose = false;
l3t.l3c.verbose = false;
l3t.l3c.cutPoints = {1, 1};

% training on perfectly solvable data
% Here, we directly set data to l3t.l3c. This makes the testing independent
% of the correctness of classify and l3d implementation.
x = rand(1000, 25); coef = randn(25, 2); 
y1 = x * coef; y2 = x * (coef + 1);
l3t.l3c.p_data = {x', [], [], x'}; l3t.l3c.p_out = {y1', [], [], y2'};
l3t.train();

% test kernels for second and third class are empty
msg = 'Potential bugs in l3t.train';
testCase.verifyEmpty(l3t.kernels{2}, msg);
testCase.verifyEmpty(l3t.kernels{3}, msg);

% test override flag
msg = 'Potential bugs in l3t.fillEmptyKernels';
k = l3t.fillEmptyKernels([], false);

testCase.verifyEmpty(l3t.kernels{2}, msg);
testCase.verifyNotEmpty(k{3}, msg);

% test parameter: weights
k = l3t.fillEmptyKernels([1 0; 1 0], false);

testCase.verifyEqual(k{1}, k{2}, msg);
testCase.verifyEqual(k{1}, k{3}, msg);

% test linearity in the interpolation
k = l3t.fillEmptyKernels([], false);

testCase.verifyEqual(k{2}(2:end, :), k{1}(2:end, :)+0.5, ...
    'absTol', 1e-5, msg);
testCase.verifyEqual(k{2}, k{3}, msg);

end