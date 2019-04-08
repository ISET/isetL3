function [rawInterp, pTypeInterp] = sensorInterpolation(raw, pType, l3dSR)

rawInterp = cell(1, length(raw));
pTypeInterp = cell(1, length(pType));
for ii=1:length(raw)
    curSensorData = raw{ii};
    interpSensorData = zeros(size(curSensorData)*l3dSR.upscaleFactor);
    
    uniPType = unique(pType{ii});

    interpedPType = cfa2ptype(size(l3dSR.cfa), size(interpSensorData));
    pTypeInterp{ii} = interpedPType;
    for jj=1:length(uniPType)
        thisTypeData = reshape(curSensorData(pType{ii} == uniPType(jj)), [size(curSensorData)./size(l3dSR.cfa)]);
        interpThisTypeData = imresize(thisTypeData, size(thisTypeData)*l3dSR.upscaleFactor, 'bicubic');
        interpSensorData(interpedPType == uniPType(jj)) = interpThisTypeData;
    end
    
    rawInterp{ii} = interpSensorData;
end

end