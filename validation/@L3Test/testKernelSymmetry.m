function testKernelSymmetry(testCase)
% L3 Unittest: test l3TrainOLS.symmetricKernels method
%
% To run this test, call
%    run(L3Test, 'testKernelSymmetry')
% 
% This function tests:
%   1) l3TrainOLS initialization
%   2) Test override flag
%   2) Up down symmetry
%   3) Left right symmetry
%
% See also:
%   L3Test
%
% HJ, VISTA TEAM, 2016

% Initialize l3TrainOLS class
l3t = l3TrainOLS('name', 'test');
testCase.verifyEqual(l3t.name, 'test', 'initialize l3t name failed');

% set/get fundamental parameters
l3t.p_min = 0;
l3t.verbose = false;
testCase.verifyEqual(l3t.p_min, 0, 'l3t p_min set failed');

% training on perfectly solvable data
% Here, we directly set data to l3t.l3c. This makes the testing independent
% of the correctness of classify and l3d implementation.
x = rand(1000, 25); coef = randn(25, 2); y = x * coef;
l3t.l3c.p_data = {x'}; l3t.l3c.p_out = {y'};
l3t.train();
k = l3t.kernels{1};
k_sym = l3t.symmetricKernels([2 1; 3 2], false);
k_sym = k_sym{1};

% test override flag
msg = 'Potential bugs in l3t.symmetricKernels';
testCase.verifyNotEqual(k, k_sym, msg);

% test up-down symmetry
k_sym = reshape(k_sym(2:end, 2), [5 5]);
testCase.verifyEqual(k_sym, flipud(k_sym), msg);

% test left-right symmetry
testCase.verifyEqual(k_sym, fliplr(k_sym), msg);

end