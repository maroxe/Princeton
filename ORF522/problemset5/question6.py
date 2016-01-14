import numpy as np
from scipy.stats import bernoulli

M = 100000 # number of iterations
gamma =  0.1 # Learning rate
T = 100   # Maturity
sigma=30   
mu = -0.5 * sigma
K = 0.     
X = np.random.normal(size=(M, T), scale=sigma, loc=mu)
X[:,0] = np.random.randint(-20, 20, size=M)
trajectories = np.cumsum(X, axis=1) 
trajectories = np.vectorize(int)(trajectories)

Smax = np.max(trajectories)
Smin = np.min(trajectories)
print(Smax - Smin)
S = np.arange(Smin, Smax+1)
t = np.arange(1, T+1)
S, t = np.meshgrid(S, t)

Q = S * 0.
Qupdate = Q.copy()
# Iterative update:
for traj in trajectories:
    transitions = list(enumerate(traj[:-1]))
    np.random.shuffle(transitions)
    for n, Sn in transitions:
        Snext = traj[n+1]
        Qupdate[n, Sn-Smin] = (1-gamma) * Q[n,Sn-Smin] + \
                gamma * max(Snext - K,  Q[n+1, Snext-Smin])
        Q = Qupdate.copy()

flat = [Q.flatten(), S.flatten() - K]
J = np.maximum(*flat)
Control = np.argmax( np.array(flat), axis=0 )
J.shape = S.shape
Control.shape = S.shape

# Plot
from matplotlib import pyplot as plt
import matplotlib.lines as mlines
from matplotlib.colors import ListedColormap

# Plot sample trajectories
for i in range(min(M, 1000)):
    plt.plot(trajectories[i])
plt.xlabel('t');plt.ylabel('St');
plt.title('Sample trajectories')
#plt.savefig('traj.png')
plt.show()


# Option price
plt.pcolormesh(S, t, J, cmap='RdBu')
plt.colorbar()
plt.axis([-10, 10, 1, T])
plt.title('$J(t, S)$')
plt.xlabel('$S$');plt.ylabel('$t$');
#plt.savefig('option.png')
plt.show()

# Exec strategy
labels_str = ('Hold','Exec')
cMap = ListedColormap(['Blue', 'Red'])
plt.pcolormesh(S, t, Control, cmap=cMap)
cbar = plt.colorbar()
cbar.ax.get_yaxis().set_ticks([])
for j, lab in enumerate(labels_str):
    cbar.ax.text(.75, (2 * j + 1) / 4.0, lab, ha='center', va='center', rotation=270)
cbar.ax.get_yaxis().labelpad = 15
cbar.ax.set_ylabel('# Strategy', rotation=270)
plt.axis([-10, 10, 1, T])
plt.xlabel('$S$');plt.ylabel('$t$');
plt.title('Exec/Hold')
#plt.savefig('control.png')
plt.show()




















