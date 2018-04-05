function testPatchMeanContrast(testCase)
% L3 Unittest: test for imagePatchMeanAndContrast
%
% To run this test, call
%    run(L3Test, 'testPatchMeanContrast')
% 
% This function tests:
%   1) patch mean and contrast with single channel
%   2) patch mean and contrast with multiple channels on uniform input
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
s = imagePatchMeanAndContrast(raw, cfa, patchSz);

% Test for mean and contrast with single channel
msg = 'Potential bugs in computing mean response level';
expMean = reshape((raw(1:end-1, :) + raw(2:end, :))/2, 1, []);
testCase.verifyEqual(s(1, :), expMean, 'absTol', 1e-8, msg);

expCont = std(RGB2XWFormat(cat(3, raw(1:end-1, :), raw(2:end, :))), 1, 2);
testCase.verifyEqual(s(2, :)', expCont, 'absTol', 1e-8, msg);

% Test for mean and constrast with multiple channel on uniform input
raw = ones(100); cfa = [1 2; 3 4]; patchSz = [5 3];
s = imagePatchMeanAndContrast(raw, cfa, patchSz);

testCase.verifyEqual(s(1, :), ones(1, size(s, 2)), msg);
testCase.verifyEqual(s(2, :), zeros(1, size(s, 2)), msg);

end