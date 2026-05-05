function [w_s, a_s] = solve_ws(phi, par, obj)
    %% Senior reservation wage objects

    beta_tilde_s = par.beta * par.gamma_ss / ...
        (1 - par.beta * par.gamma_ss * (1 - par.delta));

    a_s_star = @(x) max(0, (1 ./ phi) .* log( ...
        phi .* beta_tilde_s .* obj.R(x) ./ par.psi ));

    T_s = @(x) par.b ...
        - par.psi .* a_s_star(x) ...
        + beta_tilde_s .* obj.pi(a_s_star(x), phi) .* obj.R(x);

    Psi_s = @(x) x - T_s(x);

    %% defining the bracket
    wL = par.b;
    wH = par.mu + 2 * par.sigma;
    fL = Psi_s(wL);
    fH = Psi_s(wH);

    if abs(fL) < 1e-12
        w_s = wL;
        a_s = a_s_star(w_s);
        return;
    elseif abs(fH) < 1e-12
        w_s = wH;
        a_s = a_s_star(w_s);
        return;
    end

    if fL * fH > 0
        error('solve_ws:badBracket', ...
            'Initial bracket does not contain a sign change.');
    end

    %% Bracketed fzero solver

    w_s = fzero(Psi_s, [wL, wH]);

    a_s = a_s_star(w_s);
end
