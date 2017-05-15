cd(['/Users/maroxe/Documents/Princeton/Research/' ...
    'time_varying_polynomials/presentation/includes/'])
addpath(genpath('../../yalmip'))
sdpsettings('solver','mosek')
addpath(genpath('~/mosek/mosek'))


%% Params
m = 30;
xmin = -2;
xmax = 2;
dt = 0.04;


% generate lp parameters
rng(17,'twister');
A=rand(m,2)*2-1;
b=ones(m,1);
% y = -x^2 + 1 
% x = 2t - 1
%cbasis =  [-1 2 0;0 4, -4]';
cbasis =  [0 -1/8 0 1/8; -1/16 0 1/4 0]';
% use con2vert.m to convert facet description to vertices
V=con2vert(A, b);
conv_hull = convhull(V);

% plot the region
figure(3)
clf
V=con2vert(A, b);
plot(V(conv_hull,1),V(conv_hull,2),...
     'k-o',...
     'LineWidth', 3)



%% SOS cheby
  deg = 8;
  k = deg / 2
  n = 2*k
  t = (-1):dt:1;
  syms x; chebychev_basis = chebyshevT(0:n, x) * sqrt(2 / (2*k+1)); chebychev_basis(1) = chebychev_basis(1) / sqrt(2);

  polynomial_solution_coord = lpsoscheby(A, b, -cbasis, deg, dt, chebychev_basis)';
  polynomial_solution = evalinchebychevbasis(t', polynomial_solution_coord, chebychev_basis);
  
  figure(3); clf; hold on

  % plot polytope and optimal polynomial solution
  plot(V(conv_hull,1),V(conv_hull,2),...
     'k-',...
     'LineWidth', 3)

  plot(polynomial_solution(1,:), polynomial_solution(2,:),...
       'r--', ...
       'LineWidth', 2)

  % plot c
  c_arrow = quiver(0, 0, 0, 0);

  % plot optimal solution
  optimal_solution_marker = plot(0, 0, 'bo', 'MarkerSize', 10);
  optimal_solution_text = text(0, 0, 'x(t)');

  % plot x poly
  polynomial_solution_marker = plot(0, 0, 'k*', 'MarkerSize', 10);
  polynomial_solution_text = text(0, 0, 'p(t)');

  % debug msg
  msg = text(1.5, 0, '');
  msg.FontSize = 15;


  
  for i=1:length(t)
      c = evalinchebychevbasis(t(i), cbasis, chebychev_basis);
      c = c / norm(c);
      x = linprog(-c, A, b);

      % update positions
      c_arrow.UData = c(1);
      c_arrow.VData = c(2);
    
      optimal_solution_textimal_solution_marker.XData = x(1);
      ooptimal_solution_textimal_solution_marker.YData = x(2);
      optimal_solution_text.Position = x + [0.1; 0.1];
      polynomial_solution_marker.XData = polynomial_solution(1, i);
      polynomial_solution_marker.YData = polynomial_solution(2, i);
      polynomial_solution_text.Position = polynomial_solution(:, i) - [0.3; 0.3];
      
      axis([min(V(:,1)) max(V(:,1)) min(V(:, 2)) max(V(:, 2))] + [-0.5 2 -0.5 0.5])
      
      msg.String = sprintf('t = %.2f\nx(t) = (%.2f, %.2f)\np(t) = (%.2f, %.2f))',...
      [t(i) x' polynomial_solution(:, i)']);

      drawnow
      M(i)=getframe;
  end
