function A = L3findRGBWcolortransform()
% Find transform from XYZ to opponent color space that depends on D65
% illuminant.
%
%  A = L3findRGBWcolortransform()
%
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

%% Read in data
wavelength = 400 : 10 : 680; 
XYZ = vcReadSpectra('XYZQuanta', wavelength); % read XYZ data 
X = XYZ(:, 1);
Z = XYZ(:, 3);

W = vcReadSpectra('D65', wavelength); % read D65 illuminant data
W = Energy2Quanta(W, wavelength'); % from energy to quanta

%% Compute new basis that depends on D65 illuminant

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