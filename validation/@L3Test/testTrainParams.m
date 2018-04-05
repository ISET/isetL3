function testTrainParams(testCase)
% L3 Unittest: test for l3TrainOLS parameters
%
% To run this test, call
%    run(L3Test, 'testTrainParams')
% 
% This function tests:
%   1) l3TrainOLS initialization
%   2) fundamental parameters set / get
%   3) dependent parameters set / get
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
l3t.outChannelNames = {'test1', 'test2'};
testCase.verifyEqual(l3t.p_min, 0, 'l3t p_min set failed');
testCase.verifyEqual(length(l3t.outChannelNames), 2, ...
    'l3t outChannelNames set failed');

% test dependent variable - nChannelOut
x = rand(1000, 10); coef = randn(10, 2); y = x * coef;
l3t.l3c.p_data = {x'}; l3t.l3c.p_out = {y'};

testCase.verifyEqual(l3t.l3c.nChannelOut, 2, 'l3t nChannelOut incorrect');
testCase.verifyEqual(l3t.nChannelOut, 2, 'l3t nChannelOut incorrect');

l3t.train();
l3t.l3c.clearData();

testCase.verifyEqual(l3t.nChannelOut, 2, 'l3t nChannelOut incorrect');
testCase.verifyNotEqual(l3t.l3c.nChannelOut, 2, 'Unexpected nChannelOut');

end