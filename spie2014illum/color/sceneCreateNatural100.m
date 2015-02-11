function [scene,parms] = sceneCreateNatural100(varargin)
% Create a Natural-100 color chart.
%
%  [scene,parms] = sceneCreateNatural100(pSize,grayFlag); 
% There is always a gray strip at the right.
%
% See also:  sceneFromFile, sceneCreate
%
% Copyright ...

sceneName = 'natural100';
parms = [];  % Returned in some cases, not many.

% Identify the object type
scene.type = 'scene';
scene = sceneSet(scene,'bit depth',32);   % Single precision
if length(varargin) > 1 && ischar(varargin{end-1})
    str = ieParamFormat(varargin{end-1});
    if isequal(str,'bitdepth')
        scene = sceneSet(scene,'bit depth',varargin{end}); 
    end
end
sceneName = ieParamFormat(sceneName);

% sceneCreate('nature100',pSize,grayFlag); 
% There is always a gray strip at the right.

% Defaults
pSize = 24;     % Patch size in pixels
grayFlag = 1;   % Add a gray strip column on right

if isempty(varargin)
    recomputeFlag = false;
else
    recomputeFlag = varargin{1};
    if length(varargin) > 1, pSize = varargin{2}; end
    if length(varargin) > 2, grayFlag = varargin{3}; end            
end

if recomputeFlag
    [reflectances, wave] = computeNatural100samples();
else
    load('reflectancesNatural100.mat','reflectances','wave')
end
    
scene = sceneReflectanceChart(reflectances',[],pSize,wave,grayFlag,'r');

% Initialize scene geometry, spatial sampling
scene = sceneInitGeometry(scene);
scene = sceneInitSpatial(scene);

% Scenes are initialized to a mean luminance of 100 cd/m2.  The illuminant
% is adjusted so that dividing the radiance (in photons) by the illuminant
% (in photons) produces the appropriate peak reflectance (default = 1).
%
% Also, a best guess is made about one known reflectance.
if checkfields(scene,'data','photons') && ~isempty(scene.data.photons)
    
    if isempty(sceneGet(scene,'knownReflectance')) && checkfields(scene,'data','photons')
        
        % nWave = sceneGet(scene,'nWave');
        
        % If there is no illuminant yet, set the illuminant to equal
        % photons at 100 cd/m2.
        if isempty(sceneGet(scene,'illuminant'))
            il = illuminantCreate('equal photons',sceneGet(scene,'wave'),100);
            scene = sceneSet(scene,'illuminant',il);
        end
        
        % There is no knownReflectance, so we set the peak radiance to a
        % reflectance of 0.9.
        v = sceneGet(scene,'peakRadianceAndWave');
        wave = sceneGet(scene,'wave');
        idxWave = find(wave == v(2));
        p = sceneGet(scene,'photons',v(2));
        [tmp,ij] = max2(p); %#ok<ASGLU>
        v = [0.9 ij(1) ij(2) idxWave];
        scene = sceneSet(scene,'knownReflectance',v);
    end
    
    luminance = sceneCalculateLuminance(scene);
    scene = sceneSet(scene,'luminance',luminance);
    
    % This routine also adjusts the illumination level to be consistent
    % with the reflectance and scene photons.
    scene = sceneAdjustLuminance(scene,100);
end

return;
