%% housekeeping
clear; clc; close all;

% Plot-export scripts use matlab2tikz; see export_tikz_plot.m for setup.

%% setting parameters and reusable objects
par = set_params();
obj = rwage_objects(par);
target_duration = 13;

%% solving for calibrated phi
phi_L = 1e-16;
phi_H = 1;

Omega_L = calibration_residual(phi_L, par, obj, target_duration);
Omega_H = calibration_residual(phi_H, par, obj, target_duration);

fprintf('Omega_L = %.6f\n', Omega_L);
fprintf('Omega_H = %.6f\n', Omega_H);

phi_star = fzero(@(phi) calibration_residual(phi, par, obj, target_duration), ...
    [phi_L, phi_H]);

%% collecting equilibrium objects at calibrated phi
[~, sol] = calibration_residual(phi_star, par, obj, target_duration);
stat = stationary_distribution(phi_star, par, obj, sol);

%% displaying result
fprintf('Calibrated phi: %.15f\n', phi_star);
fprintf('Middle-age unemployment duration: %.6f\n', sol.duration_m);
fprintf('Young reservation wage: %.6f\n', stat.w_j);
fprintf('Young search effort: %.6f\n', stat.a_j);
fprintf('Middle-age reservation wage: %.6f\n', sol.w_m);
fprintf('Middle-age search effort: %.6f\n', sol.a_m);
fprintf('Senior reservation wage: %.6f\n', sol.w_s);
fprintf('Senior search effort: %.6f\n', sol.a_s);
fprintf('Young employment share: %.6f\n', stat.emp_j);
fprintf('Young unemployment share: %.6f\n', stat.unemp_j);
fprintf('Middle-age employment share: %.6f\n', stat.emp_m);
fprintf('Middle-age unemployment share: %.6f\n', stat.unemp_m);
fprintf('Senior employment share: %.6f\n', stat.emp_s);
fprintf('Senior unemployment share: %.6f\n', stat.unemp_s);
fprintf('Young unemployment share of total population: %.6f\n', stat.u_j);
fprintf('Middle-age unemployment share of total population: %.6f\n', stat.u_m);
fprintf('Senior unemployment share of total population: %.6f\n', stat.u_s);
fprintf('Aggregate employment share: %.6f\n', stat.total_employment);
fprintf('Aggregate unemployment share: %.6f\n', stat.total_unemployment);

%% saving workspace/results
save('results_workspace.mat');
