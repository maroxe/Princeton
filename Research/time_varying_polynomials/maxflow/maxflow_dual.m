%%%%%%%%%%%%%%%%
clear;

%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('../yalmip'))
sdpsettings('solver','mosek')
addpath(genpath('~/mosek/mosek'))

deg = 7;
k = (deg-1) / 2;

%%%%%%%
graph = [
   %0 1 2 3 4 5 6 7 8
   %S B C D F G H I T
0; 5; 4; 4; 7; 0; 0; 0; 0;
0; 0; 0; 0; 4; 0; 0; 0; 2;
0; 0; 0; 0; 5; 6; 0; 0; 0;
0; 0; 0; 0; 0; 4; 1; 0; 0;
0; 0; 0; 0; 0; 0; 0; 3; 2;%; F
0; 0; 0; 0; 0; 0; 2; 3; 4;%; G
0; 0; 0; 0; 0; 0; 0; 0; 8;%; H
0; 0; 0; 0; 0; 0; 0; 0; 7;%; I
0; 0; 0; 0; 0; 0; 0; 0; 0;% T
    ];
number_nodes = round(sqrt(size(graph, 1)));


% chebychev basis
syms sym_x;
chebychev_basis = chebyshevT(0:(k-1), sym_x) * sqrt(2 / (2*k-1));
chebychev_basis(1) = chebychev_basis(1) / sqrt(2);
t = chebyshevTpoints(deg+1);
chebychev_basis_t = eval(subs(chebychev_basis, t));
eval_chebychev_basis = @(u) chebychev_basis_t(:, 1:size(u)) * u;

[w, lagrange_basis] = lagrange(sym_x, t);

% generate polynomials
M = 1000;
list_polynomials = zeros(M, deg+1);
for counter=1:1000
    [y, min_p] =random_positive_polynomials(t); 
    list_polynomials(counter, :) = y+2;
end


cap = 10.*(t+1/2).*(t-.2).*(t+.3).*(t.^2-0.9)+5;
cap2 = 3-t.^2;
cap3 = 3-t.^2+t;
list_polynomials(1, :) = cap2;
list_polynomials(2, :) = cap3;
cap0 = 0 * cap;


%capacities = repmat(graph, [1 deg+1])' .* repmat(cap, [1 (number_nodes^2)]);
capacities = repmat(graph, [1 deg+1])' .* list_polynomials(randi(2, 1, number_nodes^2), :)';


b = reshape(capacities, [(deg+1), number_nodes, number_nodes ...
                   ]);
b = permute(b, [3 2 1]);
%b_ijl = b_coord(i, j, l)

% A(i, j, l) = (A_{ij}^(l))
A = zeros(k, k, deg+1);
for l=1:(deg+1)
    p_tl = chebychev_basis_t(l, :)';
    A(:, :, l) = p_tl * p_tl';
end

[dim_i, dim_j, dim_l] = size(b)


%%%%%%%%%%%%%

cvx_clear;
%cvx_precision high
cvx_begin
variables z(dim_i, dim_j, dim_l);
variables x(dim_i, dim_j, dim_l);
variables c(dim_i, dim_l);

dual variables f{dim_i, dim_j, dim_l};
% objective
obj = -sum(sum(dot(b, z, 1)));

minimize(obj);
obj >= -10;
% linear constraints
for i=1:dim_i
    for j=1:dim_j
        for l=1:dim_l
            i_diff_st = (i ~= 1)*(i ~= dim_i);
            j_diff_st = (j ~= 1)*(j ~= dim_j);
            i_is_s = (i == 1);
            i_diff_st*c(i, l) - j_diff_st*c(j, l) - x(i, j, l) + z(i, j, l) + i_is_s * w(l) <= 0 : f{i, j, l};
        end
    end
end


% sdp
n = size(A, 1);
for i=1:dim_i
    for j=1:dim_j
        A1 = 0 * x(i, j, 1) * A(:, :, 1);
        A2 = 0 * x(i, j, 1) * A(:, :, 1);
        A3 = 0 * x(i, j, 1) * A(:, :, 1);
        A4 = 0 * x(i, j, 1) * A(:, :, 1);
        for l=1:dim_l
            A1 = A1 + (1-t(l))*x(i, j, l)*A(:, :, l);
            A2 = A2 + (1+t(l))*x(i, j, l)*A(:, :, l);
            A3 = A3 + (1-t(l))*z(i, j, l)*A(:, :, l);
            A4 = A4 + (1+t(l))*z(i, j, l)*A(:, :, l);
        end
        A1 == -semidefinite(n);
        A2 == -semidefinite(n);
        A3 == -semidefinite(n);
        A4 == -semidefinite(n);
    end
end


cvx_end

ff = reshape(permute(cell2mat(f), [2 1 3]), [(number_nodes*number_nodes) (deg+1)]);
%ezplot(c * t', [-1 1]);
dlmwrite('visualize/flow-graph3', round(ff, 3));
dlmwrite('visualize/cap-graph3', round(capacities', 3));

%f_s = cell2mat(squeeze( f(1, :, :)));
%plot(t, f_s(2, :)');
 
