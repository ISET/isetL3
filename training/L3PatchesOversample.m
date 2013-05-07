function L3 = L3PatchesOversample(L3,oversample)
%
%
% Oversample the sensor patches and ideal
%
% In the future we might replace this with:
%   L3Get(L3,'sensor patches',oversample)
%   L3Get(L3,'ideal vector',oversample)
% Not sure yet.  
%
% 
% Copyright Stanford VISTA team  2012

if ieNotDefined('L3'), error('L3 required'); end
if ieNotDefined('oversample'),  error('oversample required'); end

patches = L3Get(L3,'sensor patches');
patches = repmat(patches,1,oversample);
L3 = L3Set(L3,'sensor patches',patches);

iVec = L3Get(L3,'ideal vector');
iVec = repmat(iVec,1,oversample);
L3 = L3Set(L3,'ideal vector',iVec);

end