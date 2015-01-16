function lrgb = xyz2lrgb(xyz)
%Convert CIE XYZ to sRGB color space
%
%  [srgb,lrgb,maxY] = xyz2srgb(xyz)
%
% The CIE XYZ values are in an RGB Format image. They are converted to sRGB
% values. The user can also get linear RGB values as well as the Y value
% (maxY) that is used to scale the XYZ image so that it is within the [0,1]
% range as required by the sRGB standard.
%
% The sRGB color space is a display-oriented representation that matches
% a Sony Trinitron. The monitor white point is assumed to be D65.  The
% white point chromaticity are (.3127,.3290), and for an sRGB display
% (1,1,1) is assumed to map to XYZ = ( 0.9504    0.9999    1.0891).
% The RGB primaries of an srgb display have xy coordinates of
%    xy = [.64, .3; .33, .6; .15, .06]
%
% The overall gamma of an sRGB display is about 2.2, but this is because at
% low levels the value is linear and at high levels the gamma is 2.4.  See
% the wikipedia page for a discussion.
%
% sRGB values run from [0 1].  At Imageval this assumption changed from the
% range [0 255] on July 2010. This was based on the wikipedia entry and
% discussions with Brainard.  Prior calculations of delta E are not changed
% by this scale factor.
%
% The linear srgb values (lRGB) can also be returned. These are the values
% of the linear phosphor intensities, without any gamma or clipping
% applied. lRGB values nominally run from [0,1], but we allow them to be
% returned  outside of this range.  
%
% Modern reference:    http://en.wikipedia.org/wiki/SRGB
% Original Reference:  http://www.w3.org/Graphics/Color/sRGB
%
% See also:  colorTransformMatrix, lrgb2srgb, and imageLinearTransform.
%
% Copyright ImagEval Consultants, LLC, 2003.

%% Notes

% This xyz -> sRGB matrix is supposed to work for XYZ values scaled so that
% the maximum Y value is around 1.  In the Wikipedia page, they write:
%
%   if you start with XYZ values going to 100 or so, divide them by 100
%   first, or apply the matrix and then scale by a constant factor to the
%   [0,1] range).  
%
% They add
%
%    display white represented as (1,1,1) [RGB]; the corresponding original
%    XYZ values are such that white is D65 with unit luminance (X,Y,Z =
%    0.9505, 1.0000, 1.0890).
%

%%
% The matrix converts (R,G,B)*matrix.  This is the transpose of the
% Wikipedia page.
matrix = colorTransformMatrix('xyz2srgb');

% Notice that (1,1,1) maps into D65 with unit luminance (Y)
% matrix = colorTransformMatrix('srgb2xyz');
% ones(1,3)*matrix

% The linear transform is built on the assumption that the maximum
% luminance is 1.0.  If the inputs are all within [0,1], I suppose we
% should leave the data alone. If the maximum XYZ value is outside the
% range, we need to scale. We return the true maximum luminance in the
% event the user wants to invert, later.
lrgb = imageLinearTransform(xyz, matrix);

return;

