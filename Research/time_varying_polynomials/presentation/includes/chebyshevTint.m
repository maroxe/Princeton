function I = chebyshevTint(a, b, int2d)
k = max(length(a), length(b))
a = padarray(a, k, 'post')
I = a(1:k)' * int2d(1:k, 1:k) * b(1:k)
return 


