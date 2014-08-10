function rootpath=L3rootpath()
%% L3ROOTPATH Returns the path to the root L^3 directory
%
% This function must reside in the main directory containing the L^3
% package.
%
% This helps with loading and saving files for the L^3 algorithm.
%
% Copyright Steven Lansel, 2010

rootpath=which('L3rootpath');

[rootpath,fName,ext]=fileparts(rootpath);

return