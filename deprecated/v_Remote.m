%% Validate interactions with the SCIEN repository on the RDT
%

%% Create the object and open browser
rd = RdtClient('isetbio');

% You need to run this once.
rd.credentialsDialog;

%% Change the default remote path to L3

% Watch the browser open there
rd.openBrowser;

%%  BW:  Put the ISETBIO/MULTISPECTRAL data to multiband/2004 ...
%        Just the mat files.  Inside of the ISETBIO repository

% Choose one of these
cd('/wandellfs/data/validation/SCIEN/ISETBIO/MULTISPECTRAL/2004')
rd.crp('/resources/scenes/multiband/scien/2004');

cd('/wandellfs/data/validation/SCIEN/ISETBIOp/MULTISPECTRAL/2008')
rd.crp('/resources/scenes/multiband/scien/2008');

cd('/wandellfs/data/validation/SCIEN/ISETBIO/MULTISPECTRAL/2009')
rd.crp('/resources/scenes/multiband/scien/2009');

matDir = pwd;
files = dir('*.mat');% All the mat-files in the directory
fileVersion = '1';   % A character, oddly

% Look into using publishArtifacts instead of this
% Why is there only one / in the artifact.url?  We need http://
for ii=1:length(files)
    matFileName = files(ii).name;
    matFileFull = fullfile(matDir,matFileName);
    fprintf('Writing %s (version %s)\n',matFileName,fileVersion);
    
    % supply the configuration, which now contains publishing credentials
    artifact = rd.publishArtifact(matFileFull, ...
        'version', fileVersion, ...
        'description', 'Multiband data from JEF.', ...
        'name', matFileName);
end

%% Now put the zip file with all of the individual files on the server
matDir = '/wandellfs/data/validation/SCIEN/ISETBIO/MULTISPECTRAL/2004';
cd(matDir)
rd.crp('/resources/scenes/multiband/scien/2004');

zipFileFull = fullfile(matDir,'Scenes2004.zip');
zipArtifact = rd.publishArtifact(zipFileFull, ...
    'version', fileVersion, ...
    'description', 'All the multiband scenes in 2004 from JEF.', ...
    'name', 'Scenes2004.zip');
zipArtifact.url

%% Now put the zip file with all of the individual files on the server

matDir = '/wandellfs/data/validation/SCIEN/ISETBIO/MULTISPECTRAL/2008';
cd(matDir)
rd.crp('/resources/scenes/multiband/scien/2008');
zipFileFull = fullfile(matDir,'Scenes2008.zip');
zipArtifact = rd.publishArtifact(zipFileFull, ...
    'version', fileVersion, ...
    'description', 'All the multiband scenes in 2008 from JEF.', ...
    'name', 'Scenes2004.zip');
zipArtifact.url


%% Now put the zip file with all of the individual files on the server

matDir = '/wandellfs/data/validation/SCIEN/ISETBIO/MULTISPECTRAL/2009';
cd(matDir)
rd.crp('/resources/scenes/multiband/scien/2009');
zipFileFull = fullfile(matDir,'Scenes2009.zip');
zipArtifact = rd.publishArtifact(zipFileFull, ...
    'version', fileVersion, ...
    'description', 'All the multiband scenes in 2009 from JEF.', ...
    'name', 'Scenes2004.zip');
zipArtifact.url



%%  Test that the file is there and can be downloaded.

% Notice that we can produce a url for the file itself.  Let's fit this in
% to the RDT object

% rd.openBrowser(artifact)
[p,n] = fileparts(matFileName);
n = sprintf('%s-%s.mat',n,fileVersion);
url = fullfile(artifact.url,n);
tmp = tempname;
websave(tmp,url);
s = sceneFromFile(tmp,'multispectral');
ieAddObject(s); sceneWindow;


%% See if we can find the remote multiband artifacts
rd.crp('/resources/scenes/multiband/scien');
aList = rd.listArtifacts();
txt = [];
for ii=1:length(aList)
    txt = addText(txt,sprintf('%s\n',aList(ii).url))
end
txt
 
%% Now, get the remote hyperspectral artifact URLS

rd.crp('/resources/scenes/hyperspectral/stanford_database');
aList = rd.listArtifacts();
txt = [];
for ii=1:length(aList)
    txt = addText(txt,sprintf('%s\n',aList(ii).url))
end
txt

%% Find the number of bases for each of the data sets
cd('/wandellfs/data/validation/SCIEN/ISETBIO/MULTISPECTRAL/2004');
files = dir('*.mat');
for ii=1:length(files)
    load(files(ii).name,'basis','mcCOEF');
    fprintf('%s  %d %d %d\n',files(ii).name, size(mcCOEF,1), size(mcCOEF,2), size(basis.basis,2));
end

cd('/wandellfs/data/validation/SCIEN/ISETBIO/MULTISPECTRAL/2008');
files = dir('*.mat');
for ii=1:length(files)
    load(files(ii).name,'basis','mcCOEF');
    fprintf('%s  %d %d %d\n',files(ii).name, size(mcCOEF,1), size(mcCOEF,2), size(basis.basis,2));
end

cd('/wandellfs/data/validation/SCIEN/ISETBIO/MULTISPECTRAL/2009');
files = dir('*.mat');
for ii=1:length(files)
    load(files(ii).name,'basis','mcCOEF');
    fprintf('%s  %d %d %d\n',files(ii).name, size(mcCOEF,1), size(mcCOEF,2), size(basis.basis,2));
end

%% Download a multiband file




%% JEF:  Integrate Multiband web pages with Hyperspectral web pages at ImageVal site
%        Hyperspectral means that the data were acquired the hyperspectral
%        imager.  Multiband means that the spectral radiance was inferred
%        from multiple bands of images and derived using linear models.  In
%        both cases, the representation we have is wavelength samples that
%        cover the range either from 415-700 or 415-930.
%