function testRender(testCase)
% L3 Unittest: test for l3Render.render method
%
% To run this test, call
%    run(L3Test, 'testRender')
% 
% This function tests:
%   1) Initialize the l3Render class
%   2) Setting parameters
%   3) Render image with random kernels
%
% See also:
%   L3Test
%
% HJ, VISTA TEAM, 2016

% Initialize l3Render class
l3r = l3Render('name', 'test');
testCase.verifyEqual(l3r.name, 'test', 'initialize l3r name failed');

% randomize l3 transform kernels
l3t = l3TrainOLS;
l3t.l3c.cutPoints = {[], []}; % classify only based on pixel types
l3t.kernels = {rand(26, 3), rand(26, 3), rand(26, 3), rand(26, 3)};

% render
raw = rand(100);
out = l3r.render(raw, [1 2; 3 4], l3t);

% verify whether render function gives expected results
expRes = reshape([1 reshape(raw(1:5, 1:5),1,[])]*l3t.kernels{1}, [1 1 3]);
testCase.verifyEqual(out(1, 1, :), expRes, 'absTol', 1e-8, ...
    'Potential bugs in l3Render.render');
end