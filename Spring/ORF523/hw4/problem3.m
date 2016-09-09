n = 4
cvx_begin 
variable S(n,n) hermitian 

variable a
variable b
variable c

maximize(c)

subjecto_to

S == hermitian_semidefinite( n )
for i = 1:4
    S(i, i) == 1 
end

S(1, 2) == -1/2
S(1, 3) == a
S(1, 4) == -1/10
S(2, 3) == b
S(2, 4) == c
S(3, 4) == -3/10

cvx_end

ans = [a b c]
