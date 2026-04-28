function obj = rwage_objects(par)

obj.F = @(w) normcdf(w, par.mu, par.sigma);
obj.f = @(w) normpdf(w, par.mu, par.sigma);

obj.R = @(x) par.sigma^2 .* obj.f(x) ...
          + (par.mu - x) .* (1 - obj.F(x));

obj.pi = @(a, phi) 1 - exp(-phi .* a);

end