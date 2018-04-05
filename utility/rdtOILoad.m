function ois = rdtOILoad(varargin)
% Load optical images using Remote Data Toolbox as cell array
%
%   OIs = rdtOILoad(varargin)
%
% Inputs:
%   varargin - name value pairs for the parameters
%
% Outputs:
%   ois      - cell array of optical images
%
% Examples:
%     ois = rdtOILoad();
%     ois = rdtOILoad('nOI', 5); % Loads 5 optical images
%
%     
% See also:
%   rdtScenesLoad
% 
% HJ/BW, VISTA TEAM, 2015

%% Parse input parameters
p = inputParser;
p.addParameter('nOI', inf);
p.addParameter('wave', 400:10:700);
p.addParameter('rdtConfigName', 'scien');
p.addParameter('fov', []);
p.parse(varargin{:});

nOI     = p.Results.nOI;
wave    = p.Results.wave;
rdtName = p.Results.rdtConfigName;
fov     = p.Results.fov;

%% Init remote data toolbox client
rdt = RdtClient(rdtName);  % using rdt-config-scien.json configuration file
rdt.crp('/L3/CISET_OI');
files = rdt.listArtifacts();
nOI = min(nOI, length(files));

% If number of oi required is less than 1, we return an empty set
if nOI <= 0, ois = {}; return; end

% load OI files
ois = cell(nOI, 1);
for ii = 1 : nOI
    data = rdt.readArtifact(files(ii).artifactId);
    oi = oiSet(data.oi, 'wave', wave); % adjust wavelength
    if ~isempty(fov), oi = oiSet(oi, 'h fov', fov); end
    ois{ii} = oi;
end

end