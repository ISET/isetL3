function filter=L3enforcesymmetry(filter,nummissingcolors,blockpattern,flip)

%L3ENFORCESYMMETRY forces a filter to have certain symmetries as motivated by
%assumption of direction independence
%
% filter=L3enforcesymmetry(filter,nummissingcolors,blockpattern,flip)
%
%INPUTS
%   filter:         matrix where the vectors are a filter for a patch
%                   (typically is a global filter)
%   nummissingcolors:  number of bands in desired output image
%   blockpattern:   matrix containing index of color channel that is
%                   measured at each pixel in the patch    (can be 3-D 
%                   array if multiple measurements at each pixel)
%   flip:           structure containing binaries that determine whether a 
%                   flipping operation should be performed along a direction
%
%OUTPUT
%   filter:         matrix giving the transformed symmetric filters
%
% Copyright Steven Lansel, 2010

blockwidth(1)=size(blockpattern,1);
blockwidth(2)=size(blockpattern,2);
for colornum=1:nummissingcolors
    %Enforce symmetry
    if ~isempty(flip) & flip.v
        filter(colornum,:)=reshape((fliplr(reshape(filter(colornum,:),blockwidth(1),blockwidth(2)))+reshape(filter(colornum,:),blockwidth(1),blockwidth(2)))/2,prod(blockwidth),1);
    end
    if ~isempty(flip) & flip.h
        filter(colornum,:)=reshape((flipud(reshape(filter(colornum,:),blockwidth(1),blockwidth(2)))+reshape(filter(colornum,:),blockwidth(1),blockwidth(2)))/2,prod(blockwidth),1);
    end
    if ~isempty(flip) & flip.t
        %transpose symmetry
        filter(colornum,:)=reshape((reshape(filter(colornum,:),blockwidth(1),blockwidth(2))'+reshape(filter(colornum,:),blockwidth(1),blockwidth(2)))/2,prod(blockwidth),1);
    end
end