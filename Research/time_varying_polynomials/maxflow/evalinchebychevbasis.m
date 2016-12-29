function pt = evalinchebychevbasis(t, p_coord, chebychev_basis)
chebychev_basis_t = subs(chebychev_basis(1:length(p_coord)), t);
pt = eval(chebychev_basis_t * p_coord)';
return


