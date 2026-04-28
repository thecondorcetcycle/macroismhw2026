function stat = stationary_distribution(phi, par, obj, sol)
    %% Complete reservation wages and search efforts

    [w_j, a_j] = solve_wj(phi, par, obj, sol.w_s, sol.w_m);

    stat.phi = phi;
    stat.w_j = w_j;
    stat.a_j = a_j;
    stat.w_m = sol.w_m;
    stat.a_m = sol.a_m;
    stat.w_s = sol.w_s;
    stat.a_s = sol.a_s;

    %% Age weights

    d = [1 / (1 - par.gamma_jj), ...
         1 / (1 - par.gamma_mm), ...
         1 / (1 - par.gamma_ss)];
    n = d ./ sum(d);

    stat.n_j = n(1);
    stat.n_m = n(2);
    stat.n_s = n(3);

    %% Job-finding probabilities by current and next age

    pi_j = obj.pi(a_j, phi);
    pi_m = obj.pi(sol.a_m, phi);
    pi_s = obj.pi(sol.a_s, phi);

    p_jj = pi_j * (1 - obj.F(w_j));
    p_jm = pi_j * (1 - obj.F(sol.w_m));
    p_mm = pi_m * (1 - obj.F(sol.w_m));
    p_ms = pi_m * (1 - obj.F(sol.w_s));
    p_ss = pi_s * (1 - obj.F(sol.w_s));

    stat.p_jj = p_jj;
    stat.p_jm = p_jm;
    stat.p_mm = p_mm;
    stat.p_ms = p_ms;
    stat.p_ss = p_ss;

    %% Transition matrix in state order [e_j, u_j, e_m, u_m, e_s, u_s]

    Gamma = [par.gamma_jj, 1 - par.gamma_jj, 0; ...
             0, par.gamma_mm, 1 - par.gamma_mm; ...
             0, 0, par.gamma_ss];

    L_jj = [1 - par.delta, par.delta; p_jj, 1 - p_jj];
    L_jm = [1 - par.delta, par.delta; p_jm, 1 - p_jm];
    L_mm = [1 - par.delta, par.delta; p_mm, 1 - p_mm];
    L_ms = [1 - par.delta, par.delta; p_ms, 1 - p_ms];
    L_ss = [1 - par.delta, par.delta; p_ss, 1 - p_ss];

    L = [L_jj, L_jm, zeros(2); ...
         zeros(2), L_mm, L_ms; ...
         zeros(2), zeros(2), L_ss];

    Pi = kron(Gamma, ones(2)) .* L;
    Pi(5:6, 2) = Pi(5:6, 2) + (1 - par.gamma_ss);

    row_sums = sum(Pi, 2);
    if max(abs(row_sums - 1)) > 1e-10
        error('stationary_distribution:badTransitionMatrix', ...
            'Pi is not row-stochastic.');
    end

    %% Normalized left eigenvector associated with eigenvalue one

    [V, D] = eig(Pi.');
    [~, idx] = min(abs(diag(D) - 1));
    h = real(V(:, idx)).';
    h = h ./ sum(h);

    if any(h < -1e-10)
        h = abs(h);
        h = h ./ sum(h);
    end

    stat.Pi = Pi;
    stat.h = h;
    stat.e_j = h(1);
    stat.u_j = h(2);
    stat.e_m = h(3);
    stat.u_m = h(4);
    stat.e_s = h(5);
    stat.u_s = h(6);

    stat.emp_j = h(1) / n(1);
    stat.unemp_j = h(2) / n(1);
    stat.emp_m = h(3) / n(2);
    stat.unemp_m = h(4) / n(2);
    stat.emp_s = h(5) / n(3);
    stat.unemp_s = h(6) / n(3);

    stat.total_employment = h(1) + h(3) + h(5);
    stat.total_unemployment = h(2) + h(4) + h(6);
end
