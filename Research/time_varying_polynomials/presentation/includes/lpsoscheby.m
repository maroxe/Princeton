function polynomial_solution = lpsoscheby(A_const,b, c_coord, deg, ...
                                          dt, chebychev_basis)
k = floor(deg / 2);
n = 2*k;

syms x; assume(x, 'real');
t = chebyshevTpoints(n+1);
chebychev_basis_t = eval(subs(chebychev_basis, t));
eval_chebychev_basis = @(u) chebychev_basis_t(:, 1:size(u)) * u;


int_chebychev_basis = int(chebychev_basis);
int_chebychev_basis_0_1 = eval(subs(int_chebychev_basis, 1) - subs(int_chebychev_basis, -1));
int_chebychev_basis2d = int(chebychev_basis' * chebychev_basis);
int_chebychev_basis2d_0_1 = eval(subs(int_chebychev_basis2d, 1) - subs(int_chebychev_basis2d, -1));

polynomial_solution = sdpvar(n+1, 2);


% int <xt, ct> dt, t=-1..1
alpha = 0;
for i=1:2
    alpha = alpha + chebyshevTint(c_coord(:,i), polynomial_solution(:,i), int_chebychev_basis2d_0_1);
end

% constrains

% algebraic certificate
q = sdpvar(n-1, length(b));
r = sdpvar(n+1, length(b));

xt = eval_chebychev_basis(polynomial_solution);
qt = eval_chebychev_basis(q)';
rt = eval_chebychev_basis(r)';
F = [
    repmat(b, 1, n+1) - A_const * xt'... 
    == ...
    repmat(1-t'.^ 2, length(b), 1) .* qt + rt];

for i=1:length(b)
    F = F + [[sosinchebyshev(q(:, i), chebychev_basis)]: ...
             'sos'];
    F = F + [[sosinchebyshev(r(:, i), chebychev_basis)]:'sos'];
end

res = optimize(F, alpha);
polynomial_solution = value(polynomial_solution)';
return


