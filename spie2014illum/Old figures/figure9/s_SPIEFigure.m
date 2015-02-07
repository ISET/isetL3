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
    
    Px = -2:2; Py = -2:2;
    pattern = camera.vci.L3.sensor.design.cfa.pattern;
    colors = cameraAlt.vci.L3.sensor.design.color.filterNames;
    
    clear camera
    
    for k = 1:2
      for l = 1:2
        cx = mod(Px+(k-1),2)+1;
        cy = mod(Py+(l-1),2)+1;
        for m = 1:length(colors)
          
          colorName = colors{m};
          
          colPat = pattern(cx,cy);
          filtPat = colPat == m;
          
          filtersD65 = reshape(cameraD65.vci.L3.filters(k,l,:,1),[],1);
          filtersAlt = reshape(cameraAlt.vci.L3.filters(k,l,:,1),[],1);
          idx = ~cellfun(@isempty,filtersD65) & ~cellfun(@isempty,filtersAlt);
          filtersD65 = filtersD65(idx);
          filtersAlt = filtersAlt(idx);
          
          idx = cellfun(@f_checkNPatches,filtersD65) & cellfun(@f_checkNPatches,filtersAlt);
          filtersD65 = filtersD65(idx);
          filtersAlt = filtersAlt(idx);
          
          filtersD65 = reshape(cell2mat(filtersD65),[],1);
          filtersAlt = reshape(cell2mat(filtersAlt),[],1);
          
          for i = 1:3
            figure
            
            switch i
              case 1
                filtersD65sub = [filtersD65(:).global];
                filtersAltsub = [filtersAlt(:).global];
                type = 'global';
              case 2
                filtersD65sub = [filtersD65(:).flat];
                filtersAltsub = [filtersAlt(:).flat];
                type = 'flat';
              case 3
                filtersD65sub = cell2mat([filtersD65(:).texture]);
                filtersAltsub = cell2mat([filtersAlt(:).texture]);
                type = 'texture';
              otherwise
            end
            
            filtersD65sub = filtersD65sub(:,filtPat(:));
            filtersAltsub = filtersAltsub(:,filtPat(:));
            
            plot(filtersD65sub(:),filtersAltsub(:),'+')
            X = [min([filtersD65sub(:);filtersAltsub(:)]),max([filtersD65sub(:);filtersAltsub(:)])];
            xlim(X)
            ylim(X)
            hold all
            plot(zeros(size(X)),X,'k-','LineWidth',1)
            plot(X,zeros(size(X)),'k-','LineWidth',1)
            plot(X,X,'-','LineWidth',2)
            xlabel(['D65',' -> ','D65']);
            ylabel([lights{nl},' -> ',lights{nl}]);
            title([cfas{nc},', ',type,' filters / ',lights{nl},' -> ',lights{nl},' vs. ','D65',' -> ','D65 ',num2str(2*(k-1)+l),' ',colorName])
            
            export_fig(['scatterPlot_',cfas{nc},'_',lights{nl},'_',type,'_',num2str(2*(k-1)+l),'_',colorName,'.png'],'-png','-transparent')
          end
        end
      end
    end
    
  end
end