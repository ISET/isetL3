function pMatrix = L3sensorPlane2Patch(sensorPlane,patchSize,xPos,yPos)

% Compute  patches from sensor plane
%
% pMatrix = L3sensorPlane2Patch(sensorPlane,patchSize,xPos,yPos)
%
% Group the sensor patches surrounding each xPos,yPos into the pMatrix
% For each xPos and yPos, find the surrounding patch.


%% Create matrix of patch data used for processing or testing

pMatrix = zeros(length(yPos),length(xPos),patchSize*patchSize);
shift = (1:patchSize) - ceil(patchSize/2);
for rr=1:length(yPos)
    theseY = yPos(rr) + shift;
    for cc=1:length(xPos);
        theseX = xPos(cc) + shift;
        tmp = sensorPlane(theseY,theseX);
        pMatrix(rr,cc,:) = tmp(:);
    end
end

% hcimage(pMatrix);  hcimage(pMatrix,'image montage');
% hcimage(pMatrix,'movie');

end