folder = pwd;
cd ~/Stanford/iset
isetPath(pwd)
cd ~/Stanford/L3
L3Path(pwd)
cd(folder);

clear all, clc, close all
s_initISET

lights = {'Tungsten','Fluorescent'};
cfas = {'Bayer','RGBW1','CMY1'};
lights = {'Tungsten'};
cfas = {'Bayer'};

for nl = 1:length(lights)
  for nc = 1:length(cfas)
    
    load(['../QTtraindata/data/L3camera_',cfas{nc},'_D65.mat'])
    cameraD65 = L3ModifyCamera(camera,1);
    
    
    load(['../QTtraindata/data/L3camera_',cfas{nc},'_',lights{nl},'.mat'])
    cameraAlt = L3ModifyCamera(camera,1);
    
    clear camera
    
    filtersD65 = reshape(cameraD65.vci.L3.filters(:,:,:,1),[],1);
    filtersAlt = reshape(cameraAlt.vci.L3.filters(:,:,:,1),[],1);
    idx = ~cellfun(@isempty,filtersD65) & ~cellfun(@isempty,filtersAlt);
    filtersD65 = filtersD65(idx);
    filtersAlt = filtersAlt(idx);
    
    idx = cellfun(@f_checkNPatches,filtersD65) & cellfun(@f_checkNPatches,filtersAlt);
    filtersD65 = filtersD65(idx);
    filtersAlt = filtersAlt(idx);
    
    filtersD65 = reshape(cell2mat(filtersD65),[],1);
    filtersAlt = reshape(cell2mat(filtersAlt),[],1);
    
    for i = 1
      figure
  
      switch i
        case 1
          filtersD65sub = reshape([filtersD65(:).global],[],1);
          filtersAltsub = reshape([filtersAlt(:).global],[],1);
          type = 'global';
        case 2
          filtersD65sub = reshape([filtersD65(:).flat],[],1);
          filtersAltsub = reshape([filtersAlt(:).flat],[],1);
          type = 'flat';
        case 3
          filtersD65sub = reshape(cell2mat([filtersD65(:).texture]),[],1);
          filtersAltsub = reshape(cell2mat([filtersAlt(:).texture]),[],1);
          type = 'texture';
        otherwise
      end
      
      plot(filtersD65sub,filtersAltsub,'+')
      X = [min([filtersD65sub(:);filtersAltsub(:)]),max([filtersD65sub(:);filtersAltsub(:)])];
      xlim(X)
      ylim(X)
      hold all
      plot(zeros(size(X)),X,'k-','LineWidth',1)
      plot(X,zeros(size(X)),'k-','LineWidth',1)
      plot(X,X,'-','LineWidth',2)
      xlabel(['D65',' -> ','D65']);
      ylabel([lights{nl},' -> ',lights{nl}]);
      title([cfas{nc},', ',type,' filters / ',lights{nl},' -> ',lights{nl},' vs. ','D65',' -> ','D65'])
      
      export_fig(['scatterPlot_',cfas{nc},'_',lights{nl},'_',type,'.png'],'-png','-transparent')
    end
    
  end
end