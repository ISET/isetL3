function [reim,reimglobal,clustermemberim,time,luminanceindexim]=...
    L3applypipeline2image(cfa,cfapattern,filename,maxbatchsize,...
    treedepth,nummissingcolors)
%Apply  L^3 processing pipeline to a sensor voltage image
%
%  [reim,reimglobal,clustermemberim,time,luminanceindexim]=...
%    L3applypipeline2image(cfa,cfapattern,filename,maxbatchsize,treedepth,nummissingcolors)
%
%INPUTS:
%   cfa:        matrix of cfa measurements (size(cfa)=m x n)
%   cfapattern: matrix giving the spatial pattern of the filters,
%                   each entry is between 1-3 (represent RGB filters)
%   filename:   string containing the root for a file containing the L^3
%               filters, centroids, etc to use, loaded file is appended with
%               patchtype to the end of filename
%   maxbatchsize: scalar giving the maximum number of patches to calculate at
%               once, helps control the memory requirements but does not
%               affect the results
%   treedepth:  scalar giving treedepth to use
%               (even though more may exist in table)
%   nummissingcolors:  number of bands in desired output image
%
%
%
%OUTPUTS:  (images have black borders where patch doesn't fit)
%   reim:       estimated image from L^3 algorithm
%   reimglobal: estimated image from global linear filtering
%   clustermemberim:  image showing which cluster each pixel was in, (this
%                    has a different meaning if the pixel was R, G, or B)
%   time:       structure containing the time in seconds required for
%               various stages of the calculation
%   luminanceindexim:  image where each pixel has the index of the closest
%                      trained patch luminance value for the patch centered
%                      at that pixel
%
% Copyright Steven Lansel, 2010


%% Setup for actual calculation
global patches

load([filename,'1_11'],'patchluminancesamples','luminancefilter',...
    ,'blockpattern','blockwidth')   %load the first type of patch to collect basic parameters

reim=zeros(size(cfa,1),size(cfa,2),nummissingcolors);
reimglobal=zeros(size(cfa,1),size(cfa,2),nummissingcolors);
clustermemberim=zeros(size(cfa,1),size(cfa,2));
if nargout>=5
    luminanceindexim=zeros(size(cfa,1),size(cfa,2));
end
cfawidthx=size(cfapattern,1);
cfawidthy=size(cfapattern,2);

%Initialize time to 0 and these fields will be added up eacg tune
%L3pipeline.m is called.
time.findmeans=0;
time.meanremoval=0;
time.findcontrast=0;
time.contrastthreshold=0;
time.flip=0;
time.findtexturecluster=0;
time.flatestimate=0;
time.textureestimate=0;

for xinblockpattern=1:size(cfapattern,1)
    for yinblockpattern=1:size(cfapattern,2)
        patchtype=[num2str(xinblockpattern),num2str(yinblockpattern)];
        
        
        %rangex is the rows of the images that will be used for metric
        %calculations, this excludes border region
        rangex=xinblockpattern:cfawidthx:size(cfa,1);
        rangex(find(rangex<=floor(blockwidth(1)/2) | rangex>=size(cfa,1)-floor(blockwidth(1)/2)))=[];
        numpatchesx=length(rangex);
        
        %rangey is the columns of the images that will be used for metric
        %calculations, this excludes border region
        rangey=yinblockpattern:cfawidthy:size(cfa,2);
        rangey(find(rangey<=floor(blockwidth(2)/2) | rangey>=size(cfa,2)-floor(blockwidth(2)/2)))=[];
        numpatchesy=length(rangey);
        
        xhat=zeros(nummissingcolors,numpatchesx*numpatchesy);
        xhatglobal=zeros(nummissingcolors,numpatchesx*numpatchesy);
        clustermembers=zeros(1,numpatchesx*numpatchesy);
        luminanceindex=zeros(1,numpatchesx*numpatchesy);
        
        rangexindex=1;
        rangeyindex=1;
        patchnumoffset=0;
        maxbatches=ceil(numpatchesx*numpatchesy/maxbatchsize);  %number of batches required
        for batchnum=1:maxbatches   %each batch is a set of patches of size less than maxbatchsize
            patchnums=min(maxbatchsize,numpatchesx*numpatchesy-patchnumoffset);
            allpatches=zeros(length(blockpattern(:)),patchnums);
            for patchnum=1:patchnums    %iterate through each pixel and add its associated patch
                
                allpatches(:,patchnum)=reshape(cfa(rangex(rangexindex)+(-floor(blockwidth(1)/2):floor(blockwidth(1)/2)),rangey(rangeyindex)+(-floor(blockwidth(2)/2):floor(blockwidth(2)/2)),:),length(blockpattern(:)),1);
                
                if rangexindex==numpatchesx
                    rangexindex=1;
                    rangeyindex=rangeyindex+1;
                else
                    rangexindex=rangexindex+1;
                end
            end
            
            
            %% Find luminance for each patch
            patchluminances=luminancefilter*allpatches;
            differences=repmat(patchluminances',1,length(patchluminancesamples))-repmat(patchluminancesamples,length(patchluminances),1);
            [junk,luminanceindex(patchnumoffset+(1:patchnums))]=min(abs(differences'));
            
            %% Following does actual estimation
            for patchluminancesamplenum=1:length(patchluminancesamples)
                patchrange=find(luminanceindex(patchnumoffset+(1:patchnums))==patchluminancesamplenum);
                if any(luminanceindex(patchrange)==patchluminancesamplenum)
                    patches=allpatches(:,patchrange);
                    
                    %load L^3 data saved from L3trainpipeline.m
                    load([filename,num2str(patchluminancesamplenum),'_',patchtype],...
                        'meansfilter','blockpattern','noisyflatthreshold','flip','pcas',...
                        'thresholds','projection','flatfilters','texturefilters',...
                        'globalpipelinefilter')
                    
                    maxpcanum=2^(treedepth-1)-1;
                    clusterrange=(maxpcanum+1):(2^treedepth-1);
                    
                    [time,clustermembers(patchnumoffset+patchrange),snrflat,snrtexture,freqtexture,xhat(:,patchnumoffset+patchrange),xhatglobal(:,patchnumoffset+patchrange)]=...
                        L3pipeline(meansfilter,blockpattern,noisyflatthreshold,flip,time,pcas(:,1:maxpcanum),...
                        thresholds,projection,flatfilters,texturefilters,treedepth,[],clusterrange,globalpipelinefilter);
                end
            end
            
            patchnumoffset=patchnumoffset+patchnum;
        end
        
        %% Put results back into image
        reim(rangex,rangey,1:nummissingcolors)=permute(reshape(xhat,nummissingcolors,numpatchesx,numpatchesy),[2,3,1]);
        reimglobal(rangex,rangey,1:nummissingcolors)=permute(reshape(xhatglobal,nummissingcolors,numpatchesx,numpatchesy),[2,3,1]);
        clustermemberim(rangex,rangey)=reshape(clustermembers,numpatchesx,numpatchesy);
        luminanceindexim(rangex,rangey)=reshape(luminanceindex,numpatchesx,numpatchesy);
    end     %loop for yinblockpattern
end     %loop for xinblockpattern

