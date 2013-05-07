function im = L3imcrop(L3,im)
% Crop the image according to the L3 border width
%
%   im = L3imcrop(L3,im)
%
% The border width is XXX
%
%
% (c) Stanford VISTA Team, 2012

%% Should check stuff

borderWidth = L3Get(L3,'border width');

im = im(borderWidth:end-borderWidth,  borderWidth:end-borderWidth, :);


end

