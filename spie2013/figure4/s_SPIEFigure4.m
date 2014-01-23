%% s_SPIEFigure4
%
% This script computes and plots the new opponent color space depends on 
% D65 illuminant (we call it WCbCr) for SPIE2013 paper figure 4.  
%
% (c) Stanford VISTA Team

%% Start ISET
s_initISET

%% Find conversion matrix from XYZ to WcbCr
A = L3findweightcolortransform(); 

%% Compute WCbCr basis function
wavelength = 400 : 10 : 680; 
XYZ = vcReadSpectra('XYZQuanta', wavelength); % read XYZ data 
WCbCr = A * XYZ';

%% Plot WvCbCr basis function
vcNewGraphWin;
plot(wavelength, WCbCr(1, :), 'r', 'LineWidth', 3)
hold on
plot(wavelength, WCbCr(2, :), 'k', 'LineWidth', 3)
plot(wavelength, WCbCr(3, :), 'b', 'LineWidth', 3)

xlim([min(wavelength), max(wavelength)])
grid on
xlabel('Wavelength (nm)');
ylabel('Relative sensitivity')

set(gca,'fontsize',15)
saveas(gcf, 'WCbCr.png');

%%
