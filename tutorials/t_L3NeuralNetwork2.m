% This tutorial shows how to generate the data that are needed for Neural
% Network training process. In this function, we will first use l3Data
% class to generate the raw data from the sensor, then transfer it into
% patches vector by using raw2PatchVecFormat function. The "label"
% (groundtruth) is generated with function: RGB2patchVecFormat. We feed the
% function with the groundtruth (target image), transfer the image into a
% flattened vector. After training, the output vector (predicted image)
% will be sent to the function: patchVec2RGBFormat function. The function
% will transfer the vector back into the image which will be compared with
% the target image. (To be completed).

%% l3d class data
l3d = l3DataISET();

l3d.illuminantLev = [50 10 80];
l3d.inIlluminantSPD = {'D65'};
l3d.outIlluminantSPD = {'D65'};

