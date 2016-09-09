P = [ 1 -0.6 0.2; 
      -0.6 2.6 0.6;
      0.2 0.6 0.4
    ] 
xc = [2 2 2]'
n = 3

cvx_begin
variable x(n)
variable y(n)
minimize norm(x - y)
subject to
norm(x, 1) <= 1
(y-xc)' * P * (y - xc) <= 1
cvx_end


