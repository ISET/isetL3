function testTrainRidge(testCase)
% L3 Unittest: test for l3TrainRidge.train method
%
% To run this test, call
%    run(L3Test, 'testTrainRidge')
% 
% This function tests:
%   1) l3TrainRidge initialization
%   2) parameters setting
%   3) training on perfectly linear data with lambda auto selected
%   4) training with very large lambda
%
% See also:
%   L3Test
%
% HJ, VISTA TEAM, 2016

% Initialize l3TrainRidge class
l3t = l3TrainRidge('name', 'test');
testCase.verifyEqual(l3t.name, 'test', 'initialize l3t name failed');

% set parameters
l3t.p_min = 0;
l3t.verbose = false;
testCase.verifyEqual(l3t.p_min, 0, 'l3t p_min set failed');

% training on perfectly linear data with lambda auto selected
% Here, we directly set data to l3t.l3c. This makes the testing independent
% of the correctness of classify and l3d implementation.
x = rand(1000, 10); coef = randn(10, 2); y = x * coef;
l3t.l3c.p_data = {x'}; l3t.l3c.p_out = {y'};
l3t.train();

msg = 'Potential bugs in l3TrainRidge.train';
testCase.verifyEqual(l3t.lambda, [0 0], msg);
testCase.verifyEqual(l3t.kernels{1}(2:end, :), coef, 'absTol', 1e-5, msg);
testCase.verifyEqual(l3t.kernels{1}(1, :), [0 0], 'absTol', 1e-5, msg);

% training with large lambda, learned coefficients should shrink to zero
l3t.lambda = 1e5;
l3t.train();

testCase.verifyLessThan(std(l3t.kernels{1}), [0.05 0.05], msg);

end