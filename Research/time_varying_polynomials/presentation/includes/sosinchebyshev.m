function F = sosinchebyshev(sigma, p)
% p is the chebycheb basis
% sigma is the sos polynomial

n = length(sigma)-1;
k = n/2;
t = chebyshevTpoints(n+1);

subs_p_t = eval(subs(p, t));
eval_p = @(u) subs_p_t(:, 1:size(u)) * u;

%% A^(l) . X = sigma(t_l)
AX = sdpvar(1, 2*k+1);
X = sdpvar(k+1, k+1);
for l=1:length(AX)
    ptl = subs_p_t(l, 1:k+1)';
    AX(l) = ptl' * X * ptl;
end

f = eval_p(sigma)';
F =  [AX == f; X >= 0; f >= 0];

return

