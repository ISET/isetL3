function scene = L3AdjustSceneIlluminant(scene, camera)

% Change scene illuminant if it is different than used for training
%
%   scene = L3AdjustSceneIlluminant(scene, camera)
%
% Inputs: 
%   scene: the scene to modify
%   camera: the camera to be matched
%
% Outputs:
%   scene: The scene with modified illuminant
%
% See also: L3AdjustSceneWavelength
% 
% Example:
%   scene = L3AdjustSceneIlluminant(scene, camera)
%
% (c) Vistasoft Team 2013

if ieNotDefined('scene'), error('Specify the input scene'); end
if ieNotDefined('camera'), error('Specify the input camera'); end

%% Get scene illuminant and training scenes illuminant
testingilluminant = sceneGet(scene,'illuminant energy');

L3 = cameraGet(camera,'vci','L3');
trainingilluminant = L3Get(L3,'training illuminant');
trainingilluminant = trainingilluminant.data;

%% Normalize since the scale is adjusted later when setting mean luminance.
testingilluminant = testingilluminant/ mean(testingilluminant);
trainingilluminant = trainingilluminant/ mean(trainingilluminant);

percenterror = max(abs(trainingilluminant - testingilluminant')/ trainingilluminant);
if percenterror > .01
    warning(['Scene illuminant does not match illuminant used for testing.',...
            '  Now changing scene illuminant to make it match.'])
    scene = sceneAdjustIlluminant(scene, trainingilluminant');
end

end

