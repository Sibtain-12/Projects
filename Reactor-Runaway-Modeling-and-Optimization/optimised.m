clc; clear; close all;

% Fixed Parameters
Cao = 3.99;   
Cco = 1.94;    
Cto = 2.09;   
vo  = 6e-5;   
T0  = 355;   
tspan = [0 10000000];   % Simulation time span (sec)

% Optimization Variables: x = [Ca0, Nc0, Nt0]
% Initial guess
x0 = [2.38, 7.76, 7.09];

% Lower and upper bounds for initial charges (adjust as needed)
lb = [1, 2.64, 2.2];
ub = [2.38, 7.76, 7.09];

% Objective function that simulates the reactor, then returns the batch time when Nan >= target.
objective = @(x) batch_time_obj(x, tspan, vo, Cao, Cco, Cto, T0);

% Ensure that the maximum temperature in the reactor does not exceed 405 K.
nonlcon = @(x) temp_constraint(x, tspan, vo, Cao, Cco, Cto, T0);

%
options = optimoptions('fmincon','Display','iter','Algorithm','sqp');
[x_opt, fval] = fmincon(objective, x0, [], [], [], [], lb, ub, nonlcon, options);

fprintf('Optimal initial conditions found:\n');
fprintf('   Ca0 = %.4f\n   Nc0 = %.4f\n   Nt0 = %.4f\n', x_opt(1), x_opt(2), x_opt(3));
fprintf('Minimum batch time: %.2f sec\n', fval);

% (Optional) Plot the reactor profiles for the optimal conditions
y0_opt = [x_opt(1), x_opt(2), x_opt(3), 0, T0];
Vo = ( ((x_opt(2)*84)/750) + ((x_opt(3)*92)/840) ) / (1 - ((x_opt(1)*128)/870));
tspan = [0 fval];
[t_opt, y_opt] = ode45(@(t,y) reactor_odes(t, y, Vo, vo, Cao, Cco, Cto), tspan, y0_opt);

Ca_opt = y_opt(:, 1);
Can_opt = y_opt(:, 4);
T_opt = y_opt(:, 5);

figure;
plot(t_opt, Ca_opt, 'r', 'LineWidth', 2);
hold on;
plot(t_opt, Can_opt, 'b', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Concentrations');
legend('Ca', 'Can', 'Location','Best');
title('Optimal Concentration Profiles');
grid on;

figure;
plot(t_opt, T_opt, 'g', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Temperature (K)');
title('Optimal Temperature Profile');
grid on;

Qgs = zeros(length(t_opt), 1);

for i = 1:length(t_opt)
    Ca_i = Ca_opt(i);           % Ca at time i
    T_i = T_opt(i);             % T at time i
    V_i = Vo + vo * t_opt(i);   % V at time i
    
    k_i = 4.01e3 * exp(-29000 / (8.314 * T_i));
    ra_i = -k_i * Ca_i^2;
    
    Qgs(i) = -ra_i * V_i * 64512;
end

% Plot Qgs
figure;
plot(t_opt, Qgs, 'm', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Q_{gs} (W)');
title('Heat Generation Profile (Qgs)');
grid on;

% --- Objective Function ---
function f = batch_time_obj(x, tspan, vo, Cao, Cco, Cto, T0)
    y0 = [x(1), x(2), x(3), 0, T0];
    Vo = ( ((x(2)*84)/750) + ((x(3)*92)/840) ) / (1 - ((x(1)*128)/870));
    target_Nan = 6.260775;
    options = odeset('Events', @(t,y) event_Can(t,y,Vo,target_Nan));
    [t, y, te, ye, ie] = ode45(@(t,y) reactor_odes(t, y, Vo, vo, Cao, Cco, Cto), tspan, y0, options);

    f = t(end);
end

% --- Nonlinear Constraint Function ---
function [c, ceq] = temp_constraint(x, tspan, vo, Cao, Cco, Cto, T0)
    y0 = [x(1), x(2), x(3), 0, T0];
    Vo = ( ((x(2)*84)/750) + ((x(3)*92)/840) ) / (1 - ((x(1)*128)/870));
    [t, y] = ode45(@(t,y) reactor_odes(t, y, Vo, vo, Cao, Cco, Cto), tspan, y0);
    T = y(:,5);
    % Constraint: maximum temperature - 405 <= 0
    c = max(T) - 405;
    ceq = [];
end

function [value, isterminal, direction] = event_Can(t, y, Vo, target_Nan)
    % y(4) corresponds to Can.
    % The event is triggered when value = 0, i.e., when Nan(Can*V) - target = 0.
    value = y(4)*(Vo + (6e-5)*t) - target_Nan;
    isterminal = 1;
    direction = 1;
end

% --- Reactor ODE Function ---
function dydt = reactor_odes(t, y, Vo, vo, Cao, Cco, Cto)
    % Variables
    Ca = y(1);
    Nc = y(2);
    Nt = y(3);
    Can = y(4);
    T = y(5);
    
    % Explicit Equations
    V = Vo + (vo*t);
    Na = Ca * V;
    Nan = Can * V;
    Fao = Cao * vo;
    Fco = Cco * vo;
    Fto = Cto * vo;
    
    k = 4.01e3 * exp(-29000 / (8.314 * T));
    ra = -k * (Ca^2);
    
    Cpa = 245.75;
    Cpc = 161.30;
    Cpt = 165.60;
    Cpan = 231;
    
    Qgs = -ra * V * 64512;
    Qrs1 = (Fao * Cpa + Fco * Cpc + Fto * Cpt) * (T - 310);
    Qrs2 = 5 * (T - 298);
    Qrs = Qrs1 + Qrs2 + 8.316;
    
    NCp = (Na * Cpa) + (Nc * Cpc) + (Nt * Cpt) + (Nan * Cpan);
    
    % Differential Equations
    dydt(1) = (vo/V) * (Cao - Ca) + ra; % d(Ca)/dt
    dydt(2) = Cco * vo;                 % d(Nc)/dt
    dydt(3) = Cto * vo;                 % d(Nt)/dt
    dydt(4) = -ra - (Can * (vo/V));     % d(Can)/dt
    dydt(5) = (Qgs - Qrs) / NCp;        % d(T)/dt
    
    dydt = dydt(:);
end
