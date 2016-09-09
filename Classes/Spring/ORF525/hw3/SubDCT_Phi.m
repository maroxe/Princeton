% SubDCT_Phi.m
%

function Phi = SubDCT_Phi(M, N)

F = dct(eye(N));
Q = randperm(N);
Phi = sqrt(N/M)*F(sort(Q(1:M)),:);



