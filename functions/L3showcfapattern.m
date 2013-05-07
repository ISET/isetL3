% L3SHOWCFAPATTERN generates RGB image of repeating CFA pattern
%
% Copyright Steven Lansel, 2010

%% Adjustable parameters
filterfoldername='people_small_RGBW';    %name of subfolder in results that we want to use
numpatches=[10,10]; %number of rows and columns of pixels in the CFA to show
patchwidth=5;       %number of pixels that make up each CFA pixel in the drawn figure
borderwidth=1;      %number of black pixels between each CFA pixel in the drawn figure
sigma=0;            %amount of noise to show in each CFA pixel

%% Load data
addpath(genpath(L3rootpath))
load([L3rootpath,filesep,'Results',filesep,filterfoldername,filesep,'descrip.mat'],'cfapattern','dataset')
load([dataset,'_descrip.mat'],'wave','inputfilters')

%% Generate figure
L3showCFA(cfapattern,inputfilters,wave,numpatches,patchwidth,borderwidth,sigma);