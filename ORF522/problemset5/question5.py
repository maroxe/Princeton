import numpy as np
import itertools

up, down = 0.9, 1.1
p = 0.2
S0 = 100.
K = 100.
T = 100


def generate_slates(n):
    for i in range(n):
        yield (n-i-1, list(range(n-i)))

def backward_induction(St, Jnext):
    expected_J = p * Jnext[:-1] + (1-p) * Jnext[1:]
    buffer = np.array([expected_J, St-K])
    control = np.argmax(buffer, axis=0)
    J = np.maximum(St-K, expected_J)
    return (J, control)

def price(T):
    J = np.zeros(T+1) 
    for i, slate in generate_slates(T):
        St = map(lambda k: pow(up,k)*pow(down,i-k), slate)
        St = np.array(list(St))
        J, control = backward_induction(St, J)
        yield np.array([i*np.ones_like(St), St, J, control])


from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import matplotlib.lines as mlines

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
c = np.array(('b', 'r'))
m = np.array(('^', 'o'))
for points in price(T):
    for u in (0, 1):
        xs, ys, zs, _ = points[:,abs(points[3] - u) <= 0.01]
        ax.scatter(xs, 
                   ys, zs, s=50, 
                   c=c[u], marker=m[u],
                   depthshade=True)

ax.set_xlabel('t')
ax.set_ylabel('St')
ax.set_zlabel('J(t, St)')
labels_str = ('Hold', 'Exec')
labels = [
    mlines.Line2D([], [], color=c[u], marker=m[u],
                          markersize=10, label=labels_str[u])
    for u in (0, 1)]
plt.legend(handles=labels)

plt.show()

