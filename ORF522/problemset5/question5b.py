import numpy as np
import matplotlib.pyplot as plt
import itertools

u, d = 0.9, 1.1
p = (1-d) / (u - d)
S0 = 1.
K = 1.
T = 10
L = pow(d, T)*S0-K


row = np.zeros(T*T)
row[T] = p
row[T+1] = 1-p
A = [row]
for _ in range(T*(T-1)-1):
    row = np.roll(row, 1)
    A.append(row)
row = 0 * row
for _ in range(T): A.append(row)
A = np.array(A)


B = np.zeros( shape=(T*(T-1)/2, T*T) )
i = 0
j = 0
for a in range(T-1):
    j += a + 1
    for b in range(T-a-1):
        B[i, j] = 1
        i += 1
        j += 1

U = np.array([
    pow(u, k) * pow(d, t-k) * S0 
    for t in range(T)
    for k in range(T)
]) - K

from scipy.optimize import linprog

c = np.ones_like(U)
zero = np.zeros_like(U)
I = np.eye(T*T)
res = linprog(c, 
              A_ub=np.vstack(A-I), 
              b_ub=zero,
              A_eq=B,
              b_eq=L*np.ones(B.shape[0]),
              bounds = list(zip(U, np.ones_like(c)*L)),
              options={"disp": True})

print(res.x[0])
exit()
J = res.x
J.shape = (T, T)
for i in range(T):
    print(J[i, :i+1])

