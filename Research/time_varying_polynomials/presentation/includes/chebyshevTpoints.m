function points = chebyshevTpoints(n)
points = ones(n, 1) * 1.;
for i=1:n
    points(i) = cos( (i+0.5) * pi / (n+1));
end
return


