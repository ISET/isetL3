folder = pwd;
cd ~/Stanford/iset
isetPath(pwd)
cd ~/Stanford/L3
L3Path(pwd)
cd(folder);

clear all, clc, close all
s_initISET

lights = {'D65','Tungsten','Fluorescent'};
cfas = {'RGBW1','Bayer'};

load results

  for nl = 1:length(lights)
    for nc = 1:length(cfas)
      
      load(['../QTtraindata/data/L3camera_',cfas{nc},'_',lights{nl},'.mat'])
            
      M1 = results(nl,nc).tgtXYZ'/results(nl,nc).estXYZ';
      camera.vci.L3.globaltrMFG = results(nl,nc).tgtXYZ'/results(nl,nc).estXYZ';
      
      
    end
  end
      
