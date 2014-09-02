function camera = L3ModifyCameraFG(camera)
L3 = cameraGet(camera, 'L3');
filters = L3Get(L3, 'filters');
load('T2D');
[ptrow, ptcol, ltsz, stsz] = size(filters);

for ii = 1 : ptrow
    for jj = 1 : ptcol
        for kk = 1 : ltsz
            for mm = 1 : stsz
                thisFilters = filters{ii, jj, kk, mm};
                if (~isempty(thisFilters))
                    thisFilters.global = T2D * thisFilters.global;
                    thisFilters.flat = T2D * thisFilters.flat;
                    thisFilters.texture{1} = T2D * thisFilters.texture{1};
                    filters{ii, jj, kk, mm} = thisFilters;
                end
            end
        end
    end
end

camera.vci.L3.filters = filters;
end