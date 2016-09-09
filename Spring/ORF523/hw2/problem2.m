a = 2;
b = 3;
theta = [0.05 0.1 0.3];
alpha = [-0.1 0.8 -0.3];
beta = [1.4 -0.3 0.7];
num_periods = 24;
num_groups = 3;
Theta = zeros(num_groups, num_periods);
for k=1:num_groups
    for i=1:num_periods
        Theta(k, i) = 1 - (1-theta(k))^(num_periods-i+1);
    end
end

%% Maximize individual CES
for group=1:3
    cvx_begin
    variable T(num_periods);
    maximize( Theta(group,:) * (alpha(group) * T + beta(group) * (1-T)) )
    0 <= T <= 1;
    T(1:b) == 1;
    for i = 4 : num_periods
        sum(1 - T((b+1):i)) <= a* T((b+1):i)
    end
    cvx_end
    figure(group)
    subplot(2,1,1)
    title('s_i')
    % calculate s_i
    for k=1:3
        s = zeros(num_periods+1);
        for i=2:(num_periods+1)
            s(i) = (1- theta(k)) * s(i-1) + theta(k) * (alpha(k) * T(i-1) ...
                                                        + beta(k) * (1-T(i-1)));
        end
        hold on
        plot(s(2:num_periods), '*-')
    end
    subplot(2,1,2)
    plot(T, '*-')
    title('Theory proportion')
end


%% max min CES
cvx_begin 
variable T(num_periods)
variable t
maximize t
0 <= T <= 1
T(1:b) == 1
for i = 4 : num_periods
    sum(1 - T(b:i)) <= a* T(b:i)
end
for g = 1 : num_groups
    t <= ( Theta(g,:) * (alpha(g) * T + beta(g) * (1-T)) )
end
cvx_end

figure(4)
subplot(2,1,1)
title('s_i')
% calculate s_i
for k=1:3
    s = zeros(num_periods+1);
    for i=2:(num_periods+1)
        s(i) = (1- theta(k)) * s(i-1) + theta(k) * (alpha(k) * T(i-1) ...
                                                    + beta(k) * (1-T(i-1)));
    end
    hold on
    plot(s(2:num_periods), '*-')
end
subplot(2,1,2)
plot(T, '*-')
title('Theory proportion')

for p =1:4
    saveas(p,[ 'plan' int2str(p)], 'png')
end

















