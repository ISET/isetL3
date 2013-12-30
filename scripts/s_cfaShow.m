%% s_cfaShow
%
% Let's the user select some of the published CFAs and show the pattern in
% a window
%
% 2013 Stanford VISTA Team

%% These are all of the published arrays we know about
cfaFiles = dir(fullfile(L3rootpath,'data','sensors','CFA','published','*.mat'));

%% Have the user select
listStr = cell(length(cfaFiles),1);
for ii=1:length(cfaFiles)
    listStr{ii} = cfaFiles(ii).name;
end
sel = listdlg('PromptString','Select CFAs for Training','ListString',listStr);
if isempty(sel), disp('User canceled'); return; end

%%  Loop over the selections showing a block and printing the comment

sensor = sensorCreate;

for ii=1:length(sel)
    fName = cfaFiles(sel(ii)).name;
    foo = load(cfaFiles(sel(ii)).name);
    sensor = sensorSet(sensor,'wave',foo.wavelength);
    sensor = sensorSet(sensor,'filter spectra',foo.data);
    sensor = sensorSet(sensor,'filter names',foo.filterNames);
    sensor = sensorSet(sensor,'pattern and size',foo.filterOrder);
    [~,hdl] = plotSensor(sensor,'cfa block');
    set(hdl,'name',sprintf('%s',fName));
    
    str = sprintf('***\n%s\n%s\n***\n\n',fName,foo.comment);
    h = msgbox(str);
    
end

%%