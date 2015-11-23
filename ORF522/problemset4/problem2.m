cvx_begin
    variable x
    variable y
    variable z
    minimize(x^2 + 0.5 * y^2 + (x+0.5*y)^2 + (z+0.5*y)^2 -6*x - 7*y - 8*z - 9)
cvx_end
