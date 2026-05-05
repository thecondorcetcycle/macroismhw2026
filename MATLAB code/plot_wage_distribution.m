%% Plot offer distribution F(w) and paid-wage distribution G(w)
clear; clc; close all;

%% Parameters
par = set_params();
obj = rwage_objects(par);
target_duration = 13;

%% Solve equilibrium objects
phi_L = 1e-16;
phi_H = 1;
phi_star = fzero(@(phi) calibration_residual(phi, par, obj, target_duration), ...
    [phi_L, phi_H]);

[~, sol] = calibration_residual(phi_star, par, obj, target_duration);
stat = stationary_distribution(phi_star, par, obj, sol);

%% Stationary paid-wage distribution
w_min = min([stat.w_j, stat.w_m, stat.w_s]);
w_max = par.mu + 4 * par.sigma;
w_grid = linspace(w_min, w_max, 500);

G = paid_wage_cdf(w_grid, stat, par, obj);

F = obj.F(w_grid);

%% Plot
fig = figure('Color', 'w', 'InvertHardcopy', 'off');
plot(w_grid, F, 'k--', 'LineWidth', 1.4);
hold on;
plot(w_grid, G, 'Color', [0 0.45 0.74], 'LineWidth', 1.8);
grid on;

ax = gca;
ax.Color = 'w';
ax.XColor = 'k';
ax.YColor = 'k';
ax.GridColor = [0.75, 0.75, 0.75];
ax.MinorGridColor = [0.85, 0.85, 0.85];

xlabel('w');
ylabel('CDF');
ttl = title('Offer and paid-wage distributions');
ttl.Color = 'k';
lgd = legend({'Offer distribution F(w)', ...
    'Paid-wage distribution G(w)'}, ...
    'Location', 'southeast');
lgd.Color = 'w';
lgd.TextColor = 'k';
lgd.EdgeColor = [0.2, 0.2, 0.2];

export_tikz_plot(fig, 'wage_distribution_plot');

function G = paid_wage_cdf(w_grid, stat, par, obj)
    u = [stat.unemp_j, stat.unemp_m, stat.unemp_s];
    n = [stat.n_j, stat.n_m, stat.n_s];

    Gamma = [par.gamma_jj, 1 - par.gamma_jj, 0; ...
             0, par.gamma_mm, 1 - par.gamma_mm; ...
             0, 0, par.gamma_ss];

    P = [stat.p_jj, stat.p_jm, 0; ...
         0, stat.p_mm, stat.p_ms; ...
         0, 0, stat.p_ss];

    D_e = diag(1 - u);
    D_n = diag(n);
    M = (1 - par.delta) * D_e * D_n * Gamma / D_n / D_e;
    K = inv(eye(3) - M);
    employed_mass = n .* (1 - u);

    G = zeros(size(w_grid));

    for idx = 1:numel(w_grid)
        A = [accepted_cdf(w_grid(idx), stat.w_j, obj), ...
             accepted_cdf(w_grid(idx), stat.w_m, obj), 0; ...
             0, accepted_cdf(w_grid(idx), stat.w_m, obj), ...
             accepted_cdf(w_grid(idx), stat.w_s, obj); ...
             0, 0, accepted_cdf(w_grid(idx), stat.w_s, obj)];

        G_vec = u * D_n * (Gamma .* P .* A) / D_n / D_e * K;
        G(idx) = G_vec * employed_mass.' / sum(employed_mass);
    end
end

function val = accepted_cdf(w, w_res, obj)
    if w < w_res
        val = 0;
    else
        val = (obj.F(w) - obj.F(w_res)) ./ (1 - obj.F(w_res));
    end
end
