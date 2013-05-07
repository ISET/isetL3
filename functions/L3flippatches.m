function L3 = L3flippatches(L3)
% L3 = L3flippatches(L3)
% Flips texture patches before hierarchical clustering
%
%    L3 = L3flippatches(L3)
%
% (c) Stanford VISTA Team

if ieNotDefined('L3'), error('L3 required'); end

patches        = L3Get(L3,'sensor patches');
textureindices = L3Get(L3,'texture indices');
flip      = L3Get(L3,'flip');
blocksize = L3Get(L3,'block size');
blockpattern = L3Get(L3,'block pattern');


%% Flip across vertical line so left side has higher average than right side
if flip.v
    selected = false(blocksize);
    selected(:,1:floor(blocksize(2)/2)) = true;   %pixels on left side of pattern
    flipcommand = 'fliplr';

    [lindexes,rindexes] = findindexes(selected, flipcommand, blockpattern);    

    % These are the patches whose left indices sum to less than their right
    % indices.  
    needflip = false(size(textureindices));
    textureneedflip = sum(patches(lindexes,textureindices)) ...
                              < sum(patches(rindexes,textureindices));
    needflip(textureindices) = textureneedflip;                        
    
    patches([lindexes,rindexes],needflip) = ...
        patches([rindexes,lindexes],needflip);
end

%% Flip across horizontal line so top has higher average than bottom
if flip.h
    selected = false(blocksize);
    selected(1:floor(blocksize(2)/2),:) = true;   %pixels on left side of pattern
    flipcommand = 'flipud';

    [tindexes,bindexes] = findindexes(selected,flipcommand,blockpattern);    
    
    % These are the patches whose top indices sum to less than their
    % bottom indices.    
    needflip = false(size(textureindices));
    textureneedflip = sum(patches(tindexes,textureindices)) ...
                              < sum(patches(bindexes,textureindices));
    needflip(textureindices) = textureneedflip;        
    
    patches([tindexes,bindexes],needflip) = ...
        patches([bindexes,tindexes],needflip);
end

%% Flip across diagonal so upper triangular has higher average than lower triangular
if flip.t

    selected  =triu(ones(blocksize))-eye(blocksize);
    selected = (selected==1);  %pixels above main diagonal
    flipcommand = 'transpose';

    [uindexes,lindexes] = findindexes(selected,flipcommand,blockpattern);
    
    % These are the patches whose above the diagonal indices sum to less
    % than their below the diagonal indices.
    needflip = false(size(textureindices));
    textureneedflip = sum(patches(lindexes,textureindices)) ...
                              > sum(patches(uindexes,textureindices));
    needflip(textureindices) = textureneedflip;
    
    patches([uindexes,lindexes],needflip) = ...
        patches([lindexes,uindexes], needflip);
end

L3 = L3Set(L3,'sensor patches saturation case',patches);

end


% Figures out which entries are on each patch half
function [indexes1,indexes2] = findindexes(selected,flipcommand,blockpattern)
%
%  [indexes1,indexes2]=findindexes(selected,flipcommand,blockpattern)
%
%INPUTS:
%   selected:       binary matrix with same number of rows and columns as
%                   blockpattern, value of 1 means it is on the half
%                   desired for indexes1, value of 0 means it is not
%   flipcommand:    string giving command applied to matrix to flip it in
%                   desired fashion
%   blockpattern:   matrix containing index of color channel that is
%                   measured at each pixel in the patch    (can be 3-D 
%                   array if multiple measurements at each pixel)
%
%OUTPUTS:
%   indexes1:       Location of the measurements in a patch that are on the
%                   selected side
%   indexes2:       Location of the measurements in a patch that are on the
%                   side achieved by flipping the selected side
%
% The challenge is that we need the pixel at indexes1(n) when the patch is
% flipped to correspond with the pixel at indexes2(n), for all n.
%
% This function would not be needed if there is only one measurement at
% each pixel.  This more complex sub-function is needed in the
% general case though.

blockwidth(1)=size(blockpattern,1);
blockwidth(2)=size(blockpattern,2);
maxinputcolor=max(blockpattern(:));

fullim1=zeros(blockwidth(1),blockwidth(2),maxinputcolor);  %fullim1 will have unique number in selected pixels
fullim2=zeros(blockwidth(1),blockwidth(2),maxinputcolor);  %fullim2 will be flipped version of fullim1
currentindex=0;

for colornum=1:maxinputcolor
    fullim1layer=zeros(blockwidth);
    measuredpixels=(blockpattern==colornum);    %which pixels measure the current color
    fullim1layer(selected)=(currentindex+(1:sum(selected(:))))'.*measuredpixels(selected);
    fullim1(:,:,colornum)=fullim1layer;
    
    fullim2(:,:,colornum)=eval([flipcommand,'(fullim1layer)']);
    
    currentindex=currentindex+sum(selected(:));
end


%sample the blockpatterns according to the CFA
cfaside1 = sensorRGB2Plane(fullim1,blockpattern);
cfaside2 = sensorRGB2Plane(fullim2,blockpattern);

%Now cfaside1 and cfaside2 contain unique positive numbers for each
%measurement that is on the corresponding side of the patch.  The
%entries in cfaside1 and cfaside2 that have the same number
%correspond to each other when flipped.

indexes1=zeros(1,sum(cfaside1(:)>0));
indexes2=zeros(size(indexes1));
%iterate through each of the positive entries and record their
%location
currentmin=0;   %always contains the current smallest entry in the cfasides
for indexnum=1:length(indexes1)
    cfaside1(cfaside1(:)==currentmin)=inf;
    currentmin=min(cfaside1(:));
    indexes1(indexnum)=find(cfaside1(:)==currentmin);
    indexes2(indexnum)=find(cfaside2(:)==currentmin);
end

end
