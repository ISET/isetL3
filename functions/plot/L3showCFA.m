function cfa=L3showCFA(cfapattern,filterTransmissions,wave,numpatches,...
    patchwidth,borderwidth,sigma)

%L3SHOWCFA generates a figure with the CFA pattern illustrated
%
% cfa=L3showCFA(cfapattern,filterTransmissions,wave,numpatches,...
%               patchwidth,borderwidth,sigma)
%
%INPUTS:
%   cfapattern:     Matrix describing the CFA arrangement with entries
%                   corresponding to which column of the filter is desired
%   filterTransmissions:    Matrix giving camera sensitivities
%                   size(filterTransmissions)=length(wave) x number filters
%   wave:           Vector giving the wavelength samples
%   numpatches:     Length 2 vector giving the number of rows and columns
%                   of pixels in the CFA to show
%   patchwidth:     Number of pixels that make up each CFA pixel in the 
%                   drawn figure
%   borderwidth:    Number of black pixels between each CFA pixel in the
%                   drawn figure
%   sigma:          (Optional)  Scalar that gives standard deviation of
%                   Gaussian to add to the color of each CFA pixel, used to
%                   show noise
%
%OUTPUTS:
%   cfa:            Matrix giving RGB image that was displayed
%
% Copyright Steven Lansel, 2011


% Following helps run with new camera structure
%         L3 = camera.vci.L3;
%         inputfilters = L3.sensor.design.color.filterSpectra
%         cfapattern = L3.sensor.design.cfa.pattern;
% 
%         % Convert cfapattern to new data structure, call result cfapatern2
%         cfapattern2 = zeros(size(cfapattern,1),size(cfapattern,2),3);
%         for colornum = 1:size(inputfilters,2)
%             cfapattern2(:,:,colornum) = (cfapattern==colornum);
%         end
% 
%         L3showCFA(cfapattern2,inputfilters,wave,numpatches,patchwidth,borderwidth,sigma);

addpath(genpath(L3rootpath))
tmp=load('D65');
D65=interp1(tmp.wavelength,tmp.data,wave);  %D65 light

D65=D65';

filterspectra=filterTransmissions'.*repmat(D65,size(filterTransmissions,2),1); %estimated spectra under D65

tmp=load('XYZ');
XYZ=interp1(tmp.wavelength,tmp.data,wave);
filterXYZ=filterspectra*XYZ;

xyz=filterXYZ;
xyz = xyz/max(xyz(:,2));

srgb = permute(xyz2srgb(permute(xyz,[1,3,2])),[1,3,2]);
srgb=permute(srgb,[1,3,2]);

sizex=numpatches(1)*patchwidth+(numpatches(1)+1)*borderwidth;
sizey=numpatches(2)*patchwidth+(numpatches(2)+1)*borderwidth;
cfa=zeros(sizex,sizey,3);
for patchx=1:numpatches(1)
    startindexx=(patchx-1)*patchwidth+patchx*borderwidth+1;
    cfaindexx=mod(patchx-1,size(cfapattern,1))+1;    
    for patchy=1:numpatches(2)
        startindexy=(patchy-1)*patchwidth+patchy*borderwidth+1;
        cfaindexy=mod(patchy-1,size(cfapattern,2))+1;
        
        filternum=find(cfapattern(cfaindexx,cfaindexy,:));
  
        currentsrgb=srgb(filternum,:,:);        
        currentsrgb=srgb(filternum,:,:)/max(srgb(filternum,:,:));   %makes sure all colors are bright
        if nargin==7
            noise=abs(1-abs(randn*sigma));
            currentsrgb=currentsrgb*noise;
        end
        cfa(startindexx+(0:(patchwidth-1)),startindexy+(0:(patchwidth-1)),:)=repmat(currentsrgb,patchwidth,patchwidth);        
    end
end


figure
image(cfa)
axis image
axis off