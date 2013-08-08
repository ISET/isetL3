function im = L3imcrop(L3,im)
% Crop the image according to the L3 border width
%
%   im = L3imcrop(L3,im)
%
% The L3 algorithm cannot give estimates near the border of an image.  In
% order to get an estimate, L3 needs a patch centered at the desired pixel.
% Near the edges of an image, there are not enough rows or columns to form
% a patch.  This function crops to remove the border.
%
% The width of the border is half the patch width and rounded down.
%
% (c) Stanford VISTA Team, 2012

borderWidth = L3Get(L3,'border width');
im = im(borderWidth:end-borderWidth,  borderWidth:end-borderWidth, :);

end

