function img = L3plotpatches(L3,indices,row,col,borderW)
% Show selected patches in groups in figures of 10 x 10 patches
%
% img = L3plotpatches(L3,indices,border)
%
% Inputs
%  L3           L3 structure
%  indices      vector used to choose which patches to show  (this
%               should be a reasonable number of patches)
%  border       (optional)  binary vector the same length as indices that has a 1
%               in each entry if the corresponding patch should be
%               outlined in red
% Example:
%   indices = 101:200;
%   img = L3plotpatches(L3,indices,10,10,1); vcNewGraphWin; imagesc(img); axis image, axis off
%
% Right now the result is a monochrome image where the colors of each pixel
% in the patch is ignored.  This should probably be changed.
%
% (c) Stanford VISTA Team, 2012

%%

if ieNotDefined('row'), row = 10; col = 10;  end
if ieNotDefined('borderW'), borderW = 1; end

% Number of patch rows and cols
patches = L3Get(L3,'sensor patches');
patches = patches(:,indices);

blocksize = L3Get(L3,'blocksize');
bPattern  = L3Get(L3,'block pattern');
bPattern  = padarray(bPattern,[1 1],1);

sensor   = L3Get(L3,'design sensor');
warning('off') %#ok<*WNOFF>
sensor   = sensorSet(sensor,'pattern',bPattern);
sensor   = sensorSet(sensor,'size',size(bPattern));
warning('on') %#ok<*WNON>

%% Set up the sensor with the patch type CFA
%  Then fill the sensor data with some patch data
%  Then call sensorData2Image and hope for the best
patches = reshape(patches,blocksize(1),blocksize(2),row*col);
volts   = zeros((blocksize(1) + borderW*2)*row,(blocksize(2) + borderW*2)*col);
idx = 0;
for rr=1:row
    for cc = 1:col
        idx = idx + 1;
        c = (cc-1)*(blocksize(1) + borderW*2) + borderW;
        r = (rr-1)*(blocksize(2) + borderW*2) + borderW;
        volts(c + (1:blocksize(1)),r + (1:blocksize(2))) = patches(:,:,idx);
    end
end

sensor = sensorSet(sensor,'volts',volts);
scaleFlag = 1;
img = sensorData2Image(sensor,'volts',0.6,scaleFlag);

vcNewGraphWin; imagesc(img); axis image, axis off

end

%%

% Following scaling should not be needed because we are using imagesc and
% it is a monochrome image.
% if min(patches(:))<0
%     patches=patches-min(patches(:));
% end
% patches=patches/max(patches(:));

% If there are more than 100 patches, they are shown in batches of 100.
% The number of batches needed
% maxbatchnum=min(3,ceil((size(patches,2)/100)));
% 
% for batchnum=1:maxbatchnum
%     %patchim will hold the patches for this batch to show
%     patchim=zeros((blocksize(1)+2)*10,(blocksize(2)+2)*10);
%     
%     %indexes of patches to show for this batch
%     patchnums=(100*(batchnum-1)+1):(min(100*batchnum,size(patches,2)));        
%     
%     for patchindex=1:length(patchnums)        
%         patchnum=patchnums(patchindex);
%         
%         %out of a 10x10 grid, this patch will be in position row,col
%         row=mod(patchindex,10);
%         if row==0
%             row=10;
%         end
%         col=ceil(patchindex/10);
% 
%         %Following places patches so there is a line 2 pixels wide between
%         %adjacent patches.
%         %Location of the top left corner of the patch in pixels of patchim:
%         colstart=(col-1)*(blocksize(1)+2)+1;
%         rowstart=(row-1)*(blocksize(2)+2)+1;
% 
%         patch=reshape(patches(:,patchnum),blocksize(1),blocksize(2));
%         patchim(colstart+(1:blocksize(1)),rowstart+(1:blocksize(2)),:)=patch;
% 
%         %If a border is desired around a patch, the 1 pixel wide line
%         %around a patch is colored red and otherwise is black.
%         if nargin==3
%             if border(patchnum)
%                 bordercolor=1;
%             else
%                 bordercolor=[];
%             end
%             patchim(colstart, rowstart+(0:blocksize(2)), bordercolor)=1;
%             patchim(colstart+blocksize(1)+1, rowstart+(0:(blocksize(2)+1)), bordercolor)=1;
%             patchim(colstart+(0:blocksize(1)), rowstart, bordercolor)=1;
%             patchim(colstart+(0:blocksize(1)), rowstart+blocksize(2)+1, bordercolor)=1;            
%         end        
%     end
%     
%     figure
%     imagesc(patchim)
%     axis image
%     axis off    
% end
