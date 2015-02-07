function [reflectances,wavelength] = computeNatural100samples(plotFlag)

if ieNotDefined('plotFlag'), plotFlag = false; end

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
dataM = bsxfun(@minus,data,dataMean);
[U,S,~] = svd(data,'econ');
U = U(:,1:7);
S = S(1:7,1:7);
% Projection matrix
P = U';
% P = diag(1./diag(S))*U'; % Normalize variances

if plotFlag
   close all
   figure, set(gcf,'Position',[0 0 800 400])
     plot(wavelength,U,'LineWidth',2), axis tight, set(gca,'FontSize',13,'FontWeight','b')
    legend('Component 1','Component 2','Component 3','Component 4','Component 5','Component 6','Component 7','Location','northeastoutside')
    export_fig('PCA.eps','-eps','-transparent');   
end

% Clothes reflectances
load Clothes_Vhrel
data = removeOutOfGamutAlt1(data,wavelength,{'D65','Tungsten','Fluorescent'});
dataM = bsxfun(@minus,data,dataMean);
N = 20;
r = zeros(N,length(wavelength));
c = P * dataM;
cPCA = zeros(N,7);
Z = linkage(c');
T = cluster(Z,'maxclust',N);
for i = 1:N
    k = find(T == i);
    k = k(randperm(length(k),1));
    r(i,:) = data(:,k);
    cPCA(i,:) = c(:,k);
end

if plotFlag
    plot(wavelength,r(1:7,:)','LineWidth',2), axis tight, set(gca,'FontSize',13,'FontWeight','b')
    legend('Clothes 1','Clothes 2','Clothes 3','Clothes 4','Clothes 5','Clothes 6','Clothes 7','Location','northeastoutside')
    export_fig('ClothesR.eps','-eps','-transparent');
    plot(1:7,cPCA(1:7,:)','LineWidth',2), axis tight, set(gca,'FontSize',13,'FontWeight','b')
    legend('Clothes 1','Clothes 2','Clothes 3','Clothes 4','Clothes 5','Clothes 6','Clothes 7','Location','northeastoutside')
    export_fig('ClothesP.eps','-eps','-transparent');
end
    

XYZ = ieXYZFromEnergy([r;ones(1,length(wavelength))],wavelength);
LAB = xyz2lab(XYZ(1:end-1,:),XYZ(end,:));
[~,I] = sortrows(LAB,[2 3 1]);
r = r(I,:);
reflectances = [reflectances;r];% size(reflectances)

% Food reflectances
load Food_Vhrel
data = removeOutOfGamutAlt1(data,wavelength,{'D65','Tungsten','Fluorescent'});
dataM = bsxfun(@minus,data,dataMean);
N = 20;
r = zeros(N,length(wavelength));
c = P * dataM;
Z = linkage(c');
T = cluster(Z,'maxclust',N);
for i = 1:N
    k = find(T == i);
    k = k(randperm(length(k),1));
    r(i,:) = data(:,k);
end

if plotFlag
    plot(wavelength,r(1:7,:)','LineWidth',2), axis tight, set(gca,'FontSize',13,'FontWeight','b')
    legend('Food 1','Food 2','Food 3','Food 4','Food 5','Food 6','Food 7','Location','northeastoutside')
    export_fig('FoodR.eps','-eps','-transparent');
    plot(1:7,cPCA(1:7,:)','LineWidth',2), axis tight, set(gca,'FontSize',13,'FontWeight','b')
    legend('Food 1','Food 2','Food 3','Food 4','Food 5','Food 6','Food 7','Location','northeastoutside')
    export_fig('FoodP.eps','-eps','-transparent');
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
data = removeOutOfGamutAlt1(data,wavelength,{'D65','Tungsten','Fluorescent'});
dataM = bsxfun(@minus,data,dataMean);
N = 20;
r = zeros(N,length(wavelength));
c = P * dataM;
Z = linkage(c');
T = cluster(Z,'maxclust',N);
for i = 1:N
    k = find(T == i);
    k = k(randperm(length(k),1));
    r(i,:) = data(:,k);
end

if plotFlag
    plot(wavelength,r(1:7,:)','LineWidth',2), axis tight, set(gca,'FontSize',13,'FontWeight','b')
    legend('Nature 1','Nature 2','Nature 3','Nature 4','Nature 5','Nature 6','Nature 7','Location','northeastoutside')
    export_fig('NatureR.eps','-eps','-transparent');
    plot(1:7,cPCA(1:7,:)','LineWidth',2), axis tight, set(gca,'FontSize',13,'FontWeight','b')
    legend('Nature 1','Nature 2','Nature 3','Nature 4','Nature 5','Nature 6','Nature 7','Location','northeastoutside')
    export_fig('NatureP.eps','-eps','-transparent');
end

XYZ = ieXYZFromPhotons([r;ones(1,length(wavelength))],wavelength);
LAB = xyz2lab(XYZ(1:end-1,:),XYZ(end,:));
[~,I] = sortrows(LAB,[2 3 1]);
r = r(I,:);
reflectances = [reflectances;r];% size(reflectances)

% Hair samples
load Hair_Vhrel
data = removeOutOfGamutAlt1(data,wavelength,{'D65','Tungsten','Fluorescent'});
dataM = bsxfun(@minus,data,dataMean);
N = 5;
r = zeros(N,length(wavelength));
c = P * dataM;
Z = linkage(c');
T = cluster(Z,'maxclust',N);
for i = 1:N
    k = find(T == i);
    k = k(randperm(length(k),1));
    r(i,:) = data(:,k);
end

if plotFlag
    plot(wavelength,r(1:5,:)','LineWidth',2), axis tight, set(gca,'FontSize',13,'FontWeight','b')
    legend('Hair 1','Hair 2','Hair 3','Hair 4','Hair 5')
    export_fig('ClothesR.eps','-eps','-transparent');
    plot(1:7,cPCA(1:5,:)','LineWidth',2), axis tight, set(gca,'FontSize',13,'FontWeight','b')
    legend('Hair 1','Hair 2','Hair 3','Hair 4','Hair 5')
    export_fig('HairP.eps','-eps','-transparent');
end

XYZ = ieXYZFromPhotons([r;ones(1,length(wavelength))],wavelength);
LAB = xyz2lab(XYZ(1:end-1,:),XYZ(end,:));
[~,I] = sortrows(LAB,[2 3 1]);
r = r(I,:);
reflectances = [reflectances;r];% size(reflectances)

% Skin samples
load reflectances/Skin_Vhrel
data = removeOutOfGamutAlt1(data,wavelength,{'D65','Tungsten','Fluorescent'});
dataM = bsxfun(@minus,data,dataMean);
N = 15;
r = zeros(N,length(wavelength));
c = P * dataM;
Z = linkage(c');
T = cluster(Z,'maxclust',N);
for i = 1:N
    k = find(T == i);
    k = k(randperm(length(k),1));
    r(i,:) = data(:,k);
end

if plotFlag
    plot(wavelength,r(1:7,:)','LineWidth',2), axis tight, set(gca,'FontSize',13,'FontWeight','b')
    legend('Skin 1','Skin 2','Skin 3','Skin 4','Skin 5','Skin 6','Skin 7','Location','northeastoutside')
    export_fig('SkinR.eps','-eps','-transparent');
    plot(1:7,cPCA(1:7,:)','LineWidth',2), axis tight, set(gca,'FontSize',13,'FontWeight','b')
    legend('Skin 1','Skin 2','Skin 3','Skin 4','Skin 5','Skin 6','Skin 7','Location','northeastoutside')
    export_fig('SkinP.eps','-eps','-transparent');
end

XYZ = ieXYZFromPhotons([r;ones(1,length(wavelength))],wavelength);
LAB = xyz2lab(XYZ(1:end-1,:),XYZ(end,:));
[~,I] = sortrows(LAB,[2 3 1]);
r = r(I,:);
reflectances = [reflectances;r];% size(reflectances)

% Dupont Paint samples
load DupontPaintChip_Vhrel
data = removeOutOfGamutAlt1(data,wavelength,{'D65','Tungsten','Fluorescent'});
dataM = bsxfun(@minus,data,dataMean);
N = 20;
r = zeros(N,length(wavelength));
c = P * dataM;
Z = linkage(c');
T = cluster(Z,'maxclust',N);
for i = 1:N
    k = find(T == i);
    k = k(randperm(length(k),1));
    r(i,:) = data(:,k);
end

if plotFlag
    plot(wavelength,r(1:7,:)','LineWidth',2), axis tight, set(gca,'FontSize',13,'FontWeight','b')
    legend('Dupont 1','Dupont 2','Dupont 3','Dupont 4','Dupont 5','Dupont 6','Dupont 7','Location','northeastoutside')
    export_fig('DupontR.eps','-eps','-transparent');
    plot(1:7,cPCA(1:7,:)','LineWidth',2), axis tight, set(gca,'FontSize',13,'FontWeight','b')
    legend('Dupont 1','Dupont 2','Dupont 3','Dupont 4','Dupont 5','Dupont 6','Dupont 7','Location','northeastoutside')
    export_fig('DupontP.eps','-eps','-transparent');
end

XYZ = ieXYZFromPhotons([r;ones(1,length(wavelength))],wavelength);
LAB = xyz2lab(XYZ(1:end-1,:),XYZ(end,:));
[~,I] = sortrows(LAB,[2 3 1]);
r = r(I,:);
reflectances = [reflectances;r];% size(reflectances)

