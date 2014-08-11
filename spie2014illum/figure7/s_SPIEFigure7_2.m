
load results2/L3camera_RGBW_Tungsten_results

boundShare{1} = [ 40 -20 -50; 40 70 40];
boundShare{2} = [ 70 -20 -50; 70 70 40];

for i = 1:length(results)

  XYZ = results(i).XYZ;
  estXYZ = results(i).estXYZ;
  cielab = results(i).cielab;
  estCielab = results(i).estCielab;
  
  dE = zeros(size(XYZ,1),size(XYZ,3));
  
  for j = 1:size(XYZ,3)
    dE(:,j) = deltaEab(XYZ(:,:,j),estXYZ(:,:,j),XYZ(101,:,j));
  end
  
  dE = mean(dE,2);
  
  dE = XW2RGBFormat(dE,10,11);
  XYZ = XW2RGBFormat(XYZ(:,:,1),10,11);
  
  sRGB = xyz2srgb(XYZ);
  figure
  imagesc(sRGB(1:10,1:10,:));
  a = num2cell(boundShare{i}(1,2):10:boundShare{i}(2,2));
  b = num2cell(boundShare{i}(1,3):10:boundShare{i}(2,3));
  set(gca,'XTickLabel',a,'YTickLabel',b)
  for k = 1:10
    for l = 1:10
      if i == 2
        text(k-.2,l+.1,num2str(dE(k,l),'%.1f'),'FontWeight','b')
      else
        text(k-.2,l+.1,num2str(dE(k,l),'%.1f'),'FontWeight','b','Color','w')
      end
    end
  end
  
end
    