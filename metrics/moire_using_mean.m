function [data_abIdeal_mean, data_abL3_mean, cpd_mean] = moire_using_mean(abIdeal, abL3, line)

half_size=3;
[R C]=size(abIdeal); 

switch lower(line)
case 'diagonalline'
   %% Collect data for diagonal line
    min_size=min(R, C);
    data_abIdeal_mean=zeros(1, min_size);   
    data_abL3_mean=zeros(1, min_size);  
    x=linspace(1, min_size, min_size);
    
    for i=1+half_size : min_size-half_size
        temp=abIdeal(i-half_size:i+half_size,i-half_size:i+half_size);
        data_abIdeal_mean(1,i)=mean(temp(:));
        clear temp;
        
        temp=abL3(i-half_size:i+half_size,i-half_size:i+half_size);
        data_abL3_mean(1,i)=mean(temp(:));
        clear temp;
    end
    Length=min_size;
case 'horizontalline'
   %% Collect data for horizontal line
   min_size=C;
    center_R=ceil(R/2);
    x=linspace(1, C, C);
    data_abIdeal_mean=zeros(1, C);   
    data_abL3_mean=zeros(1, C);
    
    for i=center_R : center_R
        for j=1+half_size : C-half_size
            temp=abIdeal(i-half_size:i+half_size,j-half_size:j+half_size);
            data_abIdeal_mean(1,j)=mean(temp(:));
            clear temp;
            
            temp=abL3(i-half_size:i+half_size,j-half_size:j+half_size);
            data_abL3_mean(1,j)=mean(temp(:));
            clear temp;
        end
    end
    Length=C;
otherwise
    error('moire_experiment: Unrecognized line');
end

% find a maximum ab value
max_abmean=181;
th=25;
temp_=0;
cpd_mean=0;
for j=1: Length
    if ( (data_abL3_mean(1,j)>th) && temp_==0)
        cpd_mean=j;
        temp_=temp_+1;
    end
end

%% Draw result
figure
plot(x, data_abIdeal_mean, 'LineWidth',2.5);
hold on;
plot(x, data_abL3_mean, 'r', 'LineWidth',2.5);
axis([0, Length, 0, 181])
xlabel('distance from origin'); ylabel('Block mean of square root of ab');
title('Block mean of square root of ab')
legend('Ideal', 'L3')

