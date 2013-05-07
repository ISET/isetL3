%Reads reflectance data from txt files in current folder, interpolates, and saves

files=dir(pwd);
for filenum=3:length(files)
    file=files(filenum);   
    if strcmp(file.name(end-3:end),'.txt')
        text=fileread(file.name);
        breaks=strfind(text,'PM');
        startindex=breaks(1)+3;
        textdata=textscan(text(startindex:end),'%s');
        textdata=textdata{1};
        numlambdas=length(textdata)/2;
        wave=zeros(1,numlambdas);
        data=zeros(1,numlambdas);
        for n=1:numlambdas
            wave(n)=str2num(textdata{2*n-1}(1:end-1));
            data(n)=str2num(textdata{2*n});
        end
        [wave,goodindexes]=unique(wave);
        data=data(goodindexes);
        
        wavelength=round(wave(1)/10)*10:10:round(wave(end)/10)*10;
        data=interp1(wave,data,wavelength);

        comment='Extracted from figure at http://www.lonestardigital.com/DCS620x.htm and then interpolated.';
        save(file.name(1:end-4),'data','wavelength','comment')
    end
end