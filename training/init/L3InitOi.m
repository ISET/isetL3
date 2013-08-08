function L3 = L3InitOi(L3)

% Initialize oi (optics) with default parameters.
%
%   L3 = L3InitOi(L3)
%
% The default settings for the optics are
%   
%   F number is set to 4 
%   Focal length is set to 3e-3 (3mm)
%
% (c) Stanford VISTA Team 2013


%% Create oi and set defaults
oi = oiCreate;
optics = oiGet(oi,'optics');

% Set optics parameters
fnumber = 4; % F number
optics = opticsSet(optics,'f number',fnumber);

focallength = 3e-3;  % focal length (units are meters)
optics = opticsSet(optics,'focal length',focallength);   % units are meters

oi = oiSet(oi,'optics',optics);
oi = oiSet(oi,'name','L3 default optics');

%% Store in L3 structure
L3 = L3Set(L3,'oi',oi);
