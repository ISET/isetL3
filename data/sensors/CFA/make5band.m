%% This script makes a sensor to simulate Olympus' prototype 5 band sensor.

%% Load Spectra

wavelength = 400:10:700;

% Data is from 'sensitivity 5 band.xlsx'
r =[37	27	19	15	12	10	10	14	22	31	41	54	73	91	97	97	100	109	224	373	467	438	431	455	402	287	106	29	14	8	5];
g =[15	14	16	18	26	33	47	98	180	250	306	358	413	451	467	447	424	384	352	301	229	156	102	82	66	45	17	5	3	2	2];
b =[146	185	219	245	281	302	326	319	322	280	228	185	145	124	121	116	105	98	97	90	79	59	44	43	41	30	12	4	2	2	1];
o =[6	5	4	4	5	5	8	17	33	49	79	140	206	269	336	407	443	433	411	375	278	190	121	95	77	50	20	7	4	3	3];
c =[13	11	11	10	16	21	30	87	226	339	382	408	408	419	390	355	290	237	189	137	98	67	49	44	41	29	13	4	3	2	1];



% Above data is for light expressed in energy.  ISET needs sensor to work
% for light expressed in quanta.  Following does the conversion.
r = quanta2energy(wavelength,r)';
g = quanta2energy(wavelength,g)';
b = quanta2energy(wavelength,b)';
o = quanta2energy(wavelength,o)';
c = quanta2energy(wavelength,c)';

data = [r, g, b, o, c];
filterNames = {'r', 'g', 'b', 'y', 'c'};

% Scale down maximum to have a more realistic quantum efficiency.  
% A peak of .4 is arbitrarly chosen.
data = data*.4/max(data(:));

%% Show spectra
figure
hold on
plot(wavelength,r,'r');
plot(wavelength,g,'g')
plot(wavelength,b,'b')
plot(wavelength,o,'y')
plot(wavelength,c,'c')

%% Bayer
name = '5band';
comment = 'Arrangement:  Yusuke Monno ; Masayuki Tanaka and Masatoshi Okutomi, Multispectral demosaicking using guided filter", Proc. SPIE 8299, Digital Photography VIII, 82990O (January 24, 2012); doi:10.1117/12.906168; http://dx.doi.org/10.1117/12.906168.';
filterOrder = [1, 2, 4, 2;   2, 5, 2, 3;  4, 2, 1, 2;  2, 3, 2, 5];
showCFA(filterNames,filterOrder);   title(name)
save(name,'comment','data','filterNames','filterOrder','wavelength')
