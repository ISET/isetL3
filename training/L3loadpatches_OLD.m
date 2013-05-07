function [patches,centeroutput,cameraparams]=...
    L3loadpatches(dataset,indexes,imagenums,blockpattern,nummissingcolors,...
    maxx,maxy,desiredluminance,luminancefilter,saturationflag)

%L3LOADPATCHES loads patches and scales them to the desired patch luminance
%
% [patches,centeroutput,cameraparams] = L3loadpatches(dataset,indexes,...
%   imagenums,blockpattern,nummissingcolors,maxx,maxy,desiredluminance,...
%   luminancefilter,saturationflag)
%
%INPUTS:
%   dataset:        string containing name of dataset 
%   indexes:        vector giving the encoded location of each pixel
%   imagenums:      vector giving indexes of images to pull from
%   blockpattern:   3-D array containing ones in each place where
%                   measurements are taken
%   nummissingcolors:  number of bands in desired output image
%   maxx, maxy:     scalars giving the size of the images
%   desiredluminance: scalar giving the desired luminance value of the
%                     output scaled patch
%   luminancefilter:  vector same length as patch that gives the patch's
%                     luminance by luminancefilter*patch
%   saturationflag: binary turning saturation on (flag=1) or off (flag=0)
%
%OUTPUTS:
%   patches:        matrix with columns giving patches stacked in a vector
%                   (size(patches)= sum(blockpattern(:)) x numpatches)
%   centeroutput:   matrix giving the values at the center pixel for all
%                   desired output bands
%                   (size(centeroutput)=nummissingcolors x numpatches)
%   cameraparams:   structure giving simulation parameters for noise
%
% Copyright Steven Lansel, 2010

blockwidth(1)=size(blockpattern,1);
blockwidth(2)=size(blockpattern,2);

%Vindices will be the indexes in the patches vector corresponding with the
%entries in the patch image that are indexed by pindices.  Specifically
%we are getting ready to do patches(vindices,patchnum)=patch(pindices).
%This format means we can also quickly convert CFA patches to patch vectors
%that are consistent with this notation by doing patch(:).

%following allows for the possibility that multiple bands are measured at a
%pixel
vindices=[];
sumblockpattern=cumsum(blockpattern,3);
for sumvalue=1:max(sumblockpattern(:))
    offset=sum(0<sumblockpattern(:) & sumblockpattern(:)<sumvalue);
    for layernum=1:size(blockpattern,3)
        vindices=[vindices;offset+find(blockpattern(:,:,layernum) & sumblockpattern(:,:,layernum)==sumvalue)];
    end
end

pindices=find(blockpattern);
    
maxx=maxx-2*floor(blockwidth(1)/2);
maxy=maxy-2*floor(blockwidth(2)/2);

patches=zeros(sum(blockpattern(:)),length(indexes));
centeroutput=zeros(nummissingcolors,length(indexes));

[imnums,blockxstarts,blockystarts]=index2pixel(indexes,maxx,maxy);
oldimnum=0;
for patchnum=1:length(indexes)
    if imagenums(imnums(patchnum))~=oldimnum
        oldimnum=imagenums(imnums(patchnum));
        
        savefilename=[dataset,'_',num2str(oldimnum),'.mat'];
        data=load(savefilename,'cameraparams','inputim','desiredim','illuminantlevel');
        cameraparams=data.cameraparams;
        inputim=data.inputim;
        desiredim=data.desiredim;
        
        if ~saturationflag
            cameraparams.voltageSwing=inf;   %saturation value
        end
        

        if exist('illuminantlevel','var') && ~isempty(illuminantlevel)
            inputim=inputim*illuminantlevel; %adjust illuminant by scalar implies scaling image
            desiredim=desiredim*illuminantlevel; %adjust illuminant by scalar implies scaling image
        end

    end
    blockxstart=blockxstarts(patchnum);
    blockystart=blockystarts(patchnum);
    patch=inputim(blockxstart+(0:blockwidth(1)-1),blockystart+(0:blockwidth(2)-1),:);
    patches(vindices,patchnum)=patch(pindices);
    centeroutput(:,patchnum)=squeeze(desiredim(blockxstart+floor(blockwidth(1)/2),blockystart+floor(blockwidth(2)/2),:));
    
    %Scale each patch so the patchluminance matches desiredluminance
    saturate=cameraparams.voltageSwing;   %saturation value
    [patches(:,patchnum),centeroutput(:,patchnum)]=L3scalepatchluminance(patches(:,patchnum),centeroutput(:,patchnum),desiredluminance,luminancefilter,saturate);
end


%% INDEX2PIXEL decodes location of pixels from encoded index numbers
%
%[imnum,x,y]=index2pixel(index,maxx,maxy)
%
%INPUTS:  
%   index:  vector giving a number describing location of pixels
%   maxx:   scalar giving the number of columns in an image
%   maxy:   scalar giving the number of rows in an image
%
%GLOBAL INPUT AND OUTPUT:
%   imnum:  vector giving the number of the image that each pixel was from
%   x:      vector giving the number of the column that each pixel was from
%   y:      vector giving the number of the row that each pixel was from
%
%   Note all images must be the same size.
%   pixel2index performs the inverse of this function

function [imnum,x,y]=index2pixel(index,maxx,maxy)


imnum=ceil(index/maxx/maxy);
index=index-(imnum-1)*maxx*maxy;
x=ceil(index/maxy);
y=index-(x-1)*maxy;