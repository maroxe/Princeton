from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
from matplotlib import cm

import numpy as np

t = np.concatenate((np.linspace(-1, 1, 100), np.linspace(-1000, 1000, 10000)))
z = 1 / (1 + t**2)
y = z * t 
x = y * t

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
ax.scatter(x, y, z)
ax.scatter(-x, -y, -z)
plt.xlabel('x')
plt.ylabel('y')

plt.show()

