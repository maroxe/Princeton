% SubToep_Phi.m
%

function Phi = SubToep_Phi(M, N)

h = 1/sqrt(M)*randn(N,1);

F = fft(eye(N));
H = 1/N*real(F'*(diag(fft(h))*F));
Phi = H(1:M,:);