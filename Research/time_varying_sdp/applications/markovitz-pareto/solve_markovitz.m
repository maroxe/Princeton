function x = solve_markovitz(sig, p, vol_max)
n = length(p);
cvx_begin quiet
variable x(n)
maximize(p'*x)
quad_form(x,sig) <= vol_max;
ones(1,n)*x <= 1;
x >= 0;
cvx_end
end