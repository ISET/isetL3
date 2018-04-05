classdef L3Test < matlab.unittest.TestCase
    % Unit test class for L3
    % 
    % This class contains unit test for various functions and data storage
    % of L3 method
    %
    % To run all the test case, call
    %    run(L3Test);
    %
    % To run one specific test, call
    %    run(L3Test, testName)
    %
    % Currently, testName can be chosen from
    %   
    %   'testDataRDT'           - test get data with remote data toolbox
    %   'testDataCamera'        - test l3DataCamera class
    %   'testDataISET'          - test l3DataISET class
    %   'testDataSimulation'    - test l3DataSimulation class
    %
    %   'testClassify'          - test l3ClassifyFast.classify method
    %   'testClassifyMethods'   - test other l3ClassifyFast methods
    %   'testClassifyParams'    - test parameters of l3ClassifyFast class
    %
    %   'testPatchMeanContrast' - test routine used to compute patch mean
    %   'testPatchMax'          - test routine used to compute saturation
    %
    %   'testTrainOLS'          - test train method in l3TrainOLS class
    %   'testTrainRidge'        - test train method in l3TrainRidge class
    %   'testTrainMethods'      - test other methods in l3TrainOLS
    %   'testTrainParams'       - test parameters of l3TrainOLS class
    %
    %   'testKernelSymmetry'    - test l3TrainOLS.symmetricKernels method
    %   'testKernelFillEmpty'   - test l3TrainOLS.fillEmptyKernels method
    %   'testKernelInterpolate' - test l3TrainOLS.interpolateKernels method
    %   'testKernelUniform'     - test l3TrainOLS.smoothKernels
    %
    %   'testRender'            - test l3Render class
    %
    % 
    % HJ, VISTA TEAM, 2016
    
    methods(Test)
        % data related test
        testDataRDT(testCase);
        testDataCamera(testCase);
        testDataISET(testCase);
        testDataSimulation(testCase);
        
        % classify related test
        testClassify(testCase);
        testClassifyParams(testCase);
        testClassifyMethods(testCase);
        
        % classify related utility function test
        testPatchMeanContrast(testCase);
        testPatchMax(testCase);
        
        % training related test
        testTrainOLS(testCase);
        testTrainRidge(testCase);
        testTrainMethods(testCase);
        testTrainParams(testCase);
        
        % kernel post-processing functions test
        testKernelSymmetry(testCase);
        testKernelFillEmpty(testCase);
        testKernelInterpolate(testCase);
        testKernelUniform(testCase);
        
        % rendering related test
        testRender(testCase);
    end
end