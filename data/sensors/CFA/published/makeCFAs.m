%% Load Spectra
wavelength = 400:10:700;

NikonD100 = ieReadColorFilter(wavelength,'NikonD100');
RGBW = ieReadColorFilter(wavelength,'RGBW_Manu');
CMY = ieReadColorFilter(wavelength,'KodakDCS620x-CMY');
RGBN = ieReadColorFilter(wavelength, 'RGBN');


% Scale down maximums to have a more realistic quantum efficiency.  These
% values are rather arbitrary.
NikonD100 = NikonD100 *.4; 
RGBW = RGBW*.6;

r = NikonD100(:,1);
g = NikonD100(:,2);
b = NikonD100(:,3);
w = RGBW(:,4);
c = CMY(:,1);
m = CMY(:,2);
y = CMY(:,3);
n = RGBN(:,4);

%% Show spectra
figure
hold on
plot(wavelength,r,'r');
plot(wavelength,g,'g')
plot(wavelength,b,'b')
plot(wavelength,w,'k')
plot(wavelength,c,'c')
plot(wavelength,m,'m')
plot(wavelength,y,'y')
plot(wavelength,n,'k')

%% Bayer
name = 'Bayer';
comment = 'Arrangement:  B. E. Bayer, �Color imaging array,� July 20, 1976, United States patent number 3971065.';
data = [r, g, b];
filterNames = {'r', 'g', 'b'};
filterOrder = [1, 2; 2, 3];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGB1
name = 'RGB1';
comment = 'Arrangement:  S. Yamanaka, �Solid state color camera,� US Patent 4 054 906, 1977.';
data = [r, g, b];
filterNames = {'r', 'g', 'b'};
filterOrder = [2, 1, 2, 3; 2, 3, 2, 1];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGB2
name = 'RGB2';
comment = 'Arrangement:  R. Lukac and K. N. Plataniotis, �Color filter arrays: Design and performance analysis,� IEEE Trans. Consum. Electron., vol. 51, no. 4, pp. 1260�1267, Nov. 2005.';
data = [r, g, b];
filterNames = {'r', 'g', 'b'};
filterOrder = [2, 1; 2, 3; 1, 2; 3, 2];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGB3
name = 'RGB3';
comment = 'Arrangement:  K. Hirakawa and P. J.Wolfe, �Spatio-spectral color filter array design for optimal image recovery,� Image Processing, IEEE Transactions on, vol. 17, no. 10, pp. 1876�1890, 2008.';
data = [r, g, b];
filterNames = {'r', 'g', 'b'};
filterOrder = [2, 1, 3];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGB4
name = 'RGB4';
comment = 'Arrangement:  K. Hirakawa and P. J.Wolfe, �Spatio-spectral color filter array design for optimal image recovery,� Image Processing, IEEE Transactions on, vol. 17, no. 10, pp. 1876�1890, 2008.';
data = [r, g, b];
filterNames = {'r', 'g', 'b'};
filterOrder = [1, 2, 3;...
               3, 1, 2;...
               2, 3, 1];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGB5
name = 'RGB5';
comment = 'Arrangement:  R. Lukac and K. N. Plataniotis, �Color filter arrays: Design and performance analysis,� IEEE Trans. Consum. Electron., vol. 51, no. 4, pp. 1260�1267, Nov. 2005.';
data = [r, g, b];
filterNames = {'r', 'g', 'b'};
filterOrder = [1, 2, 3, 2;...
               2, 1, 2, 3;...
               3, 2, 1, 2;...
               2, 3, 2, 1];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGB6
name = 'RGB6';
comment = 'Arrangement:  http://fujifilm-x.com/x-pro1/en/story/chapter1/index.html.';
data = [r, g, b];
filterNames = {'r', 'g', 'b'};
filterOrder = [2, 3, 2, 2, 1, 2; ...
               1, 2, 1, 3, 2, 3; ...
               2, 3, 2, 2, 1, 2; ...
               2, 1, 2, 2, 3, 2; ...
               3, 2, 3, 1, 2, 1; ...
               2, 1, 2, 2, 3, 2];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% CMY1
name = 'CMY1';
comment = 'Arrangement:  K. Hirakawa and P. J.Wolfe, �Spatio-spectral color filter array design for optimal image recovery,� Image Processing, IEEE Transactions on, vol. 17, no. 10, pp. 1876�1890, 2008.';
data = [c, m, y];
filterNames = {'c', 'm', 'y'};
filterOrder = [1, 2; 2, 3];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% CMY2
name = 'CMY2';
comment = 'Arrangement:  Behzad Sajadi, Aditi Majumder, Kazuhiro Hiwada, Atsuto Maki, and Ramesh Raskar. 2011  Switchable primaries using shiftable layers of color filter arrays. In ACM SIGGRAPH 2011.';
data = [c, m, y];
filterNames = {'c', 'm', 'y'};
filterOrder = [1, 2, 3; 2, 3, 1];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% CMY3
name = 'CMY3';
comment = ['Arrangement:  I. Sato, K. Ooi, K. Saito, Y. Takemura, and T. Shinohara, �Color image pick-up apparatus,� June 28, 1983, United States patent 4390895.   ',...
    'J.F. Hamilton, J.E. Adams, and D.M. Orlicki. Particular pattern of pixels for a color filter array which is used to derive luminanance and chrominance values. U.S. Patent 6 330 029 B1, Dec. 2001..   ',...
    'Y. Li, P. Hao, and Z. Lin, �Color filter arrays: A design methodology,� Department of Computer Science, Queen Mary, University of London, Mile End Road, London E1 4NS, UK, Tech. Rep., May 2008.'];
data = [g, c, m, y];
filterNames = {'g', 'c', 'm', 'y'};
filterOrder = [3, 4; 2, 1];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% CMY4
name = 'CMY4';
comment = 'Arrangement:  Sony Corporation, �Realization of natural color reproduction in digital still cameras, closer to the natural sight perception of the human eye,� http://www.sony.net/SonyInfo/News/Press Archive/200307/03-029E/, 2003, press release.';
data = [r, g, b, c];
filterNames = {'r', 'g', 'b', 'c'};
filterOrder = [1, 4; 2, 3];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% CMY5
name = 'CMY5';
comment = 'Arrangement:  Y. Li, P. Hao, and Z. Lin, �Color filter arrays: A design methodology,� Department of Computer Science, Queen Mary, University of London, Mile End Road, London E1 4NS, UK, Tech. Rep., May 2008.';
data = [r, c, m, y];
filterNames = {'r', 'c', 'm', 'y'};
filterOrder = [1, 2; 4, 3];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% CMY6
name = 'CMY6';
comment = 'Arrangement:  Y. Li, P. Hao, and Z. Lin, �Color filter arrays: A design methodology,� Department of Computer Science, Queen Mary, University of London, Mile End Road, London E1 4NS, UK, Tech. Rep., May 2008.';
data = [b, c, m, y];
filterNames = {'b', 'c', 'm', 'y'};
filterOrder = [1, 4; 3, 2];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% CMY7
name = 'CMY7';
comment = 'Arrangement:  Y. Li, P. Hao, and Z. Lin, �Color filter arrays: A design methodology,� Department of Computer Science, Queen Mary, University of London, Mile End Road, London E1 4NS, UK, Tech. Rep., May 2008.';
data = [r, g, c, m, y];
filterNames = {'r', 'g', 'c', 'm', 'y'};
filterOrder = [1, 3, 5, 3;...
               3, 5, 4, 5;...
               5, 4, 2, 4;...
               3, 5, 4, 5];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% CMY8
name = 'CMY8';
comment = 'Arrangement:  Y. Li, P. Hao, and Z. Lin, �Color filter arrays: A design methodology,� Department of Computer Science, Queen Mary, University of London, Mile End Road, London E1 4NS, UK, Tech. Rep., May 2008.';
data = [g, c, m, y];
filterNames = {'g', 'c', 'm', 'y'};
filterOrder = [3, 1;...
               2, 4;...
               4, 2;...
               1, 3;...
               4, 2;...
               2, 4];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGBW1
name = 'RGBW1';
comment = ['Arrangement:  M. Parmar and B. A. Wandell, �Interleaved imaging: an imaging system design inspired by rod-cone vision,� in Digital Photography V, B. G. Rodricks and S. E. Susstrunk, Eds., vol. 7250. SPIE, January 18, 2009, p. 725008.  '...
           'E. B. Gindele and A. C. Gallagher, �Sparsely sampled image sensing device with color and luminance photosites,� Nov 5, 2002, United States patent 6476865.'];
data = [r, g, b, w];
filterNames = {'r', 'g', 'b', 'w'};
filterOrder = [1, 2;...               
               4, 3];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGBW2
name = 'RGBW2';
comment = ['Arrangement:  T. Kijima, H. Nakamura, J. Compton, and J. Hamilton, �Image sensor with improved light sensitivity,� US Patent 20 070 177 236, August 2007.  ',...
           'M. Kumar, E. O. Morales, J. E. Adams, and W. Hao, �New digital camera sensor architecture for low light imaging,� in Image Processing (ICIP), 2009 16th IEEE International Conference on, 2009, pp. 2681�2684.  ',...
           'http://spectronet.de/portals/visqua/story_docs/vortraege_2009/091103_vision/091105_0930_deluca_kodak.pdf or  http://vimeo.com/7727439'];
data = [r, g, b, w];
filterNames = {'r', 'g', 'b', 'w'};
filterOrder = [4, 3, 4, 2;...
               3, 4, 2, 4;...
               4, 2, 4, 1;...
               2, 4, 1, 4];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGBW3
name = 'RGBW3';
comment = 'Arrangement:  T. Yamagami, T. Sasaki, and A. Suga, �Image signal processing apparatus having a color filter with offset luminance filter elements,� June 21, 1994, United States patent 5323233.';
data = [r, g, b, w];
filterNames = {'r', 'g', 'b', 'w'};
filterOrder = [4, 2, 4, 2;...
               1, 4, 3, 4;...
               4, 2, 4, 2;...
               3, 4, 1, 4];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGBW4
name = 'RGBW4';
comment = 'Arrangement:  T. Yamagami, T. Sasaki, and A. Suga, �Image signal processing apparatus having a color filter with offset luminance filter elements,� June 21, 1994, United States patent 5323233.';
data = [r, g, b, w];
filterNames = {'r', 'g', 'b', 'w'};
filterOrder = [4, 2, 4, 1, 4, 3;...
               1, 4, 3, 4, 2, 4];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGBW5
name = 'RGBW5';
comment = 'Arrangement:  G. Susanu, S. Petrescu, F. Nanu, A. Capata, and P. Corcoran, �RGBW sensor array,� July 2, 2009, United States patent 2009/0167893.';
data = [r, g, b, w];
filterNames = {'r', 'g', 'b', 'w'};
filterOrder = [1, 4, 3, 4, 2, 4;...
               4, 3, 4, 2, 4, 1;...
               3, 4, 2, 4, 1, 4;...
               4, 2, 4, 1, 4, 3;...
               2, 4, 1, 4, 3, 4;...
               4, 1, 4, 3, 4, 2];               
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGBW6
name = 'RGBW6';
comment = ['Arrangement:  T. Kijima, H. Nakamura, J. Compton, and J. Hamilton, �Image sensor with improved light sensitivity,� US Patent 20 070 177 236, August 2007.  ',...
           'http://spectronet.de/portals/visqua/story_docs/vortraege_2009/091103_vision/091105_0930_deluca_kodak.pdf or  http://vimeo.com/7727439'];
data = [r, g, b, w];
filterNames = {'r', 'g', 'b', 'w'};
filterOrder = [2, 4, 1, 4;...
               2, 4, 1, 4;...
               3, 4, 2, 4;...
               3, 4, 2, 4];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGBW7
name = 'RGBW7';
comment = ['Arrangement:  T. Kijima, H. Nakamura, J. Compton, and J. Hamilton, �Image sensor with improved light sensitivity,� US Patent 20 070 177 236, August 2007.  ',...
           'http://spectronet.de/portals/visqua/story_docs/vortraege_2009/091103_vision/091105_0930_deluca_kodak.pdf or  http://vimeo.com/7727439'];
data = [r, g, b, w];
filterNames = {'r', 'g', 'b', 'w'};
filterOrder = [2, 4, 1, 4;...
               3, 4, 2, 4;...               
               2, 4, 1, 4;...
               3, 4, 2, 4];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGBW8
name = 'RGBW8';
comment = 'Arrangement: Wang, J., Zhang, C., & Hao, P. (2011, September). New color filter arrays of high light sensitivity and high demosaicking performance. In Image Processing (ICIP), 2011 18th IEEE International Conference on (pp. 3153-3156). IEEE.';
data = [r, g, b, w];
filterNames = {'r', 'g', 'b', 'w'};
filterOrder = [4, 1, 3, 4, 2;...
               4, 2, 4, 1, 3;...
               1, 3, 4, 2, 4;...
               2, 4, 1, 3, 4;...
               3, 4, 2, 4, 1];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGBW9
name = 'RGBW9';
comment = ['Arrangement: Sony RGBW CFA.   '...
           'http://imagealgorithmics.com/RGBW_CFAs_Tested.html.   '...
           'http://www.sony.net/SonyInfo/News/Press/201201/12-010E/'];
data = [r, g, b, w];
filterNames = {'r', 'g', 'b', 'w'};
filterOrder = [4, 3, 4, 2;...
               1, 4, 2, 4;...
               4, 2, 4, 3;...
               2, 4, 1, 4];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGBW10
name = 'RGBW10';
comment = ['Arrangement: Aptina’s Clarity+ Solution.   '...
           'http://www.aptina.com/Aptina_ClarityPlus_WhitePaper.pdf'];
data = [r, g, b, w];
filterNames = {'r', 'g', 'b', 'w'};
filterOrder = [1, 4;...               
               4, 3];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% multi1
name = 'multi1';
comment = ['Arrangement:  S. Lansel and B. Wandell, "Local Linear Learned Image Processing Pipeline," in Imaging Systems Applications, OSA Technical Digest (CD) (Optical Society of America, 2011), paper IMC3.   ',...
           'Behzad Sajadi, Aditi Majumder, Kazuhiro Hiwada, Atsuto Maki, and Ramesh Raskar. 2011  Switchable primaries using shiftable layers of color filter arrays. In ACM SIGGRAPH 2011.'];
data = [r, g, b, c, m, y];
filterNames = {'r', 'g', 'b', 'c', 'm', 'y'};
filterOrder = [1, 4;...
               3, 6;...               
               2, 5];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% HDRgray
name = 'HDRgray';
comment = 'Arrangement:  15.	S.K. Nayar and S.G. Narasimhan, European Conference on Computer Vision (ECCV), Vol.IV, pp.636-652, May, 2002.';
w1 = w*.25;
w2 = w*.5;
w3 = w*.75;
w4 = w;
data = [w1, w2, w3, w4];
filterNames = {'w', 'w', 'w', 'k'};
filterOrder = [4, 1;...
               3, 2];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% HDRcolor
name = 'HDRcolor';
comment = 'Bayer pattern modified with darker RGB in some pixels';
rdark = r*.25;
gdark = g*.25;
bdark = b*.25;
data = [r, g, b, rdark, gdark, bdark];
filterNames = {'r', 'g', 'b', 'k', 'k', 'k'};
filterOrder = [1, 2, 4, 5;...
               5, 6, 2, 3];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGBx
name = 'RGBx';
comment = 'Bayer pattern with one G removed';
k = zeros(size(r));
data = [r, g, b, k];
filterNames = {'r', 'g', 'b', 'k'};
filterOrder = [1, 2;...
               4, 3];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGBN
name = 'RGBN';
comment = 'Bayer pattern with one G replaced with narrow band';
data = [r, g, b, n];
filterNames = {'r', 'g', 'b', 'n'};
filterOrder = [1, 2;...
               4, 3];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')