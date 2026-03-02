clc; clear; close all;

% Constants & fixed parameters
% Kinetics
A1  = 2.8e7;    Ea1 = 104174;       % A→C
A2  = 2.32e9;   Ea2 = 146742;       % A→D
R   = 8.314;                        % J/(mol·K)
dH1 = -117000; dH2 = -157000;       % J/kmol
Cp  = 650;                          % J/(kmol·K)

% Reactor
V_end = 10;                         % m^3
v     = 9.6;                        % m^3/h  (volumetric flow)

% Original feed (to get total feed for ratio)
FA0_orig = 12.4919976 + 105.2237556;  % kmol/h
FB0_orig = 183.2470831;               % kmol/h
Ftot     = FA0_orig + FB0_orig;       % kmol/h

% x(1) = r = FA0/FB0,   x(2) = T_in [K]
r0  = FA0_orig/FB0_orig;
T0  = 345 + 273.15;                   % initial inlet T
x0  = [r0; T0];

lb = [0.1; 300+273.15];     % r>=0.1, T>=300°C
ub = [5;   450+273.15];     % r<=5,   T<=450°C

opts = optimoptions('fmincon', 'Display','iter','TolFun',1e-6,'TolX',1e-6);

% Objective function
obj = @(x) obj_feed_temp(x, A1,Ea1, A2,Ea2, R, dH1,dH2, Cp, Ftot, V_end, v);

[xopt, Jopt] = fmincon(obj, x0, [],[],[],[], lb, ub, [], opts);

r_opt  = xopt(1);
Topt   = xopt(2);
FA0_opt = r_opt/(1+r_opt) * Ftot;
FB0_opt = 1/(1+r_opt) * Ftot;

fprintf('\nOptimal feed ratio FA0/FB0 = %.3f\n', r_opt);
fprintf('  → FA0 = %.4f kmol/h, FB0 = %.4f kmol/h\n', FA0_opt, FB0_opt);
fprintf('Optimal inlet T = %.2f °C\n', Topt - 273.15);
fprintf('Objective J (FD–FC) = %.4f kmol/h\n\n', Jopt);


optsODE = odeset('RelTol',1e-6,'AbsTol',1e-8);
[V,F] = ode15s(@(V,F) reaction_odes(V, F, A1,Ea1, A2,Ea2, R, dH1,dH2, Cp, v), [0 V_end], [FA0_opt; FB0_opt; 0; 0; Topt], optsODE);

FA = F(end, 1);
FB = F(end, 2);
FC_end = F(end,3);
FD_end = F(end,4);
T_end = F(end, 5) - 273.15;
fprintf("Oultle Mole Flows:\n");
fprintf('→ Propylen+Propane (FA) = %.4f kmol/h\n', FA);
fprintf('→ Benzene  (FD) = %.4f kmol/h\n', FB);
fprintf('→ Cumene : FC = %.4f kmol/h\n', FC_end);
fprintf('→ DIPB  : FD = %.4f kmol/h\n', FD_end);
fprintf('→ Temperature at end   (T) = %.4f deg C\n\n', T_end);

% Plot profiles
figure;
plot(V, F(:,1), 'LineWidth',1.5, 'DisplayName','Propylene (A)');
hold on;
plot(V, F(:,2), 'LineWidth',1.5, 'DisplayName','Benzene (B)');
hold on;
plot(V, F(:,3), 'LineWidth',1.5, 'DisplayName','Cumene (C)');
hold on;
plot(V, F(:,4), 'LineWidth',1.5, 'DisplayName','DIPB (D)');
xlabel('Reactor Volume (m^3)');
ylabel('Molar Flow (kmol/h)');
title('Profiles at Optimal Feed & Temperature');
legend; grid on;

figure;
plot(V, F(:,5)-273.15, 'r-', 'LineWidth', 2);
xlabel('Reactor Volume V (m^3)');
ylabel('Temperature (°C)');
title('Optimal Temperature Profile Along Reactor');
grid on;


% Objective function
function J = obj_feed_temp(x, A1,Ea1, A2,Ea2, R, dH1,dH2, Cp, Ftot, V_end, v)
    r    = x(1);
    T_in = x(2);

    FA0 = r/(1+r) * Ftot;
    FB0 = 1/(1+r) * Ftot;

    optsODE = odeset('RelTol',1e-6,'AbsTol',1e-8);
    [~,F] = ode15s(@(V,F) reaction_odes(V, F, A1,Ea1, A2,Ea2, R, dH1,dH2, Cp, v), [0 V_end], [FA0; FB0; 0; 0; T_in], optsODE);
    FC_end = F(end,3);
    FD_end = F(end,4);

    % Objective: minimize FD - FC
    J = FD_end - FC_end;
end

% Reactor ODEs
function dF_dV = reaction_odes(~, F, A1,Ea1, A2,Ea2, R, dH1,dH2, Cp, v)
    FA = F(1); FB = F(2); FC = F(3); FD = F(4); T = F(5);
    k1 = A1 * exp(-Ea1/(R*T));
    k2 = A2 * exp(-Ea2/(R*T));
    CA = FA / v; CB = FB / v; CC = FC / v;
    r1 = k1 * CA * CB;    % A + B → C
    r2 = k2 * CA * CC;    % A + C → D
    dFA = - (r1 + r2);
    dFB = - r1;
    dFC =   r1 - r2;
    dFD =         r2;
    dT  = (-dH1*r1 - dH2*r2) / ((FA+FB+FC+FD) * Cp);
    dF_dV = [dFA; dFB; dFC; dFD; dT];
end
