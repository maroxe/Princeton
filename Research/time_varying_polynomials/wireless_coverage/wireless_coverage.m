addpath(genpath(['/Users/maroxe/Documents/Princeton/Research/' ...
                 'time_varying_polynomials/yalmip']))
sdpsettings('solver','mosek')
addpath(genpath('~/mosek/mosek'))

clear; 
deg_certificate_region = 0;
C = 1e-2;
deg = 7;

sdpvar  t;
sdpvar  x;
sdpvar  y;


[c1, coef1] = polynomial(t, deg)
[c2, coef2] = polynomial(t, deg)

% position of transmitters
transmitter1 = [-5; -5];
transmitter2 = [5; 5];


% centers of regions to cover
z1 = [(t/3)+1; (t/3)];
z2 = [2*(t/5)-2; (t/5)^2-2];

% regions to cover
g1 = 1 - (x - z1(1))^2 - (y - z1(2))^2;
g2 = 1 - (x - z2(1))^2 - (y - z2(2))^2;
gx = 9 - x^2;
gy = 9 - y^2;

% multipliers for region 1: g1 >= 0
a0 = polynomial([t x y], deg);
a1 = polynomial([t x y], deg_certificate_region);
a2 = polynomial([t x y], deg-1);
a3 = polynomial([t x y], deg-1);
ax = polynomial([t x y], deg);
ay = polynomial([t x y], deg);

% multipliers for region 2
b0 = polynomial([t x y], deg);
b1 = polynomial([t x y], deg_certificate_region);
b2 = polynomial([t x y], deg-1);
b3 = polynomial([t x y], deg-1);
bx = polynomial([t x y], deg);
by = polynomial([t x y], deg);

% p = -C d1^2 d2^2 + c1 d2^2 +c2 d1^2
p = - C * ((x - transmitter1(1))^2 + (y - transmitter1(2))^2);
p = p   * ((x - transmitter2(1))^2 + (y - transmitter2(2))^2);
p = p + c1 * ((x - transmitter2(1))^2 + (y - transmitter2(2))^2);
p = p + c2 * ((x - transmitter1(1))^2 + (y - transmitter1(2))^2);

% constraint


obj = c1 + c2;
obj = int(obj, t, -1, 1);

F = [
    coefficients(p-a0-a1*g1-ax*gx-ay*gy-a2*(1-t)-a3*(1+t), [x y t]) == 0,
    coefficients(p-b0-b1*g2-bx*gx-by*gy-b2*(1-t)-b3*(1+t), [x y t]) == 0,
    sos(ax), sos(ay), sos(a0), sos(a1), sos(a2), sos(a3),
    sos(bx), sos(by), sos(b0), sos(b1), sos(b2), sos(b3),
    coefficients(a1, [x y t]) == 0,
    coefficients(b1, [x y t]) == 0,
    ]

solvesos(F,obj)
value(obj)

% sol
cpoly1 = c1{[t; value(coef1)]};
cpoly2 = c2{[t; value(coef2)]};

% plot
times = -1:.1:1;
% save to gif
clf;
filename = 'wireless.gif';
figure(1)
hold on
xlim([-6, 6]);
ylim([-6, 6]);

% transmission power
[X,Y] = meshgrid(-6:0.1:6);
D1 = (X - transmitter1(1)).^2 + (Y - transmitter1(2)).^2;
D2 = (X - transmitter2(1)).^2 + (Y - transmitter2(2)).^2;
n=1
for n = 1:size(times, 2)
    time_snapshot = times(n);
    E =  cpoly1{time_snapshot} ./ D1 + cpoly2{time_snapshot} ./ D2;
    
    image([-6 6], [-6 6], E >= C*0.99)
    plot(transmitter1(1), transmitter1(2), 'ko');
    plot(transmitter2(1), transmitter2(2), 'ko');

    % g1{t, x, y}
    plot([x^2 <= 9, y^2 <= 9], [x y], 'b')
    plot([g1{time_snapshot, x, y} >= 0], [x y], 'r')
    plot([g2{time_snapshot, x, y} >= 0], [x y], 'g')

    drawnow
    frame = getframe(1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if n == 1;
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append');
    end
end



% remove outliers
%outlier = 0;
%max = quantile(reshape(E,1,[]), 1 - outlier);
%min = quantile(reshape(E,1,[]), outlier);
%E(E > max | E < min) = nan;
