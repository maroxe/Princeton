def etape(b, j):
    b = np.array(b)-1
    j = j-1
    Ab = A[:,b]
    cb = c[b]
    print(Ab)
    
    det = abs(np.linalg.det(Ab))
    inv = np.linalg.inv(Ab)
    cj = c[j] - np.dot(np.dot(cb.T, inv), A[:, j])
    d = np.zeros(5)
    d[j] = 1
    d[b] = - np.dot(inv, A[:, j]) 
    return (det, det*inv, cj, d)

# p2
"""A = array([[ 1,  2,  0,  4, -3],
       [ 1,  1,  0, -3,  4],
       [-1, -3,  3,  0,  0]])
c = array([ 2,  1,  3,  1, -3])
"""
#p4
A = np.array([2,2,4,1,0], [4,2,2,0,1])
c = np.array(140, 60, 146, 0, 0)
b = np.array(5, 8)
def etape(b, j):
    b = np.array(b)-1
    j = j-1
    Ab = A[:,b]
    cb = c[b]
    print(Ab)
    
    det = abs(np.linalg.det(Ab))
    inv = np.linalg.inv(Ab)
    cj = c[j] - np.dot(np.dot(cb.T, inv), A[:, j])
    d = np.zeros(5)
    d[j] = 1
    d[b] = - np.dot(inv, A[:, j]) 
    return (det, det*inv, cj, d)

# p2
"""A = array([[ 1,  2,  0,  4, -3],
       [ 1,  1,  0, -3,  4],
       [-1, -3,  3,  0,  0]])
c = array([ 2,  1,  3,  1, -3])
"""
#p4
A = np.array([2,2,4,1,0], [4,2,2,0,1])
c = np.array(140, 60, 146, 0, 0)
b = np.array(5, 8)
