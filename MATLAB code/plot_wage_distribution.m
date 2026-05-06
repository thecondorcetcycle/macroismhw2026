%% Plot offer distribution F(w) and paid-wage distribution G(w)
clear; clc; close all;

%% Parameters
par = set_params();
obj = rwage_objects(par);
target_duration = 13;
axis_font_size = 12;
label_font_size = 14;
legend_font_size = 11;

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

G_by_age = paid_wage_cdf_by_age(w_grid, stat, par, obj);
employed_mass = [stat.n_j * (1 - stat.unemp_j), ...
                 stat.n_m * (1 - stat.unemp_m), ...
                 stat.n_s * (1 - stat.unemp_s)];
G = G_by_age * employed_mass.' / sum(employed_mass);

F = obj.F(w_grid);

%% Plot offer distribution and aggregate paid-wage distribution
fig = figure('Color', 'w', 'InvertHardcopy', 'off', ...
    'Units', 'pixels', 'Position', [100, 100, 560, 360]);
plot(w_grid, F, 'k--', 'LineWidth', 1.4);
hold on;
plot(w_grid, G, 'Color', [0 0.45 0.74], 'LineWidth', 1.8);
grid on;
xlim([50 200]);
ylim([0 1]);
xticks(60:20:200);
yticks(0:0.2:1);

ax = gca;
ax.Color = 'w';
ax.XColor = 'k';
ax.YColor = 'k';
ax.GridColor = [0.75, 0.75, 0.75];
ax.MinorGridColor = [0.85, 0.85, 0.85];
ax.FontSize = axis_font_size;
ax.FontName = 'Times New Roman';
ax.LineWidth = 1;
ax.Box = 'on';
ax.TickDir = 'in';
ax.XMinorTick = 'off';
ax.YMinorTick = 'off';

xlabel('w', 'FontSize', label_font_size, 'FontName', 'Times New Roman');
ylabel('CDF', 'FontSize', label_font_size, 'FontName', 'Times New Roman');
lgd = legend({'Offer distribution F(w)', ...
    'Paid-wage distribution G(w)'}, ...
    'Location', 'southeast');
lgd.Color = 'w';
lgd.TextColor = 'k';
lgd.EdgeColor = [0.2, 0.2, 0.2];
lgd.FontSize = legend_font_size;
lgd.FontName = 'Times New Roman';

root_dir = fileparts(fileparts(mfilename('fullpath')));
pdf_original_path = fullfile(root_dir, 'wage_distribution_plot.pdf');
exportgraphics(fig, pdf_original_path, 'ContentType', 'vector');

%% Plot cumulative paid-wage distribution by age cohort
fig_age = figure('Color', 'w', 'InvertHardcopy', 'off');
plot(w_grid, G_by_age(:, 1), 'Color', [0 0.45 0.74], 'LineWidth', 1.8);
hold on;
plot(w_grid, G_by_age(:, 2), 'Color', [0.85 0.33 0.10], 'LineWidth', 1.8);
plot(w_grid, G_by_age(:, 3), 'Color', [0.47 0.67 0.19], 'LineWidth', 1.8);
grid on;
ylim([0 1]);

ax = gca;
ax.Color = 'w';
ax.XColor = 'k';
ax.YColor = 'k';
ax.GridColor = [0.75, 0.75, 0.75];
ax.MinorGridColor = [0.85, 0.85, 0.85];
ax.FontSize = axis_font_size;

xlabel('w', 'FontSize', label_font_size);
ylabel('CDF', 'FontSize', label_font_size);
lgd = legend({'Young', 'Middle-aged', 'Old'}, ...
    'Location', 'southeast');
lgd.Color = 'w';
lgd.TextColor = 'k';
lgd.EdgeColor = [0.2, 0.2, 0.2];
lgd.FontSize = legend_font_size;

pdf_path = fullfile(root_dir, 'cumulative_wage_distribution_by_age.pdf');
exportgraphics(fig_age, pdf_path, 'ContentType', 'vector');

%% Plot cumulative paid-wage distribution by age cohort, zoomed in
fig_age_zoom = figure('Color', 'w', 'InvertHardcopy', 'off');
plot(w_grid, G_by_age(:, 1), 'Color', [0 0.45 0.74], 'LineWidth', 1.8);
hold on;
plot(w_grid, G_by_age(:, 2), 'Color', [0.85 0.33 0.10], 'LineWidth', 1.8);
plot(w_grid, G_by_age(:, 3), 'Color', [0.47 0.67 0.19], 'LineWidth', 1.8);
grid on;
xlim([50 60]);
zoom_idx = w_grid >= 50 & w_grid <= 60;
zoom_y = G_by_age(zoom_idx, :);
zoom_y_min = min(zoom_y, [], 'all');
zoom_y_max = max(zoom_y, [], 'all');
zoom_y_pad = 0.05 * max(zoom_y_max - zoom_y_min, eps);
ylim([max(0, zoom_y_min - zoom_y_pad), min(1, zoom_y_max + zoom_y_pad)]);

ax = gca;
ax.Color = 'w';
ax.XColor = 'k';
ax.YColor = 'k';
ax.GridColor = [0.75, 0.75, 0.75];
ax.MinorGridColor = [0.85, 0.85, 0.85];
ax.FontSize = axis_font_size;

xlabel('w', 'FontSize', label_font_size);
ylabel('CDF', 'FontSize', label_font_size);
lgd = legend({'Young', 'Middle-aged', 'Old'}, ...
    'Location', 'southeast');
lgd.Color = 'w';
lgd.TextColor = 'k';
lgd.EdgeColor = [0.2, 0.2, 0.2];
lgd.FontSize = legend_font_size;

pdf_zoom_path = fullfile(root_dir, 'cumulative_wage_distribution_by_age_zoom_50_60.pdf');
exportgraphics(fig_age_zoom, pdf_zoom_path, 'ContentType', 'vector');

%% Plot aggregate paid-wage distribution, zoomed in
fig_agg_zoom = figure('Color', 'w', 'InvertHardcopy', 'off');
plot(w_grid, G, 'Color', [0 0.45 0.74], 'LineWidth', 1.8);
grid on;
xlim([50 60]);
zoom_G = G(zoom_idx);
zoom_G_min = min(zoom_G);
zoom_G_max = max(zoom_G);
zoom_G_pad = 0.05 * max(zoom_G_max - zoom_G_min, eps);
ylim([max(0, zoom_G_min - zoom_G_pad), min(1, zoom_G_max + zoom_G_pad)]);

ax = gca;
ax.Color = 'w';
ax.XColor = 'k';
ax.YColor = 'k';
ax.GridColor = [0.75, 0.75, 0.75];
ax.MinorGridColor = [0.85, 0.85, 0.85];
ax.FontSize = axis_font_size;

xlabel('w', 'FontSize', label_font_size);
ylabel('CDF', 'FontSize', label_font_size);

pdf_agg_zoom_path = fullfile(root_dir, 'cumulative_wage_distribution_zoom_50_60.pdf');
exportgraphics(fig_agg_zoom, pdf_agg_zoom_path, 'ContentType', 'vector');

%% Plot aggregate paid-wage distribution, zoomed in further
fig_agg_zoom_50_55 = figure('Color', 'w', 'InvertHardcopy', 'off');
plot(w_grid, G, 'Color', [0 0.45 0.74], 'LineWidth', 1.8);
grid on;
xlim([50 55]);
zoom_50_55_idx = w_grid >= 50 & w_grid <= 55;
zoom_G_50_55 = G(zoom_50_55_idx);
zoom_G_50_55_min = min(zoom_G_50_55);
zoom_G_50_55_max = max(zoom_G_50_55);
zoom_G_50_55_pad = 0.05 * max(zoom_G_50_55_max - zoom_G_50_55_min, eps);
ylim([max(0, zoom_G_50_55_min - zoom_G_50_55_pad), ...
      min(1, zoom_G_50_55_max + zoom_G_50_55_pad)]);

ax = gca;
ax.Color = 'w';
ax.XColor = 'k';
ax.YColor = 'k';
ax.GridColor = [0.75, 0.75, 0.75];
ax.MinorGridColor = [0.85, 0.85, 0.85];
ax.FontSize = axis_font_size;

xlabel('w', 'FontSize', label_font_size);
ylabel('CDF', 'FontSize', label_font_size);

pdf_agg_zoom_50_55_path = fullfile(root_dir, 'cumulative_wage_distribution_zoom_50_55.pdf');
exportgraphics(fig_agg_zoom_50_55, pdf_agg_zoom_50_55_path, 'ContentType', 'vector');

try
    export_tikz_plot(fig, 'wage_distribution_plot');
catch ME
    warning('plot_wage_distribution:tikzExportSkipped', ...
        'Skipping TikZ export: %s', ME.message);
end

function G_by_age = paid_wage_cdf_by_age(w_grid, stat, par, obj)
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

    G_by_age = zeros(numel(w_grid), 3);

    for idx = 1:numel(w_grid)
        A = [accepted_cdf(w_grid(idx), stat.w_j, obj), ...
             accepted_cdf(w_grid(idx), stat.w_m, obj), 0; ...
             0, accepted_cdf(w_grid(idx), stat.w_m, obj), ...
             accepted_cdf(w_grid(idx), stat.w_s, obj); ...
             0, 0, accepted_cdf(w_grid(idx), stat.w_s, obj)];

        G_vec = u * D_n * (Gamma .* P .* A) / D_n / D_e * K;
        G_by_age(idx, :) = G_vec;
    end
end

function val = accepted_cdf(w, w_res, obj)
    if w < w_res
        val = 0;
    else
        val = (obj.F(w) - obj.F(w_res)) ./ (1 - obj.F(w_res));
    end
end
