import numpy as np
import matplotlib.pyplot as plt
import itertools

up, down = 1.1, 0.9
p = 0.45
S0 = 1.
K = 1.
T = 10
L = pow(up, T)*S0-K

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
    pow(down, k) * pow(up, t-k) * S0 
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
              bounds = list(zip(U, np.ones_like(U)*L)),
              options={"disp": True})

if res.status != 0: 
    print("Optimization failed, try a lower value for T")
    exit()

J = res.x
U.shape = J.shape = (T, T)
control = (J - U > 1e-8)
for i in range(T):
    print(J[i, :i+1])
    print(control[i, :i+1])













