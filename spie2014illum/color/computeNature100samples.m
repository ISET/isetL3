function [reflectances,wavelength] = computeNature100samples()

reflectances = [];
rng(1);

% Compute principal components
load MunsellSamples_Vhrel
munsellData = data;
load DupontPaintChip_Vhrel
dupontData = data;
load Objects_Vhrel.mat
objectsData = data;
data = [munsellData,dupontData,objectsData];
dataMean = mean(data,2);
data = bsxfun(@minus,data,dataMean);
[U,S,~] = svd(data,'econ');
U = U(:,1:7);
S = S(1:7,1:7);
% Projection matrix
P = diag(1./diag(S))*U';

% Clothes reflectances
load Clothes_Vhrel
data = removeOutOfGamut2(data,wavelength);
N = 20;
r = zeros(N,length(wavelength));
c = P * data;
Z = linkage(c');
T = cluster(Z,'maxclust',N);
for i = 1:N
    k = find(T == i);
    k = k(randperm(length(k),1));
    r(i,:) = data(:,k);
end
XYZ = ieXYZFromEnergy([r;ones(1,length(wavelength))],wavelength);
LAB = xyz2lab(XYZ(1:end-1,:),XYZ(end,:));
[~,I] = sortrows(LAB,[2 3 1]);
r = r(I,:);
reflectances = [reflectances;r];% size(reflectances)

% Food reflectances
load Food_Vhrel
data = removeOutOfGamut2(data,wavelength);
N = 20;
r = zeros(N,length(wavelength));
c = P * data;
Z = linkage(c');
T = cluster(Z,'maxclust',N);
for i = 1:N
    k = find(T == i);
    k = k(randperm(length(k),1));
    r(i,:) = data(:,k);
end
XYZ = ieXYZFromPhotons([r;ones(1,length(wavelength))],wavelength);
LAB = xyz2lab(XYZ(1:end-1,:),XYZ(end,:));
[~,I] = sortrows(LAB,[2 3 1]);
r = r(I,:);
reflectances = [reflectances;r];% size(reflectances)

% Nature data
load Food_Vhrel
foodData = data;
load reflectances/Nature_Vhrel
data = setdiff(data',foodData','rows')';
data = removeOutOfGamut2(data,wavelength);
N = 20;
r = zeros(N,length(wavelength));
c = P * data;
Z = linkage(c');
T = cluster(Z,'maxclust',N);
for i = 1:N
    k = find(T == i);
    k = k(randperm(length(k),1));
    r(i,:) = data(:,k);
end
XYZ = ieXYZFromPhotons([r;ones(1,length(wavelength))],wavelength);
LAB = xyz2lab(XYZ(1:end-1,:),XYZ(end,:));
[~,I] = sortrows(LAB,[2 3 1]);
r = r(I,:);
reflectances = [reflectances;r];% size(reflectances)

% Hair samples
load Hair_Vhrel
data = removeOutOfGamut2(data,wavelength);
N = 5;
r = zeros(N,length(wavelength));
c = P * data;
Z = linkage(c');
T = cluster(Z,'maxclust',N);
for i = 1:N
    k = find(T == i);
    k = k(randperm(length(k),1));
    r(i,:) = data(:,k);
end
XYZ = ieXYZFromPhotons([r;ones(1,length(wavelength))],wavelength);
LAB = xyz2lab(XYZ(1:end-1,:),XYZ(end,:));
[~,I] = sortrows(LAB,[2 3 1]);
r = r(I,:);
reflectances = [reflectances;r];% size(reflectances)

% Skin samples
load reflectances/Skin_Vhrel
data = removeOutOfGamut2(data,wavelength);
N = 15;
r = zeros(N,length(wavelength));
c = P * data;
Z = linkage(c');
T = cluster(Z,'maxclust',N);
for i = 1:N
    k = find(T == i);
    k = k(randperm(length(k),1));
    r(i,:) = data(:,k);
end
XYZ = ieXYZFromPhotons([r;ones(1,length(wavelength))],wavelength);
LAB = xyz2lab(XYZ(1:end-1,:),XYZ(end,:));
[~,I] = sortrows(LAB,[2 3 1]);
r = r(I,:);
reflectances = [reflectances;r];% size(reflectances)

% Munsell samples
load DupontPaintChip_Vhrel
data = removeOutOfGamut2(data,wavelength);
N = 20;
r = zeros(N,length(wavelength));
c = P * data;
Z = linkage(c');
T = cluster(Z,'maxclust',N);
for i = 1:N
    k = find(T == i);
    k = k(randperm(length(k),1));
    r(i,:) = data(:,k);
end
XYZ = ieXYZFromPhotons([r;ones(1,length(wavelength))],wavelength);
LAB = xyz2lab(XYZ(1:end-1,:),XYZ(end,:));
[~,I] = sortrows(LAB,[2 3 1]);
r = r(I,:);
reflectances = [reflectances;r];% size(reflectances)

