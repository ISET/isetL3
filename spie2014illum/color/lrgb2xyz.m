function xyz = lrgb2xyz(lrgb)
% Transform lrgb to CIE XYZ
%
%    xyz = lrgb2xyz(lrgb)
% 
% lRGB:  RGB format image
% xyz :  RGB format image
%
% Convert sRGB image into CIE XYZ values.
% The input range for lrgb values is (0,1).
%
% Copyright ImagEval Consultants, LLC, 2003.

% Data format should be in RGB format
if ndims(lrgb) ~= 3
    error('lrgb2xyz:  lrgb must be a NxMx3 color image.  Use XW2RGBFormat if needed.');
end

% convert lrgb to xyz 
matrix = colorTransformMatrix('lrgb2xyz');
xyz = imageLinearTransform(lrgb, matrix);  

return;