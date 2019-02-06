function fitPatch = fitPatchPattern(patchSz, thisCenterPixel, inCfa)

%% Set parameters
row = patchSz(1); col = patchSz(2);
[rCfa, cCfa] = size(inCfa);
nPType = numel(inCfa);
centerPos = ceil(patchSz / 2); rCenter = centerPos(1); cCenter = centerPos(2);
%%
fitPatch = zeros(patchSz);

fitPatch(rCenter, cCenter) = thisCenterPixel;

for cc = 1 : col
    fitPatch(rCenter, cc) = thisCenterPixel + (cc-cCenter)*cCfa;
    if fitPatch(rCenter, cc) <= 0
        while fitPatch(rCenter, cc) <= 0
            fitPatch(rCenter, cc) = fitPatch(rCenter, cc) + nPType;
        end
    elseif fitPatch(rCenter, cc) > nPType
        fitPatch(rCenter, cc) = mod(fitPatch(rCenter, cc), nPType);
        if fitPatch(rCenter, cc) == 0
           fitPatch(rCenter, cc) = fitPatch(rCenter, cc) + nPType;
        end
    end
end

for rr = 1 : row
    for cc = 1 : col
        if fitPatch(rr, cc) ==0
            whichCol = ceil(fitPatch(rCenter, cc)/cCfa);
            fitPatchTmp = fitPatch(rCenter, cc) + (rr - rCenter);
            fitPatchTmp = fitPatchTmp + (whichCol - ceil(fitPatchTmp/cCfa)) * cCfa;
            fitPatch(rr, cc) = fitPatchTmp;
        end
    end
end

end