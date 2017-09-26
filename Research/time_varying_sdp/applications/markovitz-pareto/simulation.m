clear;
cd  '~/Documents/Princeton/Research/time_varying_sdp/applications/markovitz-pareto'
addpath(genpath(['~/Documents/Princeton/Research/' ...
                 'time_varying_polynomials/yalmip']))
sdpsettings('solver','mosek')
addpath(genpath('~/mosek/mosek'))


%% Markowitz Portfolio Optimization
%
% min x'Sx
% s.t. p'x >= r_min
%      1'x = 1
%      x >= 0
%      sum_{i=1}^{0.1n} x[i] <= alpha
%
% x: portfolio weights
% S: portfolio covariance matrix
% p: mean return vector
% x[i]: ith greatest component in x
%
%% generate data
randn('state',0);
n=25; %number of items
p_mean = randn(n,1);
temp = randn(n,n);
sig = temp'*temp;
r = floor(0.1*n);


vol_range = 0:0.1:1;
f1 = vol_range;
f2 = [];
sol_discrete = [];
for v=vol_range
    x_opt = solve_markovitz(sig, p_mean, v);
    f2 = [f2 (p_mean'*x_opt)];
    sol_discrete = [ sol_discrete x_opt  ];
end

figure(1)
clf
hold on
plot(f1, f2, '-o')
xlabel('vol')
ylabel('return')
title('vol vs returns pareto curve');



%% poly solution
deg_x = 10;

% variables
x = [];
sdpvar t;
dummy = sdpvar (n+1, 1);
mon = [t; dummy];
parametric = [];
coef_x = []
for i=1:n
    [xi, ci] = polynomial(t, deg_x);
    x = [x; xi];
    parametric = [parametric; ci];
    coef_x = [coef_x; ci]
end
M = [t x'; x inv(sig)];

%
objective = int(p_mean' * x,t, 0, 1);


% const
F = [];
pos_constraints = [
    dummy'*M*dummy;
    1 - sum(x),
    x; ];


for i=1:length(pos_constraints)
    needed_mon = [t];
    if i == 1
        needed_mon = mon;
    end
    p=pos_constraints(i);
    deg = ones(length(needed_mon), 1)*2;
    deg(1) = deg_x;
    deg'
    [s2, cs2] = polynomial(needed_mon, deg);
    deg(1) = deg_x-1;
    [s0, cs0] = polynomial(needed_mon, deg);
    [s1, cs1] = polynomial(needed_mon, deg);

    parametric = [parametric; cs0; cs1; cs2];
    F = [F,
         coefficients(p - t*s0 - (1-t)*s1 - s2, ...
                 needed_mon) == 0,
         sos(s0), sos(s1), sos(s2),
        ];
end

solvesos(F, -objective, [], parametric)
xpoly = x{[t; value(coef_x)]}

figure(1)
clf
hold on
plot(f1, f2, '-o')
xlabel('vol')
ylabel('return')
title('vol vs returns pareto curve');

[Y, X] = sample_poly(xpoly);
plot(X, p_mean' * Y);


figure(3)
clf
hold on
plot(f1, sol_discrete')
plot(X,  Y, '--');
title('x_i(t)');

%% generate plots
figure; bar(x); xlim([0, n]);
title('optimal portfolio weights');