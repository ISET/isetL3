function f_LABsampling(n)

load LABfeasible.mat LABfeasible

I = all(mod(LABfeasible,n)==0,2);

LABfeasible = LABfeasible(logical(I),:);

save(['LABfeasible',num2str(n)],'LABfeasible');

clear LABfeasible

load LABfeasible.mat Reffeasible

Reffeasible = Reffeasible(logical(I),:);

save(['LABfeasible',num2str(n)],'Reffeasible','-append');

end