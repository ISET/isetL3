% L3ANALYSISPLOTSIMAGE is a ROUGH script containing a number of cells to
% generate images and plots related to the output of trainpipeline.m
%
% This serves as a very rough template for displaying some possibly
% interesting plots.
% The cells may or may not run properly or be clear.
%
% Copyright Steven Lansel, 2010





%% Plot of PSNR vs varvalues

% foldername='wstdv-block5-sigma20-kodim23'
% foldername='RGB'
% foldername='wstdv-block5-sigma10-ctreedepth3-kodim23-noP';
% foldername='wstdv-block9-leftout23'
% foldername='flatpercent-leftout23'
foldername='wstdv-block5-sigma10-kodim23-noP';

seperator='\';
load([pwd,seperator,'Results',seperator,foldername,seperator,'descrip.mat'])
currenttreedepth=treedepth2;

for patchtypenum=1:length(patchtypes)                
% for patchtypenum=1:length(patchtypes)
            
    
    patchtype=patchtypes{patchtypenum};
%     subplot(1,length(patchtypes),patchtypenum)
    trainpsnrs=zeros(3,length(varvalues));
    testpsnrs=zeros(3,length(varvalues));

    
    for varvaluenum=1:length(varvalues)

        eval([varname,'=',num2str(varvalues(varvaluenum)),';'])
        
        if trainpatches2>=1000000
            sizedescrip=[num2str(floor(trainpatches2/1000000),1),'m'];
        elseif trainpatches2>=1000
            sizedescrip=[num2str(floor(trainpatches2/1000),1),'k'];
        else
            sizedescrip=num2str(trainpatches2);
        end

        savefilename=['table','_',num2str(varvaluenum),'_',sizedescrip,'_',num2str(blockwidth(1)),'_',num2str(treedepth2),'_',patchtype];
        if exist([pwd,seperator,'Results',seperator,foldername,seperator,savefilename,'.mat'],'file')==0
            trainpsnrs(:,varvaluenum)=NaN;
            testpsnrs(:,varvaluenum)=NaN;
        else
            load([pwd,seperator,'Results',seperator,foldername,seperator,savefilename,'.mat'])
            if ctreedepth==0
                ctreedepth=1;
                ctrainfreqs=1-trainfreqs(1);
                ctestfreqs=1-testfreqs(1);
                ctrainpsnrclusters=ctrainpsnr0;     
                ctestpsnrclusters=ctestpsnr0;
            end

                
            cclustersatdepth=2^(ctreedepth-1):(2^ctreedepth-1);
            clustersatdepth=2^(currenttreedepth-1):(2^(currenttreedepth)-1);

            traincurrentfreqs=[ctrainfreqs(cclustersatdepth),trainfreqs(clustersatdepth)];                        
            testcurrentfreqs=[ctestfreqs(cclustersatdepth),testfreqs(clustersatdepth)];
            
            traincurrentpsnrs=[ctrainpsnrclusters(:,cclustersatdepth),trainpsnrclusters(:,clustersatdepth)];
            testcurrentpsnrs=[ctestpsnrclusters(:,cclustersatdepth),testpsnrclusters(:,clustersatdepth)];

            badindexes=(traincurrentpsnrs<0 | isnan(traincurrentpsnrs));
            traincurrentpsnrs(badindexes)=500;

            trainpsnrs(:,varvaluenum)=10*log10(255^2./(traincurrentfreqs*(255^2./10.^(traincurrentpsnrs'/10))));           
            testpsnrs(:,varvaluenum)=10*log10(255^2./(testcurrentfreqs*(255^2./10.^(testcurrentpsnrs'/10))));
        end
    end
    

    figure    
    for colornum=1:3
        subplot(1,3,colornum)
        if colornum==1
            color='r';
        elseif colornum==2  
            color='g';
        else
            color='b';
        end

        plot(varvalues,squeeze(trainpsnrs(colornum,:)),[color,'-x'],'LineWidth',3)

        grid on
        xlabel(varname)
        ylabel('PSNR (dB)')
        title('Training')
    end
    
    figure    
    for colornum=1:3
        subplot(1,3,colornum)
        if colornum==1
            color='r';
        elseif colornum==2  
            color='g';
        else
            color='b';
        end

        plot(varvalues,squeeze(testpsnrs(colornum,:)),[color,'-x'],'LineWidth',3)

        grid on
        xlabel(varname)
        ylabel('PSNR (dB)')
        title('Testing')
    end
end




%% Plot of PSNR vs spatial tree depth (for many varvalues)

% foldername='all-leftout-block5-mode6';
% foldername='RGBXYZ';
% foldername='wstdv-block5-sigma20-kodim23'
% foldername='RGB'
% foldername='projection-block5-sigma10-leftout23'
% foldername='globalflat0';
% foldername='wstdv-block5-sigma10-kodim23-noP-noflip';
foldername='poisson_block9_leftout19_vector';

seperator='\';
load([pwd,seperator,'Results',seperator,foldername,seperator,'descrip.mat'])

styles={'-x',':o','-.','-*','--+','-s','-p','-.',':o','-.x','-*','--+','-s','-p'};

figure
% for patchtypenum=1:1
for patchtypenum=1:length(patchtypes)
            
    
    patchtype=patchtypes{patchtypenum};
%     subplot(1,length(patchtypes),patchtypenum)
    trainpsnrs=zeros(3,length(varvalues),treedepth2);
%     testpsnrs=zeros(3,length(varvalues),treedepth2);
    
    for varvaluenum=1:length(varvalues)

        eval([varname,'=',num2str(varvalues(varvaluenum)),';'])
        
        if trainpatches2>=1000000
            sizedescrip=[num2str(floor(trainpatches2/1000000),1),'m'];
        elseif trainpatches2>=1000
            sizedescrip=[num2str(floor(trainpatches2/1000),1),'k'];
        else
            sizedescrip=num2str(trainpatches2);
        end

        savefilename=['table','_',num2str(varvaluenum),'_',sizedescrip,'_',num2str(blockwidth(1)),'_',num2str(treedepth2),'_',patchtype];
        if exist([pwd,seperator,'Results',seperator,foldername,seperator,savefilename,'.mat'],'file')==0
            trainpsnrs(:,varvaluenum,:)=0;
            testpsnrs(:,varvaluenum,:)=0;
        else
            load([pwd,seperator,'Results',seperator,foldername,seperator,savefilename,'.mat'])

            if ctreedepth==0
                ctreedepth=1;
                ctrainfreqs=1-trainfreqs(1);
                ctestfreqs=1-testfreqs(1);
                ctrainpsnrclusters=ctrainpsnr0;
                ctestpsnrclusters=ctestpsnr0;
            end            
            
            for currenttreedepth=1:treedepth2

                cclustersatdepth=2^(ctreedepth-1):(2^ctreedepth-1);
                clustersatdepth=2^(currenttreedepth-1):(2^(currenttreedepth)-1);
                traincurrentfreqs=[ctrainfreqs(cclustersatdepth),trainfreqs(clustersatdepth)];
                traincurrentpsnrs=[ctrainpsnrclusters(:,cclustersatdepth),trainpsnrclusters(:,clustersatdepth)];
                testcurrentfreqs=[ctestfreqs(cclustersatdepth),testfreqs(clustersatdepth)];
                testcurrentpsnrs=[ctestpsnrclusters(:,cclustersatdepth),testpsnrclusters(:,clustersatdepth)];

                if abs(1-sum(traincurrentfreqs))>.03 %| abs(1-sum(testcurrentfreqs))>.03
                    error('sum is not 1')
                end

                trainpsnrs(:,varvaluenum,currenttreedepth)=10*log10(255^2./(traincurrentfreqs*(255^2./10.^(traincurrentpsnrs'/10))));           
                testpsnrs(:,varvaluenum,currenttreedepth)=10*log10(255^2./(testcurrentfreqs*(255^2./10.^(testcurrentpsnrs'/10))));
            end
        end
    end 
    

    figure    
    legendstrs=[];
    for varvaluenum=1:length(varvalues)
        style=styles{varvaluenum};
        for colornum=1:3
            subplot(1,3,colornum)
            if colornum==1
                color='r';
            elseif colornum==2  
                color='g';
            else
                color='b';
            end

            plot(1:treedepth2,squeeze(trainpsnrs(colornum,varvaluenum,:)),[color,style],'LineWidth',3)
            hold on
            if colornum==3
                
                
                
                if any(trainpsnrs(:,varvaluenum,:)~=0)
                    legendstrs{end+1}=[varname,'=',num2str(varvalues(varvaluenum),2)];
                else
                    legendstrs{end+1}=' ';
                end

                legend(legendstrs,'Location','SouthEast')
            end
                        
%             plot(1:treedepth2,squeeze(trainpsnrs(colornum,varvaluenum,:)),[color,styles{2*varvaluenum}])            

            grid on
            xlabel('tree depth')
            ylabel('PSNR (dB)')
            title('Training')
        end
    end   

%     
    figure    
    legendstrs=[];
    for varvaluenum=1:length(varvalues)
        style=styles{varvaluenum};        
        for colornum=1:3
            subplot(1,3,colornum)
            if colornum==1
                color='r';
            elseif colornum==2  
                color='g';
            else
                color='b';
            end

            plot(1:treedepth2,squeeze(testpsnrs(colornum,varvaluenum,:)),[color,style],'LineWidth',3)
            hold on
            if colornum==3
                if any(testpsnrs(:,varvaluenum,:)~=0)
                    legendstrs{end+1}=[varname,'=',num2str(varvalues(varvaluenum),2)];
                else
                    legendstrs{end+1}=' ';
                end

                legend(legendstrs,'Location','SouthEast')
            end
                        
%             plot(1:treedepth2,squeeze(testpsnrs(colornum,varvaluenum,:)),[color,styles{2*varvaluenum}])            

            grid on
            xlabel('tree depth')
            ylabel('PSNR (dB)')
            title('Testing')
        end
    end   
end




%% Plot spatial centroids and filters (for an already loaded file)
numclusters=1;
% numclusters=min(size(centroids,2),15);
clusteroffset=length(thresholds);
currentplotnum=1;
for clusternum=1:numclusters
    if mod(clusternum,7)==1
        currentplotnum=1;
        figure
    end
    subplot(min(numclusters,7),6,currentplotnum)
    currentplotnum=currentplotnum+1;

                
    imagesc(reshape(centroids(:,clusternum)./weights(:),blockwidth(1),blockwidth(2)))
    colorbar
    colormap(gray)
    axis image
    axis off    
    title([num2str(clusternum),': ',num2str(100*trainfreqs(clusternum),2),'% ',num2str(100*testfreqs(clusternum),2),'%'])

    
    subplot(min(numclusters,7),6,currentplotnum)
    currentplotnum=currentplotnum+1;       
    imagesc(reshape(variances(:,clusternum)./weights(:),blockwidth(1),blockwidth(2)))
    colorbar
    colormap(gray)
    axis image
    axis off  
    title('Variance')
%     if clusternum<=clusteroffset
%         title(num2str(thresholds(clusternum),3))
%     end
    
    if clusternum<=clusteroffset
        subplot(min(numclusters,7),6,currentplotnum)
        imagesc(reshape(pcas(:,clusternum),blockwidth(1),blockwidth(2)))
        colorbar
        colormap(gray)
        axis image
        axis off
        title('PCA Direction')
    end
    currentplotnum=currentplotnum+1;
    
    
    for colornum=1:3
        subplot(min(numclusters,7),6,currentplotnum)
        currentplotnum=currentplotnum+1;
        imagesc(reshape(texturefilters{clusternum}(colornum,1:prod(blockwidth)),blockwidth(1),blockwidth(2)))
        colorbar
        colormap(gray)
        axis image
        axis off
        if colornum==1
%             title(['R: ',num2str(trainpsnrclusters(colornum,clusternum),3),', ',num2str(testpsnrclusters(colornum,clusternum),3)])
            title(['R: ',num2str(trainpsnrclusters(colornum,clusternum),3)])
        elseif colornum==2
%             title(['G: ',num2str(trainpsnrclusters(colornum,clusternum),3),', ',num2str(testpsnrclusters(colornum,clusternum),3)])   
            title(['G: ',num2str(trainpsnrclusters(colornum,clusternum),3)])
        elseif colornum==3
%             title(['B: ',num2str(trainpsnrclusters(colornum,clusternum),3),', ',num2str(testpsnrclusters(colornum,clusternum),3)])
            title(['B: ',num2str(trainpsnrclusters(colornum,clusternum),3)])
        end    
    end
end

%% Plot of Centroids only  (for an already loaded file)
% numclusters=size(centroids,2);
numclusters=25;
figure
for clusternum=1:numclusters
    subplot(ceil(sqrt(numclusters)),ceil(sqrt(numclusters)),clusternum)
    imagesc(reshape(centroids(:,clusternum),blockwidth,blockwidth))
    colorbar
    colormap(gray)
    axis image
    axis off    
    title(num2str(clusternum))
end


%% Plot of Predicted and Actual Values for Training Data

figure
colors={'rx','gx','bx','cx','mx','yx','kx','ro','go','bo','co','mo','yo','ko'};

subplot(1,2,1)
for clusternum=1:numclusters
    plot(xhattrain(1,clustermembers{clusternum}),traindata(blockwidth^2+1,clustermembers{clusternum}),colors{clusternum})
    hold on
end
xlabel('Estimated')
ylabel('Original')
if missingcolors(1)==1
    title('R')
elseif missingcolors(1)==2
    title('G')
elseif missingcolors(1)==3
    title('B')
end  

subplot(1,2,2)
for clusternum=1:numclusters
    plot(xhattrain(2,clustermembers{clusternum}),traindata(blockwidth^2+2,clustermembers{clusternum}),colors{clusternum})
    hold on
end
xlabel('Estimated')
ylabel('Original')
if missingcolors(2)==1
    title('R')
elseif missingcolors(2)==2
    title('G')
elseif missingcolors(2)==3
    title('B')
end 
legend(num2str((1:numclusters)'))

%% Plot of Predicted and Actual Values for Test Data

figure
colors={'rx','gx','bx','cx','mx','yx','kx','ro','go','bo','co','mo','yo','ko','r*','g*','b*','c*','m*','y*','k*','rs','gs','bs','cs','ms','ys','ks'};

subplot(1,2,1)
for clusternum=1:numclusters
    plot(testdata(blockwidth^2+1,testclustermembers{clusternum}),testdata(blockwidth^2+1,testclustermembers{clusternum})-xhat(1,testclustermembers{clusternum}),colors{clusternum})
    hold on
end
xlabel('Estimated')
ylabel('Original')
if missingcolors(1)==1
    title('R')
elseif missingcolors(1)==2
    title('G')
elseif missingcolors(1)==3
    title('B')
end  
lims=axis;
plot([max(lims([1,3])),min(lims([2,4]))],[max(lims([1,3])),min(lims([2,4]))],'k')

subplot(1,2,2)
for clusternum=1:numclusters
    plot(testdata(blockwidth^2+2,testclustermembers{clusternum}),testdata(blockwidth^2+2,testclustermembers{clusternum})-xhat(2,testclustermembers{clusternum}),colors{clusternum})
    hold on
end
xlabel('Estimated')
ylabel('Original')
if missingcolors(2)==1
    title('R')
elseif missingcolors(2)==2
    title('G')
elseif missingcolors(2)==3
    title('B')
end 
lims=axis;
plot([max(lims([1,3])),min(lims([2,4]))],[max(lims([1,3])),min(lims([2,4]))],'k')
legend(num2str((1:numclusters)'))


%% Plot of PSNR for training and testing vs Cluster Index
figure
numclusters=size(trainpsnrmeanclusters,2);
for missingcolornum=1:2
    subplot(1,2,missingcolornum)
    hold on
%     plot(0:numclusters,[trainpsnrcluster0(missingcolornum),trainpsnrmeanclusters(missingcolornum,:)],'rx')
% %     plot(0:numclusters,[trainpsnrcluster0(missingcolornum),trainpsnrclusters(missingcolornum,:)],'r-o')
%     plot(0:numclusters,[trainpsnrcluster0(missingcolornum),trainpsnrlinearclusters(missingcolornum,:)],'gx')
%     plot(0:numclusters,[trainpsnrcluster0(missingcolornum),trainpsnraffineclusters(missingcolornum,:)],'bx')
%     plot(0:numclusters,[trainpsnrcluster0(missingcolornum),trainpsnrstrictclusters(missingcolornum,:)],'kx')

    
    plot(0:numclusters,[testpsnrcluster0(missingcolornum),testpsnrmeanclusters(missingcolornum,:)],'rx')
%     plot(0:numclusters,[testpsnrcluster0(missingcolornum),testpsnrclusters(missingcolornum,:)],'g-o')
    plot(0:numclusters,[testpsnrcluster0(missingcolornum),testpsnrlinearclusters(missingcolornum,:)],'gx')
    plot(0:numclusters,[testpsnrcluster0(missingcolornum),testpsnraffineclusters(missingcolornum,:)],'bx')
    plot(0:numclusters,[testpsnrcluster0(missingcolornum),testpsnrstrictclusters(missingcolornum,:)],'kx')


    xlabel('Cluster Index')
    ylabel('PSNR (dB)')
    grid on
%     legend('Training Global Linear','Training Local Linear','Testing Global Linear','Testing Local Linear')
    legend('Training Global Linear','Training Local Linear','Training Local Affine','Training Local Strict')


    if missingcolors(missingcolornum)==1
        title('R Prediction');
    elseif missingcolors(missingcolornum)==2
        title('G Prediction');           
    elseif missingcolors(missingcolornum)==3
        title('B Prediction');        
    end 
end


%% Plot of PSNR averaged over all pixels vs tree depth (for many varvalues)

% foldername='leave1out';
foldername='noise-contrast';

seperator='\';
load([pwd,seperator,'Results',seperator,foldername,seperator,'descrip.mat'])

styles={'-.',':o','-.x','-*','--+','-s','-p','-.',':o','-.x','-*','--+','-s','-p'};


figure
legendstrs=[];    
% for varvaluenum=1:length(varvalues)
for varvaluenum=1
    eval([varname,'=',num2str(varvalues(varvaluenum)),';'])
    trainpsnrs=zeros(2,length(patchtypes),treedepth2);
    testpsnrs=zeros(2,length(patchtypes),treedepth2);
    for patchtypenum=1:length(patchtypes)
        patchtype=patchtypes{patchtypenum};
        
        if trainpatches2>=1000000
            sizedescrip=[num2str(floor(trainpatches2/1000000),1),'m'];        
        elseif trainpatches2>=1000
            sizedescrip=[num2str(floor(trainpatches2/1000),1),'k'];
        else
            sizedescrip=num2str(trainpatches2);
        end

        savefilename=['table','_',num2str(varvaluenum),'_',sizedescrip,'_',num2str(blockwidth),'_',num2str(treedepth2),'_',num2str(flatthreshold),'_',patchtype];
        load([pwd,seperator,'Results',seperator,foldername,seperator,savefilename,'.mat'])
        
        for currenttreedepth=1:treedepth2
            clustersatdepth=2^(currenttreedepth-1):(2^currenttreedepth-1);
            freqs=trainfreqs(clustersatdepth);

%             freqs(end+1)=1-trainfreqs(1);    
%             currentpsnrs=[trainpsnrclusters(:,clustersatdepth),trainpsnrcluster0];
            currentpsnrs=trainpsnrclusters(:,clustersatdepth);

            trainpsnrs(:,patchtypenum,currenttreedepth)=10*log10(255^2./(freqs*(255^2./10.^(currentpsnrs'/10))));

            
            
            freqs=testfreqs(clustersatdepth);

%             freqs(end+1)=1-testfreqs(1);    
%             currentpsnrs=[testpsnrclusters(:,clustersatdepth),testpsnrcluster0];
            currentpsnrs=testpsnrclusters(:,clustersatdepth);

            testpsnrs(:,patchtypenum,currenttreedepth)=10*log10(255^2./(freqs*(255^2./10.^(currentpsnrs'/10))));
        end
    end 
    
    for currenttreedepth=1:treedepth2
        mse=2/3*mean(mean(255^2./10.^(trainpsnrs(:,:,currenttreedepth)/10)));
        finaltrainpsnr(currenttreedepth)=10*log10(255^2/mse);
        
        mse=2/3*mean(mean(255^2./10.^(testpsnrs(:,:,currenttreedepth)/10)));
        finaltestpsnr(currenttreedepth)=10*log10(255^2/mse);
    end
    
    plot(1:treedepth2,finaltrainpsnr,styles{2*varvaluenum-1})
    hold on
    plot(1:treedepth2,finaltestpsnr,styles{2*varvaluenum})

    legendstrs{end+1}=['train ',varname,'=',num2str(varvalues(varvaluenum))];
    legendstrs{end+1}=['test ',varname,'=',num2str(varvalues(varvaluenum))];
end

grid on
xlabel('tree depth')
ylabel('PSNR (dB)')
legend(legendstrs)

%% Plot of PSNR vs varvalues (for many tree depths)

% foldername='leave1out';
foldername='flatthreshold-k07';


seperator='\';
load([pwd,seperator,'Results',seperator,foldername,seperator,'descrip.mat'])
varvalues=1:3;

styles={'-.',':o','-.x','-*','--+','-s','-p','-.',':o','-.x','-*','--+','-s','-p'};

figure
for patchtypenum=1:length(patchtypes)
    patchtype=patchtypes{patchtypenum};
    subplot(1,length(patchtypes),patchtypenum)
    allpsnr=zeros(2,length(varvalues),treedepth2);

    for varvaluenum=1:length(varvalues)
%         eval([varname,'=',num2str(varvalues(varvaluenum)),';'])
        
        if trainpatches2>=1000000
            sizedescrip=[num2str(floor(trainpatches2/1000000),1),'m'];        
        elseif trainpatches2>=1000
            sizedescrip=[num2str(floor(trainpatches2/1000),1),'k'];
        else
            sizedescrip=num2str(trainpatches2);
        end

        savefilename=['table','_',num2str(varvaluenum),'_',sizedescrip,'_',num2str(blockwidth),'_',num2str(treedepth2),'_',num2str(flatthreshold),'_',patchtype];
        load([pwd,seperator,'Results',seperator,foldername,seperator,savefilename,'.mat'])
        
        for currenttreedepth=1:treedepth2
            clustersatdepth=2^(currenttreedepth-1):(2^currenttreedepth-1);
            freqs=trainfreqs(clustersatdepth);
            %Adjust above line when new data is run to testfreqs instead of
            %trainfreqs

            freqs(end+1)=mean(clustermembers==0);    
            currentpsnrs=[psnrclusters(:,clustersatdepth),psnrcluster0];
            allpsnr(:,varvaluenum,currenttreedepth)=10*log10(255^2./(freqs*(255^2./10.^(currentpsnrs'/10))));
        end
    end 
    
    legendstrs=[];
    for missingcolornum=1:2
        if missingcolors(missingcolornum)==1
            color='r';
        elseif missingcolors(missingcolornum)==2
            color='g';
        elseif missingcolors(missingcolornum)==3
            color='b';
        end
        for currenttreedepth=1:treedepth2             
            plot(varvalues,allpsnr(missingcolornum,:,currenttreedepth),[color,styles{currenttreedepth}])
            hold on
            legendstrs{end+1}=['treedepth=',num2str(currenttreedepth)];
        end
    end   
    grid on
    xlabel(varname)
    ylabel('PSNR (dB)')
    title(['Patchtype=',patchtype])
end
legend(legendstrs)


%% Plot of Flatthreshold (varvalue) vs % in Centroid 0

foldername='flatthreshold-k07';

seperator='\';
load([pwd,seperator,'Results',seperator,foldername,seperator,'descrip.mat'])

figure
legendstrs=[];
for patchtypenum=1:length(patchtypes)
    patchtype=patchtypes{patchtypenum};
    percent0=zeros(1,length(varvalues)); 
    for varvaluenum=1:length(varvalues)
        eval([varname,'=',num2str(varvalues(varvaluenum)),';'])
        
        if trainpatches2>=1000000
            sizedescrip=[num2str(floor(trainpatches2/1000000),1),'m'];        
        elseif trainpatches2>=1000
            sizedescrip=[num2str(floor(trainpatches2/1000),1),'k'];
        else
            sizedescrip=num2str(trainpatches2);
        end

        savefilename=['table','_',num2str(varvaluenum),'_',sizedescrip,'_',num2str(blockwidth),'_',num2str(treedepth2),'_',num2str(flatthreshold),'_',patchtype];
        load([pwd,seperator,'Results',seperator,foldername,seperator,savefilename,'.mat'])
        percent0(:,varvaluenum)=100*(1-testfreqs(1));
    end

    if patchtype=='R'
        plot(varvalues,percent0,'-xr')
        legendstrs{end+1}='R patch';
    elseif patchtype=='B'
        plot(varvalues,percent0,'-xb')
        legendstrs{end+1}='B patch';
    else
        plot(varvalues,percent0,'-xg')
        legendstrs{end+1}='G patch';        
    end
    hold on
end
grid on
xlabel(varname)
ylabel('% in Cluster 0')
legend(legendstrs,'Location','SouthEast')