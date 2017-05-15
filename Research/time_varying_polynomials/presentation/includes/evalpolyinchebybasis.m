function [y, ts]=evalpolyinchebybasis(p1)
n = length(p1)-1;
syms x;
p = chebyshevT(0:n, x);
ts = chebyshevTpoints(n);
p_evaluated = eval(subs(p, ts));
y = p_evaluated * p1;
return
