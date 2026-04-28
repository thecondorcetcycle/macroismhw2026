function [w_j, a_j] = solve_wj(phi, par, obj, w_s, w_m)
    %% Objects inherited from the senior worker

    D_s = 1 - par.beta * par.gamma_ss * (1 - par.delta);
    V_us = w_s / (1 - par.beta * par.gamma_ss);
    V_es = @(w) (w + par.beta * par.gamma_ss * par.delta * V_us) ./ D_s;

    Vtilde_s = @(w) par.beta * (1 - par.gamma_mm) .* ...
        ((1 - par.delta) .* V_es(w) + par.delta .* V_us);

    B_s = par.beta * (1 - par.gamma_mm) * (1 - par.delta) / D_s;

    %% Objects inherited from the middle-aged worker

    D_m = 1 - par.beta * par.gamma_mm * (1 - par.delta);
    V_um = (w_m + Vtilde_s(w_m)) / (1 - par.beta * par.gamma_mm);
    V_em = @(w) (w + par.beta * par.gamma_mm * par.delta * V_um + ...
        Vtilde_s(w)) ./ D_m;

    Vtilde_m = @(w) par.beta * (1 - par.gamma_jj) .* ...
        ((1 - par.delta) .* V_em(w) + par.delta .* V_um);

    B_m = par.beta * (1 - par.gamma_jj) * (1 - par.delta) * ...
        (1 + B_s) / D_m;

    %% Young objects

    beta_tilde_j = par.beta * par.gamma_jj / ...
        (1 - par.beta * par.gamma_jj * (1 - par.delta));

    I_m = (1 + B_s) .* obj.R(w_m);

    gain_j = @(x) beta_tilde_j .* (1 + B_m) .* obj.R(x) ...
        + par.beta * (1 - par.gamma_jj) / D_m .* I_m;

    a_j_star = @(x) max(0, (1 ./ phi) .* log( ...
        phi .* gain_j(x) ./ par.psi ));

    T_j = @(x) par.b ...
        - par.psi .* a_j_star(x) ...
        + Vtilde_m(w_m) - Vtilde_m(x) ...
        + obj.pi(a_j_star(x), phi) .* gain_j(x);

    Psi_j = @(x) x - T_j(x);
    dGain_j = @(x) -beta_tilde_j .* (1 + B_m) .* (1 - obj.F(x));
    dPsi_j = @(x) 1 + B_m - obj.pi(a_j_star(x), phi) .* dGain_j(x);

    %% Bracket

    wL = par.b;
    wH = par.mu + 2 * par.sigma;

    fL = Psi_j(wL);
    fH = Psi_j(wH);

    if abs(fL) < 1e-12
        w_j = wL;
        a_j = a_j_star(w_j);
        return;
    elseif abs(fH) < 1e-12
        w_j = wH;
        a_j = a_j_star(w_j);
        return;
    end

    if fL * fH > 0
        error('solve_wj:badBracket', ...
            'Initial bracket does not contain a sign change.');
    end

    %% Safeguarded Newton-Raphson solver

    tol = 1e-10;
    max_iter = 200;
    w_j = 0.5 * (wL + wH);

    for iter = 1:max_iter
        f = Psi_j(w_j);

        if abs(f) < tol || (wH - wL) < tol
            break;
        end

        df = dPsi_j(w_j);
        w_newton = w_j - f ./ df;

        if isfinite(w_newton) && w_newton > wL && w_newton < wH
            w_next = w_newton;
        else
            w_next = 0.5 * (wL + wH);
        end

        f_next = Psi_j(w_next);

        if fL * f_next <= 0
            wH = w_next;
            fH = f_next;
        else
            wL = w_next;
            fL = f_next;
        end

        w_j = w_next;
    end

    if iter == max_iter && abs(Psi_j(w_j)) >= tol
        error('solve_wj:noConvergence', ...
            'Safeguarded Newton did not converge.');
    end

    a_j = a_j_star(w_j);
end
