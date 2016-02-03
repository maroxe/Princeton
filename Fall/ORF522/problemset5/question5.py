import numpy as np
import itertools
from scipy.optimize import linprog

up, down = 1.1, 0.9
p = 0.45
S0 = 1.
K = 1.
timestep = 10.
T = int(100 / timestep)

#######################
# Tree pricing
#######################

def generate_slates(n):
    for i in range(n):
        yield (n-i-1, list(range(n-i)))

def backward_induction(St, Jnext):
    expected_J = p * Jnext[:-1] + (1-p) * Jnext[1:]
    buffer = np.array([expected_J, St-K])
    control = np.argmax(buffer, axis=0)
    J = np.maximum(St-K, expected_J)
    return (J, control)

def price_tree():
    J = np.zeros(T+1) 
    for i, slate in generate_slates(T):
        St = map(lambda k: pow(down,k)*pow(up,i-k), slate)
        St = np.array(list(St))*S0
        J, control = backward_induction(St, J)
        yield np.array([i*np.ones_like(St), St, J, control])


#######################
# LP Pricing
#######################

# Get the relevent matrices
def get_A():
    row = np.zeros(T*T)
    row[T] = p
    row[T+1] = 1-p
    A = [row]
    for _ in range(T*(T-1)-1):
        row = np.roll(row, 1)
        A.append(row)
    row = 0 * row
    for _ in range(T): A.append(row)
    return np.array(A)

def get_B():
    B = np.zeros( shape=(T*(T-1)/2, T*T) )
    i, j = 0, 0
    for a in range(T-1):
        j += a + 1
        for b in range(T-a-1):
            B[i, j] = 1
            i, j = i+1, j+1
    return B
def get_U():
    return np.array([
        pow(down, k) * pow(up, t-k) * S0 
        for t in range(T)
        for k in range(T)
    ]) - K

# Construct and solve the LP program
def price_lp():
    L = pow(up, T)*S0-K # Upper bound for J
    # Look at PDF for definition of A, B, U and c
    A = get_A() 
    B = get_B() 
    U = get_U() 
    c = np.ones_like(U)
    
    res = linprog(c, 
              A_ub=np.vstack(A-np.eye(T*T)), 
              b_ub=np.zeros_like(U),
              A_eq=B,
              b_eq=L*np.ones(B.shape[0]),
              bounds = list(zip(U, np.ones_like(U)*L)),
              options={"disp": True})

    if res.status != 0: 
        print("Optimization failed, try a lower value for T")
        exit()

    J = res.x
    U.shape = J.shape = (T, T)
    control = (J - U < 1e-8)
    for i, slate in generate_slates(T):
        St = map(lambda k: pow(down,k)*pow(up,i-k), slate)
        St = np.array(list(St))*S0
        yield np.array([i*np.ones_like(St), St, J[i, :i+1], control[i, :i+1]])

# plot 
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import matplotlib.lines as mlines

def plot(pricing_method, name, img):
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    c = np.array(('b', 'r'))
    m = np.array(('^', 'o'))
    for points in pricing_method():
        for u in (0, 1):
            xs, ys, z_tree, _ = points[:,abs(points[3] - u) <= 0.01]
            ax.scatter(xs, 
                   ys, z_tree, s=50, 
                   c=c[u], marker=m[u],
                   depthshade=False)

    ax.set_xlabel('t'); ax.set_xlim((0, T))
    ax.set_ylabel('St'); ax.set_ylim((0, pow(up, T)*S0))
    ax.set_zlabel('J(t, St)')
    labels_str = ('Hold', 'Exec')
    labels = [
        mlines.Line2D([], [], color=c[u], marker=m[u],
                      markersize=10, label=labels_str[u])
        for u in (0, 1)]
    plt.title(name)
    plt.legend(handles=labels)
    plt.savefig('q%s.png' % img)
    plt.show()

plot(price_tree, 'Backward Induction', 'tree')
plot(price_lp, 'LP programming', 'lp')










