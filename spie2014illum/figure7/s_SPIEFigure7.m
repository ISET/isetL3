close all

load ../color/results/L3camera_RGBW_Tungsten_results.mat

c = [];
for nr = 1:length(results)
  
  k = [ strfind(results(nr).name,'_'), strfind(results(nr).name,'.') ];

  L = str2double( results(nr).name(k(1)+2:k(2)-1));
  a = str2double( results(nr).name(k(2)+2:k(3)-1));
  b = str2double( results(nr).name(k(3)+2:k(4)-1));
  
  if L ~= 40
    continue
  end
  
  c = [c;[L a b]];
end
plot(c(:,2),c(:,3),'+')
% return

c=zeros(8,10,3);
resultsTab = zeros(7,10);
for nr = 1:length(results)
  
  k = [ strfind(results(nr).name,'_'), strfind(results(nr).name,'.') ];

  L = str2double( results(nr).name(k(1)+2:k(2)-1));
  a = str2double( results(nr).name(k(2)+2:k(3)-1));
  b = str2double( results(nr).name(k(3)+2:k(4)-1));
  
  if L ~= 70 || a < -30 || a > 30 || b < -20 || b > 70 
    continue
  end
  
  c(a/10+4,b/10+3,:) = [70,a,b];
  
  XYZ = results(nr).XYZ;
  estXYZ = results(nr).estXYZ;
  
%   fprintf('%.0f,%.0f,%.0f\n',XYZ(101,1),XYZ(101,2),XYZ(101,3))
  dE = deltaEab(XYZ(1:100,:),estXYZ(1:100,:),XYZ(101,:));
%   hist(dE,30);
%   xlabel('\Delta E')
%   ylabel('Count');
%   v = sprintf('%.1f',mean(dE(:)));
%   title(['Mean \Delta E ',v])
%   pause(1)
  resultsTab(a/10+4,b/10+3) = mean(dE(:));
end

at = [min(min(c(:,:,2))) max(max(c(:,:,2)))];
bt = [min(min(c(:,:,3))) max(max(c(:,:,3)))];
at = at(1):10:at(2);
bt = bt(1):10:bt(2);
at = mat2cell(at,ones(size(at,1),1),ones(size(at,2),1));
bt = mat2cell(bt,ones(size(bt,1),1),ones(size(bt,2),1));
at = cellfun(@num2str,at,'UniformOutput',0);
bt = cellfun(@num2str,bt,'UniformOutput',0);

XYZcharts = lab2xyz( c, XYZ(101,:) );
for i = 1:size(XYZcharts,2)
  XYZcharts(end,i,:) = XYZ(101,:);
end
RGBcharts = xyz2srgb(XYZcharts);
figure
imagesc(RGBcharts(1:end-1,:,:)); axis image
set(gca,'XTickLabel',bt,'YTickLabel',at)
xlabel('b'),ylabel('a')

for i = 1:size(resultsTab,1)
for j = 1:size(resultsTab,2)
  text(j-.2,i+.1,sprintf('%.1f',resultsTab(i,j)),'FontWeight','b')
end
end
export_fig -png -transparent RefChartRGBWTun70.png

close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load ../color/results/L3camera_RGBW_Fluorescent7_results.mat
c=zeros(8,10,3);
resultsTab = zeros(7,10);
for nr = 1:length(results)
  
  k = [ strfind(results(nr).name,'_'), strfind(results(nr).name,'.') ];

  L = str2double( results(nr).name(k(1)+2:k(2)-1));
  a = str2double( results(nr).name(k(2)+2:k(3)-1));
  b = str2double( results(nr).name(k(3)+2:k(4)-1));
  
  if L ~= 70 || a < -30 || a > 30 || b < -20 || b > 70 
    continue
  end
  
  c(a/10+4,b/10+3,:) = [70,a,b];
  
  XYZ = results(nr).XYZ;
  estXYZ = results(nr).estXYZ;
  
%   fprintf('%.0f,%.0f,%.0f\n',XYZ(101,1),XYZ(101,2),XYZ(101,3))
  dE = deltaEab(XYZ(1:100,:),estXYZ(1:100,:),XYZ(101,:));
%   hist(dE,30);
%   xlabel('\Delta E')
%   ylabel('Count');
%   v = sprintf('%.1f',mean(dE(:)));
%   title(['Mean \Delta E ',v])
%   pause(1)
  resultsTab(a/10+4,b/10+3) = mean(dE(:));
end

at = [min(min(c(:,:,2))) max(max(c(:,:,2)))];
bt = [min(min(c(:,:,3))) max(max(c(:,:,3)))];
at = at(1):10:at(2);
bt = bt(1):10:bt(2);
at = mat2cell(at,ones(size(at,1),1),ones(size(at,2),1));
bt = mat2cell(bt,ones(size(bt,1),1),ones(size(bt,2),1));
at = cellfun(@num2str,at,'UniformOutput',0);
bt = cellfun(@num2str,bt,'UniformOutput',0);

XYZcharts = lab2xyz( c, XYZ(101,:) );
for i = 1:size(XYZcharts,2)
  XYZcharts(end,i,:) = XYZ(101,:);
end
RGBcharts = xyz2srgb(XYZcharts);
figure
imagesc(RGBcharts(1:end-1,:,:)); axis image
set(gca,'XTickLabel',bt,'YTickLabel',at)
xlabel('b'),ylabel('a')

for i = 1:size(resultsTab,1)
for j = 1:size(resultsTab,2)
  text(j-.2,i+.1,sprintf('%.1f',resultsTab(i,j)),'FontWeight','b')
end
end
export_fig -png -transparent RefChartRGBWF770.png
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load ../color/results/L3camera_RGBW_Tungsten_results.mat

c=zeros(8,9,3);
resultsTab = zeros(7,9);
for nr = 1:length(results)
  
  k = [ strfind(results(nr).name,'_'), strfind(results(nr).name,'.') ];

  L = str2double( results(nr).name(k(1)+2:k(2)-1));
  a = str2double( results(nr).name(k(2)+2:k(3)-1));
  b = str2double( results(nr).name(k(3)+2:k(4)-1));
  
  if L ~= 40 || a < 0 || a > 60 || b < -40 || b > 40 
    continue
  end
  
  c(a/10+1,b/10+5,:) = [40,a,b];
  
  XYZ = results(nr).XYZ;
  estXYZ = results(nr).estXYZ;
  
%   fprintf('%.0f,%.0f,%.0f\n',XYZ(101,1),XYZ(101,2),XYZ(101,3))
  dE = deltaEab(XYZ(1:100,:),estXYZ(1:100,:),XYZ(101,:));
%   hist(dE,30);
%   xlabel('\Delta E')
%   ylabel('Count');
%   v = sprintf('%.1f',mean(dE(:)));
%   title(['Mean \Delta E ',v])
%   pause(1)
  resultsTab(a/10+1,b/10+5) = mean(dE(:));
end

at = [min(min(c(:,:,2))) max(max(c(:,:,2)))];
bt = [min(min(c(:,:,3))) max(max(c(:,:,3)))];
at = at(1):10:at(2);
bt = bt(1):10:bt(2);
at = mat2cell(at,ones(size(at,1),1),ones(size(at,2),1));
bt = mat2cell(bt,ones(size(bt,1),1),ones(size(bt,2),1));
at = cellfun(@num2str,at,'UniformOutput',0);
bt = cellfun(@num2str,bt,'UniformOutput',0);

XYZcharts = lab2xyz( c, XYZ(101,:) );
for i = 1:size(XYZcharts,2)
  XYZcharts(end,i,:) = XYZ(101,:);
end
RGBcharts = xyz2srgb(XYZcharts);
figure
imagesc(RGBcharts(1:end-1,:,:)); axis image
set(gca,'XTickLabel',bt,'YTickLabel',at)
xlabel('b'),ylabel('a')

for i = 1:size(resultsTab,1)
for j = 1:size(resultsTab,2)
  text(j-.2,i+.1,sprintf('%.1f',resultsTab(i,j)),'FontWeight','b',...
    'Color','w')
end
end

export_fig -png -transparent RefChartRGBWTun40.png

close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load ../color/results/L3camera_RGBW_Fluorescent7_results.mat
c=zeros(8,9,3);
resultsTab = zeros(7,9);
for nr = 1:length(results)
  
  k = [ strfind(results(nr).name,'_'), strfind(results(nr).name,'.') ];

  L = str2double( results(nr).name(k(1)+2:k(2)-1));
  a = str2double( results(nr).name(k(2)+2:k(3)-1));
  b = str2double( results(nr).name(k(3)+2:k(4)-1));
  
  if L ~= 40 || a < 0 || a > 60 || b < -40 || b > 40 
    continue
  end
  
  c(a/10+1,b/10+5,:) = [40,a,b];
  
  XYZ = results(nr).XYZ;
  estXYZ = results(nr).estXYZ;
  
%   fprintf('%.0f,%.0f,%.0f\n',XYZ(101,1),XYZ(101,2),XYZ(101,3))
  dE = deltaEab(XYZ(1:100,:),estXYZ(1:100,:),XYZ(101,:));
%   hist(dE,30);
%   xlabel('\Delta E')
%   ylabel('Count');
%   v = sprintf('%.1f',mean(dE(:)));
%   title(['Mean \Delta E ',v])
%   pause(1)
  resultsTab(a/10+1,b/10+5) = mean(dE(:));
end

at = [min(min(c(:,:,2))) max(max(c(:,:,2)))];
bt = [min(min(c(:,:,3))) max(max(c(:,:,3)))];
at = at(1):10:at(2);
bt = bt(1):10:bt(2);
at = mat2cell(at,ones(size(at,1),1),ones(size(at,2),1));
bt = mat2cell(bt,ones(size(bt,1),1),ones(size(bt,2),1));
at = cellfun(@num2str,at,'UniformOutput',0);
bt = cellfun(@num2str,bt,'UniformOutput',0);

XYZcharts = lab2xyz( c, XYZ(101,:) );
for i = 1:size(XYZcharts,2)
  XYZcharts(end,i,:) = XYZ(101,:);
end
RGBcharts = xyz2srgb(XYZcharts);
figure
imagesc(RGBcharts(1:end-1,:,:)); axis image
set(gca,'XTickLabel',bt,'YTickLabel',at)
xlabel('b'),ylabel('a')

for i = 1:size(resultsTab,1)
for j = 1:size(resultsTab,2)
  text(j-.2,i+.1,sprintf('%.1f',resultsTab(i,j)),'FontWeight','b',...
    'Color','w')
end
end

export_fig -png -transparent RefChartRGBWF740.png
close all
