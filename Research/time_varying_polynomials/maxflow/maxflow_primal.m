%%%%%%%%%%%%%%%%
clear;

%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('../yalmip'))
sdpsettings('solver','mosek')
addpath(genpath('~/mosek/mosek'))

deg = 33;
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

% graph = [
% %0 1 2 3 4 5 6 7 8
% %S B C D F G H I T
% 0; 0; 0; 0; 0; 0; 0; 0; 0;
% 0; 0; 0; 0; 0; 0; 0; 0; 0;
% 0; 0; 0; 0; 0; 0; 0; 0; 0;
% 0; 0; 0; 0; 0; 0; 0; 0; 0;
% 0; 0; 0; 0; 0; 0; 0; 0; 0;%; F
% 0; 0; 0; 0; 0; 0; 0; 0; 0;%; G
% 0; 0; 0; 0; 0; 0; 0; 0; 0;%; H
% 0; 0; 0; 0; 0; 0; 0; 0; 0;%; I
% 0; 0; 0; 0; 0; 0; 0; 0; 0;% T
% ];

%graph = importdata('matlab-graph.txt', ',' ,0)';
number_nodes = round(sqrt(size(graph, 1)));


% chebychev basis
syms sym_x;
chebychev_basis = chebyshevT(0:(k-1), sym_x) * sqrt(2 / (2*k-1));
chebychev_basis(1) = chebychev_basis(1) / sqrt(2);
t = round(flipud(chebyshevTpoints(deg+1)), 8); %rouding avoids NAN
                                               %in chehbychev evaluation
chebychev_basis_t = eval(subs(chebychev_basis, t));
eval_chebychev_basis = @(u) chebychev_basis_t(:, 1:size(u)) * u;

[w, lagrange_basis] = lagrange(sym_x, t);

% generate polynomials
M = 3;
list_polynomials = zeros(M, deg+1);
cap = 10.*(t+1/2).*(t-.2).*(t+.3).*(t.^2-0.9)+5;
cap2 = 3-t.^2-t+t.^5;
cap3 = 3-t.^2+t;
cap4 = (((t+0.5)*3).^3-4*((t+0.5)*3).^2+40)/10;
list_polynomials(1, :) = cap2;
list_polynomials(2, :) = cap3;
list_polynomials(3, :) = cap4;
cap0 = 0 * cap;


%capacities = repmat(graph, [1 deg+1])' .* repmat(cap, [1
%(number_nodes^2)]);
rng('default');
rng(1);
capacities = repmat(graph, [1 deg+1])' .* list_polynomials(randi(3, 1, number_nodes^2), :)';

b = reshape(capacities, [(deg+1), number_nodes, number_nodes ...
                   ]);
b = permute(b, [3 2 1]);
% b = 0 * b;
% b(1, 2, :) = 1+t;
% b(1, 4, :) = 1-t;
%b(2, 9, :) = 1;
%b(4, 9, :) = 1;
%capacities = reshape(permute(b, [3, 2, 1]), deg+1, number_nodes*number_nodes);
%b_ijl = b_coord(i, j, l)

% A(i, j, l) = (A_{ij}^(l))
A = zeros(k, k, deg+1);
for l=1:(deg+1)
    p_tl = chebychev_basis_t(l, :)';
    A(:, :, l) = p_tl * p_tl';
    [sum(sum(A( :, :, l))) l]
end

[dim_i, dim_j, dim_l] = size(b)


%%%%%%%%%%%%%

cvx_clear;
%cvx_precision high
cvx_begin
variables f(dim_i, dim_j, dim_l);
variables X(4, dim_i, dim_j, k, k);

% objective = int sum f_{1j}(t) dt = sum_l(sum_k f_{1, j, l})w_l
obj = dot(squeeze(sum(f(1, :, :))), w);
maximize(obj)

for i=2:(dim_i-1)
    for l=1:dim_l
        sum(f(i, :, l))  - sum(f(:, i, l)) == 0;
    end
end

for i=1:dim_i
    for j=1:dim_j
        for l=1:dim_l
            f(i, j, l) == sum(dot(A(:, :, l), (1-t(l)) * squeeze(X(1, i, j, :, :)) + (1+t(l)) * squeeze(X(2, i, j, :, :))))
            b(i, j, l) - f(i, j, l) == sum(dot(A(:, :, l), (1-t(l)) * ...
                                          squeeze(X(3, i, j, :, :)) + (1+t(l)) * squeeze(X(4,i, j, :, :))))
        end
        for r=1:size(X, 1)
            squeeze(X(r, i, j, :, :)) == semidefinite(k)
        end
    end
end

cvx_end

ff = reshape(permute(f, [2 1 3]), [(number_nodes*number_nodes) (deg+1)]);
%ezplot(c * t', [-1 1]);
dlmwrite('visualize/flow-graph3', round(ff, 3));
dlmwrite('visualize/cap-graph3', round(capacities', 3));
dlmwrite('visualize/time-points', t');
%f_s = cell2mat(squeeze( f(1, :, :)));
%plot(t, f_s(2, :)');
 
