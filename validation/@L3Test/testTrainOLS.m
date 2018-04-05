function testTrainOLS(testCase)
% L3 Unittest: test for l3TrainOLS.train method
%
% To run this test, call
%    run(L3Test, 'testTrainOLS')
% 
% This function tests:
%   1) l3TrainOLS initialization
%   2) parameters setting
%   3) training on perfectly solvable data
%   4) training on noisy data
%
% See also:
%   L3Test
%
% HJ, VISTA TEAM, 2016

% Initialize l3TrainOLS class
l3t = l3TrainOLS('name', 'test');
testCase.verifyEqual(l3t.name, 'test', 'initialize l3t name failed');

% set parameters
l3t.p_min = 0;
l3t.verbose = false;
testCase.verifyEqual(l3t.p_min, 0, 'l3t p_min set failed');

% training on perfectly solvable data
% Here, we directly set data to l3t.l3c. This makes the testing independent
% of the correctness of classify and l3d implementation.
x = rand(1000, 10); coef = randn(10, 2); y = x * coef;
l3t.l3c.p_data = {x'}; l3t.l3c.p_out = {y'};
l3t.train();

msg = 'Potential bugs in l3TrainOLS.train';
testCase.verifyEqual(l3t.kernels{1}(2:end, :), coef, 'absTol', 1e-5, msg);
testCase.verifyEqual(l3t.kernels{1}(1, :), [0 0], 'absTol', 1e-5, msg);

% training on noisy data
y = x * coef + 0.1 * randn(1000, 2); % additive white noise
l3t.l3c.p_data = {x'}; l3t.l3c.p_out = {y'};
l3t.train();
noise = bsxfun(@minus, y - x*l3t.kernels{1}(2:end,:), l3t.kernels{1}(1,:));

testCase.verifyEqual(mean(noise), [0 0], 'absTol', 1e-5, msg);
testCase.verifyEqual(std(noise), [0.1 0.1], 'absTol', 0.05, msg);
end