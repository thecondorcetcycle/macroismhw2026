%% Plot offer distribution F(w) and accepted-wage distribution G(w)
clear; clc; close all;

%% Parameters
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

obj = rwage_objects(par);
target_duration = 13;

%% Solve equilibrium objects
phi_L = 1e-16;
phi_H = 1;
phi_star = fzero(@(phi) calibration_residual(phi, par, obj, target_duration), ...
    [phi_L, phi_H]);

[~, sol] = calibration_residual(phi_star, par, obj, target_duration);
stat = stationary_distribution(phi_star, par, obj, sol);

%% Cohort-specific accepted-wage distributions
w_min = min([stat.w_j, stat.w_m, stat.w_s]);
w_max = par.mu + 4 * par.sigma;
w_grid = linspace(w_min, w_max, 500);

G_j = accepted_cdf(w_grid, stat.w_j, obj);
G_m = accepted_cdf(w_grid, stat.w_m, obj);
G_s = accepted_cdf(w_grid, stat.w_s, obj);

weight_j = stat.e_j / stat.total_employment;
weight_m = stat.e_m / stat.total_employment;
weight_s = stat.e_s / stat.total_employment;

G = weight_j .* G_j + weight_m .* G_m + weight_s .* G_s;
F = obj.F(w_grid);

%% Plot
fig = figure('Color', 'w', 'InvertHardcopy', 'off');
plot(w_grid, F, 'k--', 'LineWidth', 1.4);
hold on;
plot(w_grid, G, 'b-', 'LineWidth', 1.8);
grid on;

ax = gca;
ax.Color = 'w';
ax.XColor = 'k';
ax.YColor = 'k';
ax.GridColor = [0.75, 0.75, 0.75];
ax.MinorGridColor = [0.85, 0.85, 0.85];

xlabel('w');
ylabel('CDF');
ttl = title('Offer and accepted-wage distributions');
ttl.Color = 'k';
lgd = legend({'Offer distribution F(w)', 'Accepted-wage distribution G(w)'}, ...
    'Location', 'southeast');
lgd.Color = 'w';
lgd.TextColor = 'k';
lgd.EdgeColor = [0.2, 0.2, 0.2];

set(fig, 'PaperPositionMode', 'auto');
print(fig, 'wage_distribution_plot.png', '-dpng', '-r300');

function G = accepted_cdf(w, w_res, obj)
    G = zeros(size(w));
    idx = w >= w_res;
    G(idx) = (obj.F(w(idx)) - obj.F(w_res)) ./ (1 - obj.F(w_res));
end
