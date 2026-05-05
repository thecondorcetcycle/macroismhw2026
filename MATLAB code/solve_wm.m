function [w_m, a_m] = solve_wm(phi, par, obj, w_s)
    %% solving objects from the senior worker
    D_s = 1 - par.beta * par.gamma_ss * (1 - par.delta);

    V_us = w_s / (1 - par.beta * par.gamma_ss);

    V_es = @(w) (w + par.beta * par.gamma_ss * par.delta * V_us) ./ D_s;

    % Continuation value into senior
    Vtilde_s = @(w) par.beta * (1 - par.gamma_mm) .* ...
        ((1 - par.delta) .* V_es(w) + par.delta .* V_us);

    B_s = par.beta * (1 - par.gamma_mm) * (1 - par.delta) / D_s;

    %% middle-aged objects

    % Simplified integral
    I_m = @(x) (1 + B_s) .* obj.R(x);

    % Gain term (future surplus)
    beta_tilde_m = par.beta * par.gamma_mm / ...
        (1 - par.beta * par.gamma_mm * (1 - par.delta));

    gain_m = @(x) beta_tilde_m .* I_m(x) ...
        + par.beta * (1 - par.gamma_mm) / ...
        (1 - par.beta * par.gamma_ss * (1 - par.delta)) ...
        * obj.R(w_s);

    % Optimal effort
    a_m_star = @(x) max(0, (1 ./ phi) .* log( ...
        phi .* gain_m(x) ./ par.psi ));

    %% the fixed-point operator

    T_m = @(x) par.b ...
        - par.psi .* a_m_star(x) ...
        + Vtilde_s(w_s) - Vtilde_s(x) ...
        + obj.pi(a_m_star(x), phi) .* gain_m(x);

    Psi_m = @(x) x - T_m(x);

    %% checking the bracket

    wL = par.b;
    wH = par.mu + 2 * par.sigma;

    fL = Psi_m(wL);
    fH = Psi_m(wH);

    if abs(fL) < 1e-12
        w_m = wL;
        a_m = a_m_star(w_m);
        return;
    elseif abs(fH) < 1e-12
        w_m = wH;
        a_m = a_m_star(w_m);
        return;
    end

    if fL * fH > 0
        error('solve_wm:badBracket', ...
            'Initial bracket does not contain a sign change.');
    end

    %% Bracketed fzero solver

    w_m = fzero(Psi_m, [wL, wH]);

    a_m = a_m_star(w_m);
end
