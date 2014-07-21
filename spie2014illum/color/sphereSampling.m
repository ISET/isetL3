function dX = sphereSampling(R,n)

u = rand(n,1);
r = R*(u.^(1/3));

v = 2*rand(n,1)-1;
theta = acos(v);
sint = sin(theta);
cost = cos(theta);

phi = rand(n,1)*2*pi;
sinp = sin(phi);
cosp = cos(phi);

dX = zeros(n,3);
dX(:,1) = r.*sint.*cosp;
dX(:,2) = r.*sint.*sinp;
dX(:,3) = r.*cost;