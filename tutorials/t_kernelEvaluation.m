% t_kernelEvaluation
%% Init the isetcam environment
ieInit

%% l3Data class
% Init data class

% The default is to use scene data that are stored on the RemoteDataToolbox
% in /L3/faces.  We should generalize this with more uploads to the RDT
% site and a simple parameter here that would specify the alternative
% training data.
l3d = l3DataISET();   

% Set up parameters for boosting the training data. The variations in the
% scene illuminant level and SPD are established here.
l3d.illuminantLev = [50 10 80]; %[50 10 80 100 110 120 150 160 170 180];
l3d.inIlluminantSPD = {'D65'};
l3d.outIlluminantSPD = {'D65'};

%% Training

% Create training class instance.  The other possibilities are l3TrainOLS
% and l3TrainWiener.
l3t = l3TrainRidge();

% set training parameters for the lookup tables.  These are the number and
% spacing of the response levels, and the training patch size
l3t.l3c.cutPoints = {logspace(-1.7, -0.12, 30), []};
l3t.l3c.patchSize = [5 5];
%l3t.l3c.channelName = ["g1", "r", "b", "g2", "w"];
% Invoke the training algorithm
l3t.l3c.satClassOption = 'none';
l3t.train(l3d);

%% Check the training result

mse = u_kernelEvaluation(l3t);
