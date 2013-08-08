function A = L3findRGBWcolortransform(L3)
% Find transform from XYZ to opponent color space that depends on W
%
%  A = L3findRGBWcolortransform(L3)
%
% Input:
%   L3: L3 structure  (with W sensitivity as 4th design filter curve)
%
% Output:
%   A: color transform matrix described below
%      This is generally set using:  
%           L3 = L3Set(L3, 'weight color transform', A)
%
%
% Let Cx, Cy, Cz be XYZ measurements of a spectra, S (expressed in quanta):
%   [Cx; Cy; Cz] = XYZ' * S
%
% Let Wxyz be basis that spans same subspace as XYZ.
% Let Cwx, Cwy, Cwz be measurements of spectra in Wxyz basis:
%   [Cwx; Cwy; Cwz] = Wxyz' * S
%   
% A is change of basis matrix that performs:
% [Cwx; Cwy; Cwz] = A * [Cx, Cy, Cz]
% [Cx; Cy; Cz] = inv(A) * [Cwx, Cwy, Cwz]
%
% Also Wxyz' = A * XYZ'
%   Because following is true for all S:
%        Wxyz' * S = [Cwx; Cwy; Cwz] = A * [Cx; Cy; Cz] = A * XYZ' * S
%
% (c) Stanford VISTA Team 2013

%% Check inputs
if ieNotDefined('L3'), error('Requires L3'); end

%% Read XYZ data and W sensitivity
XYZ = L3Get(L3, 'idealfiltertransmissivities');
X = XYZ(:, 1);
Z = XYZ(:, 3);

RGBW = L3Get(L3, 'designfiltertransmissivities');
W = RGBW(:, 4);

%% Compute new basis that depends on W

% Wy is projection of W onto XYZ so it is the visible part of W.
% Wx and Wz are components of X and Z that are orthogonal to Wy.
% All vectors are normalized to unit vectors.
%
% Wy is in special direction of visible part of W, which is similar to
% luminance.  Wx and Wz are orthogonal and similar to chrominance.

PontoXYZ = XYZ*(XYZ'*XYZ)^-1*XYZ';  % projection matrix

W2xyz = PontoXYZ * W; % project W onto subspace spanned by XYZ
Wy = W2xyz/norm(W2xyz); % normalization (so Wy'*Wy=1)

Wx = X - (Wy'*X)*Wy; % remove component in direction of W (so Wx'*Wy=0)
Wx = Wx/norm(Wx); % normalization (so Wx'*Wx=1)

Wz = Z - (Wy'*Z)*Wy; % remove component in direction of W (so Wz'*Wy=0)
Wz = Wz/norm(Wz); % normalization (so Wz'*Wz=1)

Wxyz = [Wx,Wy,Wz]; %new basis

%% Find Change of Basis Matrix, A
A = Wxyz'/XYZ';    % same as A = (XYZ\Wxyz)' = Wxyz' * pinv(XYZ');

return