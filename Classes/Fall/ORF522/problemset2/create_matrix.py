
W = array([ 0,  5,  4,  0,  0,  0,  0,  0,  0,  0,  1,  3,  0,  0,  0,  0,  0,
         0,  0,  5,  0,  0,  0,  3,  0,  4,  6,  0,  0,  0,  0,  0,  0,  1,
        10,  0,  0,  0,  0,  1,  0,  6,  0,  0,  0,  0,  0,  1,  0])

W = [
0     5     4     8     0     0     0
0     0     0     1     3     0     0
0     0     0     0     0     5     0
0     0     3     0     4     6     0
0     0     0     0     0     1    10
0     0     0     0     1     0     6
0     0     0     0     0     1     0
]

c = np.zeros(49)
c[:7] = 1

A = np.zeros((7,49))
for v in range(1,6): 
    for u in range(7): 
        A[v, u*7+v] = 1
        A[v, v*7+u] = -1

%----------------------------%
matlab

A = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 -1 -1 -1 -1 -1 -1 -1 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 -1 -1 -1 -1 -1 -1 -1 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 -1 -1 -1 -1 -1 -1 -1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 -1 -1 -1 -1 -1 -1 -1 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 -1 -1 -1 -1 -1 -1 -1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
A = reshape(A, 49, 7).';
c = [1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
W = [
0     5     4     8     0     0     0
0     0     0     1     3     0     0
0     0     0     0     0     5     0
0     0     3     0     4     6     0
0     0     0     0     0     1    10
0     0     0     0     1     0     6
0     0     0     0     0     1     0
];

b = zeros(7, 1);
f = linprog(-c, [], [], A, b, W*0, W);
f = reshape(f, 7, 7)
