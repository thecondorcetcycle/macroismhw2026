%% Plot calibration residual over phi
clear; clc; close all;

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

phi_L = 1e-16;
phi_H = 1;
phi_star = fzero(@(phi) calibration_residual(phi, par, obj, target_duration), ...
    [phi_L, phi_H]);

phis = logspace(-8, 2, 100);
Omega = nan(size(phis));

for i = 1:numel(phis)
    try
        Omega(i) = calibration_residual(phis(i), par, obj, target_duration);
    catch
        Omega(i) = nan;
    end
end

Omega_star = calibration_residual(phi_star, par, obj, target_duration);

fig = figure('Color', 'w', 'InvertHardcopy', 'off');
semilogx(phis, Omega, 'LineWidth', 1.5);
hold on;
yline(0, 'k--', 'LineWidth', 1);
xline(phi_star, 'r--', 'LineWidth', 1);
plot(phi_star, Omega_star, 'ro', 'MarkerFaceColor', 'r');
grid on;

ax = gca;
ax.Color = 'w';
ax.XColor = 'k';
ax.YColor = 'k';
ax.GridColor = [0.75, 0.75, 0.75];
ax.MinorGridColor = [0.85, 0.85, 0.85];

xlabel('\phi');
ylabel('\Omega(\phi)');
ttl = title('Calibration residual');
ttl.Color = 'k';
lgd = legend({'\Omega(\phi)', 'Zero line', '\phi^*'}, 'Location', 'best');
lgd.Color = 'w';
lgd.TextColor = 'k';
lgd.EdgeColor = [0.2, 0.2, 0.2];

set(fig, 'PaperPositionMode', 'auto');
print(fig, 'calibration_residual_plot.png', '-dpng', '-r300');
