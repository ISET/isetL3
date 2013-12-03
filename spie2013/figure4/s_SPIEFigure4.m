%% s_SPIEFigure4
%
% This script computes and plots the new opponent color space WvCbCr 
% optimized for the W pixel for SPIE2013 paper figure 4.  
% 
%
%
% (c) Stanford VISTA Team

%% Start ISET
s_initISET

%% Find conversion matrix  
L3 = L3Initialize();  % initialize L3
A = L3findRGBWcolortransform(L3); % from XYZ to WvCbCr

%% Compute WvCbCr basis function
XYZ = L3Get(L3, 'idealfiltertransmissivities');
wavelength = L3Get(L3, 'idealfilterwave');
WvCbCr = A * XYZ';

%% Plot WvCbCr basis function
plot(wavelength, WvCbCr(1, :), 'b', 'LineWidth', 3)
hold on
plot(wavelength, WvCbCr(2, :), 'k', 'LineWidth', 3)
plot(wavelength, WvCbCr(3, :), 'r', 'LineWidth', 3)
grid on
xlim([min(wavelength), max(wavelength)])
set(gca,'fontsize',15)
saveas(gcf, 'WvCbCr.png');







