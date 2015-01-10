function [desiredImSamp, inputImSamp] = L3SampleSensorImage(desiredIm, inputIm, L3, nSamples)

if ieNotDefined('nSamples'), nSamples = 50; end
desiredImSamp = cell(nSamples,1);
inputImSamp = cell(nSamples,1);

nImages = length(inputIm);

totalPatches = [];
blockSize = L3Get(L3, 'block size');

for ii = 1:nImages
    sz = size(inputIm{ii});
    nPatches = (sz(1)-blockSize(1)+1)*(sz(2)-blockSize(2)+1);
    totalPatches = [totalPatches, nPatches];
end

keep = randperm(sum(totalPatches));
keep = keep(1:nSamples);

for jj = 1:length(keep)
   kk = find( keep(jj) < cumsum(totalPatches), 1 );
   ll = keep(jj) - sum( totalPatches(1:kk-1) );
   rr = floor( ll / (sz(2)-blockSize(2)+1) );
   cc = ll - rr * (sz(2)-blockSize(2)+1);
   
   desiredImSamp{jj} = desiredIm{kk}(rr+(1:blockSize(1)),cc+(1:blockSize(2)),:);
   inputImSamp{jj} = inputIm{kk}(rr+(1:blockSize(1)),cc+(1:blockSize(2)),:);
end

