function camera = modifyCamera(camera, opt)

%% Check inputs
switch nargin
    case 0
        error('Camera needed.')
    case 1
        error('Option needed.')
end

filters = camera.vci.L3.filters;
[ptrow, ptcol, ltsz, stsz] = size(filters);

for ii = 1 : ptrow
    for jj = 1 : ptcol
        for kk = 1 : ltsz
            for mm = 1 : stsz
                thisFilters = filters{ii, jj, kk, mm};
                
                if (~isempty(thisFilters)) % if filters exit, we need to modify the data
                    switch opt
                        case 1
                            % The L3 filters are now stored as a 6 by 81
                            % matrix. The first three rows are filters
                            % trained from some light to some light. Thus
                            % we need to delete the last thee rows. 
                            thisFilters.global(4:6, :) = [];
                            thisFilters.flat(4:6, :) = [];
                            thisFilters.texture{1}(4:6, :) = [];
                        case 2
                            % Delete the first three rows to use the filters
                            % trained from some light to D65
                            thisFilters.global(1:3, :) = [];
                            thisFilters.flat(1:3, :) = [];
                            thisFilters.texture{1}(1:3, :) = [];
                        case 3
                            % Use the first three rows and modified using
                            % the global correction matrix
                            thisFilters.global(4:6, :) = [];
                            thisFilters.flat(4:6, :) = [];
                            thisFilters.texture{1}(4:6, :) = [];
                            
                            thisFilters.global=camera.vci.L3.globaltrM * thisFilters.global;
                            thisFilters.flat=camera.vci.L3.globaltrM * thisFilters.flat;
                            thisFilters.texture{1}= camera.vci.L3.globaltrM * thisFilters.texture{1};
                        case 4
                            % Use the first three rows and modified using
                            % the cluster dependent correction matrices
                            thisFilters.global(4:6, :) = [];
                            thisFilters.flat(4:6, :) = [];
                            thisFilters.texture{1}(4:6, :) = [];
                            
                            thisFilters.global=thisFilters.globaltrm*thisFilters.global;
                            thisFilters.flat=thisFilters.flattrm*thisFilters.flat;
                            thisFilters.texture{1}= thisFilters.texturetrm{1} * thisFilters.texture{1};
                        otherwise
                            error('No such option');
                    end
                    filters{ii, jj, kk, mm} = thisFilters;
                end  
            end
        end
    end
end

camera.vci.L3.filters = filters;
end

