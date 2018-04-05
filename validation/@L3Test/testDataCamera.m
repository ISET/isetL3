function testDataCamera(testCase)
% L3 Unittest: test for l3DataCamera class
%
% To run this test, call
%    run(L3Test, 'testDataCamera')
% 
% This function tests:
%   1) Initialize and set parameters of the l3DataCamera class
%   2) Adding more data to the class object (dataAdd method)
%   3) Read out data from the class object (dataGet method)
%
% See also:
%   L3Test
%
% HJ, VISTA TEAM, 2016

% Setup input and output images
inSz = [2 2]; outSz = [4 4 2]; % input and output image size

inImg = {rand(inSz)}; outImg = {rand(outSz)};
cfa = [1 2];

% Initialize l3DataCamera class
l3d = l3DataCamera(inImg, outImg, cfa, 'name', 'test');
testCase.verifyInstanceOf(l3d, 'l3DataS');
testCase.verifyEqual(l3d.name, 'test');

% Test adding more data
l3d.dataAdd(rand(inSz), rand(outSz));
l3d.dataAdd({rand(inSz), rand(inSz)}, {[], []});

testCase.verifyNumElements(l3d.inImg, 4, 'Unexpected number of data');

% Test dataGet function
[in, out] = l3d.dataGet(1);
testCase.verifyNumElements(in, 1, 'Unexpected number of data');
testCase.verifyEqual(in{1}, inImg{1}, 'Unexpected data from dataGet');
testCase.verifyEqual(out{1}, outImg{1}, 'Unexpected data from dataGet');

end