function camera = L3ModifyCameraFG(camera, cameraD65, opt)
%% To compute the illumination correction matrices, the filters and matrics
% are stored in a modified way in the training process. In oder to use the
% old rendering process conveniently, we need to modify the filters. It's
% dirty but convenient for now. We have to think out a clean way.
%
% options are as follows:
%       1: Some light to Some light
%       2: Some light to D65
%       3: Global correction
%
%
% (c) Stanford Vista Team 2014
%% Check inputs
switch nargin
  case 0
    error('Camera needed.')
  case 1
    error('CameraD65 needed.')
  case 2
    error('Option needed.')
end

L3 = cameraGet(camera, 'L3');
filters = L3Get(L3, 'filters');
L3D65 = cameraGet(cameraD65, 'L3');
filtersD65 = L3Get(L3D65, 'filters');

if opt >= 3 && opt < 6
  
  [ptrow, ptcol, ltsz, stsz] = size(filtersD65);
  
  for ii = 1 : ptrow
    for jj = 1 : ptcol
      for kk = 1 : ltsz
        for mm = 1 : stsz
          thisFilters = filtersD65{ii, jj, kk, mm};
          
          if (~isempty(thisFilters)) % if filters exit, we need to modify the data
            switch opt
              case 4
                % The L3 filters are now stored as a 6 by 81
                % matrix. The first three rows are filters
                % trained from some light to some light. Thus
                % we need to delete the last thee rows.
                thisFilters.global(4:6, :) = [];
                thisFilters.flat(4:6, :) = [];
                thisFilters.texture{1}(4:6, :) = []; % We only use one texture type
              case 3
                % Use the first three rows and modified using
                % the global correction matrix
                thisFilters.global(4:6, :) = [];
                thisFilters.flat(4:6, :) = [];
                thisFilters.texture{1}(4:6, :) = [];
                
                thisFilters.global = L3.globaltrM * thisFilters.global;
                thisFilters.flat = L3.globaltrM * thisFilters.flat;
                thisFilters.texture{1} = L3.globaltrM * thisFilters.texture{1};
              case 5
                % Use the first three rows and modified using
                % the global correction matrix
                thisFilters.global(4:6, :) = [];
                thisFilters.flat(4:6, :) = [];
                thisFilters.texture{1}(4:6, :) = [];
                try
                  thisFilters.global = L3.globaltrMFG * thisFilters.global;
                  thisFilters.flat = L3.globaltrMFG * thisFilters.flat;
                  thisFilters.texture{1} = L3.globaltrMFG * thisFilters.texture{1};
                catch err
                  thisFilters.global = L3.globaltrM * thisFilters.global;
                  thisFilters.flat = L3.globaltrM * thisFilters.flat;
                  thisFilters.texture{1} = L3.globaltrM * thisFilters.texture{1};
                end
              otherwise
                error('No such option');
            end
            filtersD65{ii, jj, kk, mm} = thisFilters;
          end
        end
      end
    end
  end
  
  L3D65.filters = filtersD65;
  camera.vci.L3 = L3D65;
  
else
  
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
                thisFilters.texture{1}(4:6, :) = []; % We only use one texture type
              case 2
                % Delete the first three rows to use the filters
                % trained from some light to D65
                thisFilters.global(1:3, :) = [];
                thisFilters.flat(1:3, :) = [];
                thisFilters.texture{1}(1:3, :) = [];
              case 6
                % Delete the first three rows to use the filters
                % trained from some light to D65
                thisFilters.global(4:6, :) = [];
                thisFilters.flat(4:6, :) = [];
                thisFilters.texture{1}(4:6, :) = [];
                
                thisFilters.global = L3.globaltrM * thisFilters.global;
                thisFilters.flat = L3.globaltrM * thisFilters.flat;
                thisFilters.texture{1} = L3.globaltrM * thisFilters.texture{1};
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


