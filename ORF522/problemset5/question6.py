import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import bernoulli

M = 10000
T = 100
p = 0.8
K = 0
jumps = 2*bernoulli.rvs(p, size=(M, T))-1
jumps[:,0] = np.random.randint(-10,10, size=M)
trajectories = np.cumsum(jumps, axis=1) 
Smax = np.max(trajectories)
Smin = np.min(trajectories)

for i in range(10):
    plt.plot(trajectories[i])
plt.show()

Q = np.zeros(shape=(T, Smax-Smin+1))
Qupdate = np.zeros_like(Q)
gamma = 0.9
for traj in trajectories:
    for t, St in enumerate(traj[:-1]):
        Stnext = traj[t+1]
        Qupdate[t, St-Smin] = (1-gamma) * Q[t,St-Smin] + \
                gamma * max(Stnext - K,  Q[t+1, Stnext-Smin])
        Q = np.array(Qupdate, copy=True)

S = np.arange(Smin, Smax+1)
t = np.arange(1, T+1)
S, t = np.meshgrid(S, t)
flat = [Q.flatten(), S.flatten() - K]
J = np.maximum(*flat)
Control = np.argmax( np.array(flat), axis=0 )
J.shape = S.shape
Control.shape = S.shape
from matplotlib import pyplot as plt

plt.pcolormesh(S, t, J, cmap='RdBu')
plt.colorbar()
plt.axis([-10, 10, 1, T])
plt.show()

plt.pcolormesh(S, t, Control, cmap='RdBu')
plt.colorbar()
plt.axis([Smin, Smax, 1, T])
plt.axis([-10, 10, 1, T])
plt.show()




















