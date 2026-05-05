function par = set_params()
    par.b     = 50;
    par.psi   = 1;
    par.delta = 0.2 / 12;
    par.beta  = 0.995;
    par.mu    = 100;
    par.sigma = 25;

    par.d = [10 * 12, 25 * 12, 5 * 12];
    par.gamma = (par.d - 1) ./ par.d;

    par.gamma_jj = par.gamma(1);
    par.gamma_mm = par.gamma(2);
    par.gamma_ss = par.gamma(3);
end
