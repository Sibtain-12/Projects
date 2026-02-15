clc; clear; close all;

% Initial Conditions
Cao = 2.22;
Cco = 3.52;
Cto = 2.92;
Nc0 = 2.64;
Nt0 = 2.2;
Ca0 = 2.12;
Vo = 0.73;
vo = 0.00015;
T0 = 355;

% Time span
tspan = [0 3000];

% Initial values [Ca0, Nc0, Nt0, Can0, T0]
y0 = [Ca0, Nc0, Nt0, 0, T0];

% Solve ODEs
[t, y] = ode45(@(t, y) reactor_odes(t, y, Vo, vo, Cao, Cco, Cto), tspan, y0);

% Results
Ca = y(:, 1);
Can = y(:, 4);
T = y(:, 5);

% Plot results
figure;
plot(t, Ca, 'r', 'LineWidth', 2);
hold on;
plot(t, Can, 'b', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Concentrations');
legend('Ca', 'Can');
title('Concentration Profiles');
grid on;

figure;
plot(t, T, 'g', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Temperature (K)');
title('Temperature Profile');
grid on;

% Compute Qgs over time
Qgs = zeros(length(t), 1);

for i = 1:length(t)
    Ca_i = Ca(i);           % Ca at time i
    T_i = T(i);             % T at time i
    V_i = Vo + vo * t(i);   % V at time i
    
    k_i = 4.01e3 * exp(-29000 / (8.314 * T_i));
    ra_i = -k_i * Ca_i^2;
    
    Qgs(i) = -ra_i * V_i * 64512;
end

% Plot Qgs
figure;
plot(t, Qgs, 'm', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Q_{gs} (W)');
title('Heat Generation Profile (Qgs)');
grid on;


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
    Qrs1 = (Fao*Cpa + Fco*Cpc + Fto*Cpt) * (T - 310);
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
