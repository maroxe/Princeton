function [w, p]=lagrange(sym_t, points)
%
%LAGRANGE   approx a point-defined function using the Lagrange polynomial interpolation
%
%      LAGRANGE(X,POINTX,POINTY) approx the function definited by the points:
%      P1=(POINTX(1),POINTY(1)), P2=(POINTX(2),POINTY(2)), ..., PN(POINTX(N),POINTY(N))
%      and calculate it in each elements of X
%
%      If POINTX and POINTY have different number of elements the function will return the NaN value
%
%      function wrote by: Calzino
%      7-oct-2001
%

n=size(points,1);
p = sym(zeros(n, 1));
points = round(points, 5);
for i=1:n
    p(i) = 1;
    for j=1:n
        if (i~=j)
            p(i)=p(i) * (sym_t-points(j))/(points(i)-points(j));
        end
        %[c, t] = coeffs(p(i), sym_t);
        %c = round(double(c), 2);
        %p(i) = c * t';
    end
end

w = eval(int(p, -1, 1));