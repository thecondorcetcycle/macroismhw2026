%% Plot calibration residual over phi
clear; clc; close all;

par = set_params();
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
semilogx(phis, Omega, 'Color', [0 0.45 0.74], 'LineWidth', 1.5);
hold on;
yline(0, 'k--', 'LineWidth', 1);
xline(phi_star, '--', 'Color', [0.85 0.33 0.10], 'LineWidth', 1);
plot(phi_star, Omega_star, 'o', 'Color', [0.85 0.33 0.10], ...
    'MarkerFaceColor', [0.85 0.33 0.10]);
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
lgd = legend({'\Omega(\phi)', 'Zero line', '\phi^*'}, 'Location', 'northwest');
lgd.Color = 'w';
lgd.TextColor = 'k';
lgd.EdgeColor = [0.2, 0.2, 0.2];

export_tikz_plot(fig, 'calibration_residual_plot');
