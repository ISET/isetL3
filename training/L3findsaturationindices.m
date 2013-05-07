function saturationindices = L3findsaturationindices(saturationcases, ...
                                        desiredsaturationcase)

% Finds indices for patches that match a desired saturation case
%
% saturationindices = L3findsaturationindices(saturationcases, ...
%                                         desiredsaturationcase)
%
% saturationcases:  Binary matrix where each column gives the saturation
%                   case for the corresponding patch. The number of rows is
%                   equal to the number of color channels in the CFA.  The
%                   entry is 1 if the corresponding color channel is
%                   saturated for a patch.
%
% desiredsaturationcase: Binary column vector giving the saturation case to
%                        look for
%
% The desired saturation case is stored in L3 as indicated by the
% saturation type as a pointer into the proper column in the L3
% structures's saturation list.
%
% Example:
%   saturationtype = L3Get(L3,'saturation type');
%   desiredsaturationcase = L3Get(L3,'saturation list',saturationtype);
%   saturationindices = L3findsaturationindices(saturationcases, ...
%                                          desiredsaturationcase);

        
saturationindices = true(1,size(saturationcases,2));
for filternum = 1 : length(desiredsaturationcase)
    saturationindices = saturationindices & (saturationcases(filternum,:) == ...
                 desiredsaturationcase(filternum));
end