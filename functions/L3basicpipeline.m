function [reim,time]=L3basicpipeline(cfa,cfapattern,sensorQE,targetQE,wave)

%L3BASICPIPELINE performs bilinear demosaicing and linear color conversion
%
%[reim,time]=L3basicpipeline(cfa,cfapattern,sensorQE,targetQE,wave)
%
%INPUTS:
%   cfa:            Matrix of cfa measurements (size(cfa)=m x n)
%   cfapattern:     Matrix giving CFA block pattern where the entry
%                   corresponds to the filters in filterSpectra
%                   size(cfapattern) = rows x cols
%   sensorQE:       Matrix giving camera sensitivities
%                   size(sensorQE)=length(wave) x number filters
%   targetQE:       Matrix giving sensitivites of desired output space
%                   size(targetQE)=length(wave) x number filters
%   wave:           Vector giving the wavelength samples
%
%OUTPUTS:
%   reim:       Demosaiced image (with black border where patch is too big)
%               (size(reim)=m x n x 3)
%   time:       Structure giving the time in seconds of parts of the
%               calculation
%
% Copyright Steven Lansel, 2010


%% Conversion of CFA data to 3 channel image with holes
tic     %starts clock for timing
[numxs,numys]=size(cfa);    %dimensions of the image
blockwidthx=size(cfapattern,1);    %height of the block filter pattern
blockwidthy=size(cfapattern,2);    %width of the block filter pattern
mosaic=zeros(numxs,numys,max(cfapattern(:))); %will hold measurements
for xinblock=1:blockwidthx   %iterate through all pixels in the block in the vertical direction
    for yinblock=1:blockwidthy   %iterate through all pixels in the block in the vertical direction
        mosaiclayer=cfapattern(xinblock,yinblock);
        mosaic(xinblock:blockwidthx:end,yinblock:blockwidthy:end,mosaiclayer)=cfa(xinblock:blockwidthx:end,yinblock:blockwidthy:end);
    end
end
time.setup=toc;     %stops clock for timing and saves result

%% Bilinear Demosaicking
tic
img = Bilinear(mosaic, cfapattern);
time.demosaic=toc;

%% Color Conversion from Sensor to Target Output Color Space
tic
T = imageMCCTransform(sensorQE,targetQE,'D65',wave);    %find optimal linear transformation for MCC under D65
reim = imageLinearTransform(img,T); %apply linear transformatoin
time.colortransform=toc;