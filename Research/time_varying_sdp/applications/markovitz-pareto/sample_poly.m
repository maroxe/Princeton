function [xpoly_snaps, time_snaps] = sample_poly(q)
time_snaps = 0:.01:1;
xpoly_snaps = []
for i=time_snaps
    xpoly_snaps = [xpoly_snaps, q{i}];
end
end