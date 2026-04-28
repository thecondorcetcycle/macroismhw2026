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
    dPsi_s = @(x) 1 + beta_tilde_s .* obj.pi(a_s_star(x), phi) .* ...
        (1 - obj.F(x));

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

    %% Safeguarded Newton-Raphson solver

    tol = 1e-10;
    max_iter = 200;
    w_s = 0.5 * (wL + wH);

    for iter = 1:max_iter
        f = Psi_s(w_s);

        if abs(f) < tol || (wH - wL) < tol
            break;
        end

        df = dPsi_s(w_s);
        w_newton = w_s - f ./ df;

        if isfinite(w_newton) && w_newton > wL && w_newton < wH
            w_next = w_newton;
        else
            w_next = 0.5 * (wL + wH);
        end

        f_next = Psi_s(w_next);

        if fL * f_next <= 0
            wH = w_next;
            fH = f_next;
        else
            wL = w_next;
            fL = f_next;
        end

        w_s = w_next;
    end

    if iter == max_iter && abs(Psi_s(w_s)) >= tol
        error('solve_ws:noConvergence', ...
            'Safeguarded Newton did not converge.');
    end

    a_s = a_s_star(w_s);
end
