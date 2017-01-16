cd(['/Users/maroxe/Documents/Princeton/Research/' ...
    'time_varying_polynomials/drafts/summary/scripts'])

addpath(genpath('/Users/maroxe/Documents/Princeton/Research/time_varying_polynomials/yalmip'))
sdpsettings('solver','mosek')
addpath(genpath('~/mosek/mosek'))

clear;
deg = 9;
k = (deg-1) / 2;


% chebychev basis
syms sym_x;
assume(sym_x, 'real')
chebychev_basis = chebyshevT(0:(k-1), sym_x) * sqrt(2 / (2*k-1));
chebychev_basis(1) = chebychev_basis(1) / sqrt(2);
t = round(flipud(chebyshevTpoints(deg+1)), 8); %rouding avoids NAN
                                               %in chehbychev evaluation
chebychev_basis_t = eval(subs(chebychev_basis, t));
eval_chebychev_basis = @(u) chebychev_basis_t(:, 1:size(u)) * u;


% Basis for SOS
% squared_basis(i, j, l) = (squared_basis_{ij}^(l))
squared_basis = zeros(k, k, deg+1);
for l=1:(deg+1)
    p_tl = chebychev_basis_t(l, 1:k)';
    squared_basis(:, :, l) = p_tl * p_tl';
end


[w, lagrange_basis] = lagrange(sym_x, t);
% int in lagrange basis
int_lagrange_basis2d = int(lagrange_basis * lagrange_basis');
int_lagrange_basis2d_0_1 = eval(subs(int_lagrange_basis2d, 1) - subs(int_lagrange_basis2d, -1));



%A(i, j, l)
A = [2-t -1-t;
     1+t 2-t;
     -[2-t -1-t];
     -[1+t 2-t];
     [2+t 2+t]
    ];
A = squeeze(reshape(A, [size(t), 5, 2]));
A = permute(A, [2 3 1])
[dim_constraints, dim_variable, dim_l] = size(A)


%b(i, l)
b = [(0*t + 1) (0*t +  1)  (0*t +  2)  (0*t +  2) (-t)]';

%c(j, l)
%c = [t.*(t-0.5).*(t-1) (t-0.25).*(t-0.75)]';
c = [t (t+0.1).^2]';

%%% plot
x_plot = sdpvar(2,1);
figure(3)
clf

hold on
F = [A(:, :, 10) * x_plot <=  b(:, 10)];
plot(F, x_plot, 'red');

cvx_clear;
%cvx_precision high
cvx_begin

variables x(dim_variable, dim_l);
variables X(dim_constraints, k, k);
variables Y(dim_constraints, k, k);

% int <xt, ct> dt, t=-1..1
obj = 0;
for j=1:2
    obj = obj + chebyshevTint(c(j,:)', x(j,:)', int_lagrange_basis2d_0_1);
end

maximize(obj)
obj <= 10;
for i=1:dim_constraints
    for l=1:dim_l
        b(i, l) - A(i, :, l)*x(:, l) == sum(dot(squared_basis(:, :, l), (1-t(l)) * squeeze(X(i, :, :)) + (1+t(l)) * squeeze(Y(i, :, :))));
    end
    squeeze(X(i, :, :)) == semidefinite(k);
    squeeze(Y(i, :, :)) == semidefinite(k);
end


cvx_end


%%% reconstruct and plot

figure(2)

clf;
hold on
t_for_plot = -1:0.01:1;
x_for_plot = eval(subs((x * lagrange_basis)', t_for_plot'))';
plot3(x_for_plot(1, :), x_for_plot(2, :), t_for_plot, 'r--', ...
      'LineWidth', 3)
hold on
%plot(x(1, :), x(2, :))

for l=1:2:10
    A_t = A(:, :, l);
    b_t = b(:, l);
    c_t = c(:, l);
    c_t = c_t / (2*norm(c_t));
    x_opt_t =  linprog(-c_t, A_t, b_t);
    V = con2vert(A_t, b_t);
    conv_hull = convhull(V);
    plot3(x_opt_t(1), x_opt_t(2), t(l), 'bo', 'LineWidth', 3)
    linestyle = '--';
    linewidth = 0.5;
    if l == 1 || l == 9
        linestyle = '-';
        linewidth = 2;
    end
    plot3(V(conv_hull, 1), V(conv_hull, 2), V(conv_hull, ...
                                                      2)*0+t(l), ['b' linestyle],  'LineWidth', linewidth);
            quiver3(mean(V(conv_hull, 1)), mean(V(conv_hull, 2)), t(l), ...
                    c_t(1), c_t(2), 0, ['k' linestyle], 'LineWidth', linewidth)
end
text(mean(V(conv_hull, 1)), mean(V(conv_hull, 2)), t(l), ['A(t)x(t) <= b(t)'], 'Color', 'b');

xlabel('x_1')
ylabel('x_2')
zlabel('t')
