function polynomial_solution = lpsoscheby(b_coord, deg, number_nodes, dt)
k = floor(deg / 2);
n = 2*k;


% chebychev basis
syms x;
chebychev_basis = chebyshevT(0:n, x) * sqrt(2 / (2*k+1));
chebychev_basis(1) = chebychev_basis(1) / sqrt(2);


t = chebyshevTpoints(n+1);
chebychev_basis_t = eval(subs(chebychev_basis, t));
eval_chebychev_basis = @(u) chebychev_basis_t(:, 1:size(u)) * u;


int_chebychev_basis = int(chebychev_basis);
int_chebychev_basis_0_1 = eval(subs(int_chebychev_basis, 1) - subs(int_chebychev_basis, -1));
int_chebychev_basis2d = int(chebychev_basis' * chebychev_basis);
int_chebychev_basis2d_0_1 = eval(subs(int_chebychev_basis2d, 1) - subs(int_chebychev_basis2d, -1));

polynomial_solution = sdpvar(n+1, number_nodes^2);

xt = eval_chebychev_basis(polynomial_solution);
xt_matrix = reshape(xt, [n+1, number_nodes, number_nodes])
bt = eval_chebychev_basis(b_coord);

% int <xt, ct> dt, t=-1..1
alpha = 0;
for i=1:number_nodes
    alpha = alpha +  int_chebychev_basis_0_1 * xt_matrix(:, 1, i);
end

% constrains

% equality constraints
F = [];

% flow conservation
for i=2:(number_nodes-1)
    F = F + [
            [ sum(squeeze(xt_matrix(:, i, :)) - squeeze(xt_matrix(:, :, i))) == 0]
            
    ];
end

% algebraic certificate
number_constraints = 2*number_nodes*number_nodes;
q = sdpvar(n-1, number_constraints);
r = sdpvar(n+1, number_constraints);


qt = eval_chebychev_basis(q)';
rt = eval_chebychev_basis(r)';
F = F + [
    [bt' - xt'; xt']... 
    == ...
    repmat(1-t'.^ 2, number_constraints, 1) .* qt + rt];

for i=1:number_constraints
    F = F + [[sosinchebyshev(q(:, i), chebychev_basis)]: 'sos-capacity'];
    F = F + [[sosinchebyshev(r(:, i), chebychev_basis)]:'sos-capacity'];
end

res = optimize(F, -alpha)
alpha
polynomial_solution = value(polynomial_solution)';
return


