function [rawInterp, pTypeInterp] = sensorInterpolation(raw, pType, l3dSR)

rawInterp = cell(1, length(raw));
pTypeInterp = cell(1, length(pType));
for ii=1:length(raw)
    curSensorData = raw{ii};
    interpSensorData = zeros(size(curSensorData)*l3dSR.upscaleFactor);
    
    uniPType = unique(pType);

    interpedPType = cfa2ptype(size(l3dSR.cfa), size(interpSensorData));
    pTypeInterp{ii} = interpedPType;
    for jj=1:length(uniPType)
        thisTypeData = curSensorData(pType == uniPType(jj));
        interpThisTypeData = imresize(thisTypeData, size(thisTypeData)*l3dSR.upscaleFactor, 'bilinear');
        interpSensorData(interpedPType == uniPType(jj)) = interpThisTypeData;
    end
    
    rawInterp{ii} = interpSensorData;
end

end