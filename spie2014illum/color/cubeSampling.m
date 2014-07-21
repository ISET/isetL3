function dX = cubeSampling(L,n)

dX = zeros(n,3);

dX(:,1) = L*(rand(n,1)-1/2);
dX(:,2) = L*(rand(n,1)-1/2);
dX(:,3) = L*(rand(n,1)-1/2);
