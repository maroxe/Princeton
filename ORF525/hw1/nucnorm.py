from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
from matplotlib import cm

import numpy as np


theta = np.linspace(0, 2 * np.pi, 100)
x = 0.5 + np.cos(theta) / 2
y = np.sin(theta) / np.sqrt(2)
z = 1 - x

x2 = -0.5 + np.cos(theta) / 2
y2 = np.sin(theta) / np.sqrt(2)
z2 = - 1 - x2



fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
ax.scatter(x, y, z)
ax.scatter(x2, y2, z2)

#draw sphere
u, v = np.mgrid[0:2*np.pi:30j, 0:np.pi:30j]
x=np.cos(u)*np.sin(v)
y=np.sin(u)*np.sin(v)
z=np.cos(v)
ax.plot_wireframe(x, y, z, color="r", alpha=0.4)

# draw plane
x, y=np.mgrid[-1.3:1.3:10j,-1.3:1.3:10j]
z = 1 - x
ax.plot_wireframe(x, y, z, alpha=0.4, color='g')
ax.plot_wireframe(x, y, z-2, alpha=0.4, color='g')


plt.xlim(-2, 2)
plt.ylim(-2, 2)
ax.set_zlim(-2, 2)
plt.xlabel('x')
plt.ylabel('y')
ax.set_zlabel('z')
ax.view_init(30, -60)
plt.savefig('nucnormset1.png')


fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

x, y=np.mgrid[-1:1:50j,-1.2:1.2:10j]

for a in (-1, 1):
    ax.plot_wireframe(x, y, a * (1 - np.abs(x)), color='b', alpha=1, rstride=2, cstride=2)
plt.xlim(-2, 2)
plt.ylim(-2, 2)
ax.set_zlim(-2, 2)
plt.xlabel('x')
plt.ylabel('y')
ax.set_zlabel('z')
ax.view_init(0, 80)
plt.savefig('nucnormset2.png')
plt.show()




