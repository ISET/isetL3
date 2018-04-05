function testPatchMax(testCase)
% L3 Unittest: test for imagePatchMax
%
% To run this test, call
%    run(L3Test, 'testPatchMax')
% 
% This function tests:
%   1) patch max with single channel
%   2) patch max with multiple channels
%
% See also:
%   L3Test
%
% HJ, VISTA TEAM, 2016

% Compute mean and contrast with single channel
% Here, patch size is specially designed. If you want to change it, you
% might need to change all other code in this function
cfa = 1; patchSz = [2 1];
raw = rand(100);
s = imagePatchMax(raw, cfa, patchSz);

% Test for mean and contrast with single channel
msg = 'Potential bugs in computing patch max';
expMax = reshape(max(raw(1:end-1, :), raw(2:end, :)), 1, []);
testCase.verifyEqual(s, expMax, 'absTol', 1e-8, msg);

% Test for mean and constrast with multiple channel on uniform input
cfa = [1 2; 3 4]; patchSz = [3 2];
s = imagePatchMax(raw, cfa, patchSz);

testCase.verifyEqual(s(1, 1), max(raw(1, 1), raw(3, 1)), msg);
testCase.verifyEqual(s(2, 1), max(raw(1, 2), raw(3, 2)), msg);
testCase.verifyEqual(s(3, 1), raw(2, 1), msg);
testCase.verifyEqual(s(4, 1), raw(2, 2), msg);

end