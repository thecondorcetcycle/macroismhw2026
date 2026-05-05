function [Omega, sol] = calibration_residual(phi, par, obj, target_duration)

    % Setting default value of target
    if nargin < 4
        target_duration = 13;
    end

    %% Solve reservation wages and search efforts

    [w_s, a_s] = solve_ws(phi, par, obj);
    [w_m, a_m] = solve_wm(phi, par, obj, w_s);

    %% Exit probability from middle-aged unemployment
    % The middle-aged unemployment spell ends either when the worker finds
    % an acceptable job while remaining middle-aged or when the worker ages
    % out of the middle-aged cohort.

    p_mm = obj.pi(a_m, phi) * (1 - obj.F(w_m));
    q_m = par.gamma_mm * p_mm + (1 - par.gamma_mm);

    %% Implied duration and residual

    duration_m = 1 / q_m;

    Omega = duration_m - target_duration;

    if nargout > 1
        sol.phi = phi;
        sol.w_s = w_s;
        sol.a_s = a_s;
        sol.w_m = w_m;
        sol.a_m = a_m;
        sol.p_mm = p_mm;
        sol.q_m = q_m;
        sol.duration_m = duration_m;
        sol.target_duration = target_duration;
        sol.Omega = Omega;
    end

end
