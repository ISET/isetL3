function testDataISET(testCase)
% L3 Unittest: test for l3DataISET class
%
% To run this test, call
%    run(L3Test, 'testDataISET')
% 
% This function tests:
%   1) Initialize the l3DataISET class
%   2) Set parameters to l3DataISET object
%   3) Read out data from the class object (dataGet method)
%
% See also:
%   L3Test
%
% HJ, VISTA TEAM, 2016

% Initialize l3DataCamera class
l3d = l3DataISET('nScenes', 1, 'name', 'test');
testCase.verifyInstanceOf(l3d, 'l3DataS');
testCase.verifyEqual(l3d.name, 'test');

% Set parameters
l3d.inIlluminantSPD = {'D65'};
l3d.outIlluminantSPD = {'D65'};
l3d.illuminantLev = [1 100];
l3d.verbose = false;

testCase.verifyEqual(l3d.illuminantLev, [1 100], ...
    'illuminant levels set failed');

% Test dataGet function
[in, ~] = l3d.dataGet(1);
testCase.verifyNumElements(in, 2, 'Unexpected number of data');

end