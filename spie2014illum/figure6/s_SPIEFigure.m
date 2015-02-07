folder = pwd;
cd ~/scien/iset
isetPath(pwd)
cd ~/scien/L3
L3Path(pwd)
cd(folder);

% clear all, clc, close all
% s_initISET

lights = {'Tungsten','Fluorescent'};
cfas = {'Bayer','RGBW1','CMY1'};
lights = {'Tungsten'};
cfas = {'Bayer'};

for nl = 1:length(lights)
    for nc = 1:length(cfas)
        
        load(['../QTtraindata/data/L3camera_',cfas{nc},'_D65.mat'])
        cameraD65 = L3ModifyCameraFG(camera,camera,1);
        
        
        load(['../QTtraindata/data/L3camera_',cfas{nc},'_',lights{nl},'.mat'])
        cameraAlt = L3ModifyCameraFG(camera,camera,1);
        
        clear camera
        
        colors = cameraD65.sensor.color.filterNames;
        colors2 = colors
        cfa = cameraD65.sensor.cfa.pattern;
        blockSize = cameraD65.vci.L3.training.patchSize;
        
        for ncol = 1:length(colors)
            filtersD65 = [];
            filtersAlt = [];
            if colors{ncol} == 'w'
                colors2{ncol} = 'k';
            end
            for ncfax = 1:size(cfa,1)
                for ncfay = 1:size(cfa,2)
                    if cfa(ncfax,ncfay) == ncol
                        filtersD65 = [filtersD65;reshape(cameraD65.vci.L3.filters(ncfax,ncfay,:,1),[],1)];
                        filtersAlt = [filtersAlt;reshape(cameraAlt.vci.L3.filters(ncfax,ncfay,:,1),[],1)];
                    end
                end
            end
           
            
            idx = ~cellfun(@isempty,filtersD65) & ~cellfun(@isempty,filtersAlt);
            filtersD65 = filtersD65(idx);
            filtersAlt = filtersAlt(idx);
            
            idx = cellfun(@f_checkNPatches,filtersD65) & cellfun(@f_checkNPatches,filtersAlt);
            filtersD65 = filtersD65(idx);
            filtersAlt = filtersAlt(idx);
            
            filtersD65 = reshape(cell2mat(filtersD65),[],1);
            filtersAlt = reshape(cell2mat(filtersAlt),[],1);
            
            for i = 2
                figure
                
                switch i
                    case 1
                        filtersD65sub = reshape([filtersD65(:).global],[],1);
                        filtersAltsub = reshape([filtersAlt(:).global],[],1);
                        filtersD65sub = vertcat(filtersD65(:).global);
                        filtersAltsub = vertcat(filtersAlt(:).global);
                        type = 'global';
                    case 2
                        filtersD65sub = reshape([filtersD65(:).flat],[],1);
                        filtersAltsub = reshape([filtersAlt(:).flat],[],1);
                        filtersD65sub = vertcat(filtersD65(:).flat);
                        filtersAltsub = vertcat(filtersAlt(:).flat);
                        type = 'flat';
                    case 3
                        filtersD65sub = reshape(cell2mat([filtersD65(:).texture]),[],1);
                        filtersAltsub = reshape(cell2mat([filtersAlt(:).texture]),[],1);
                        filtersD65sub = cell2mat(vertcat(filtersD65(:).texture));
                        filtersAltsub = cell2mat(vertcat(filtersAlt(:).texture));
                        type = 'texture';
                    otherwise
                end
                
                d = floor(blockSize/2);
                [mx,my] = meshgrid(-d:d,-d:d);
                mark = {'x','o','s'};
                
                for ndist = 1:length(mark)
                    maskd = max(abs(mx),abs(my)) == (ndist-1);
                    maskd = maskd(:)';
                    Maskd = repmat(maskd,size(filtersD65sub,1),1);
                    for ncfax = 1:size(cfa,1)
                        for ncfay = 1:size(cfa,2)
                            if cfa(ncfax,ncfay) == ncol
                                maskc = cfa(mod((-d:d)+ncfax-1,2)+1,mod((-d:d)+ncfay-1,2)+1) == ncol;
                                maskc = maskc(:)';
                                Maskc = repmat(maskc,size(filtersD65sub,1),1);
                            end
                        end
                    end
                    fD65 = filtersD65sub( Maskd & Maskc );
                    fAlt = filtersAltsub( Maskd & Maskc );
                    
                    fD65 = fD65(ncol:3:end);
                    fAlt = fAlt(ncol:3:end);
                    
                    plot(fD65,fAlt,[colors2{ncol},mark{ndist}],'LineWidth',2,'MarkerSize',9)
                    X = [min([filtersD65sub(:);filtersAltsub(:)]),max([filtersD65sub(:);filtersAltsub(:)])];
                    xlim(X)
                    ylim(X)
                    hold all
                    plot(zeros(size(X)),X,'k-','LineWidth',1)
                    plot(X,zeros(size(X)),'k-','LineWidth',1)
                    plot(X,X,'--k','LineWidth',2)
                    xlabel(['SI\_D65']);
                    ylabel(['SI\_Tun']);
%                     title([cfas{nc},', ',type,' filters / ',lights{nl},' -> ',lights{nl},' vs. ','D65',' -> ','D65'])
                    set(gca,'FontSize',16,'FontWeight','b')
                    
                end
                export_fig(['scatterPlot_',cfas{nc},'_',lights{nl},'_',type,'_',colors{ncol},'.png'],'-png','-transparent')
                export_fig(['scatterPlot_',cfas{nc},'_',lights{nl},'_',type,'_',colors{ncol},'.eps'],'-eps','-transparent')
                close
            end
        end
        
    end
end