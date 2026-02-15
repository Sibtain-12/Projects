clc; clear; close all;

A1 = 2.8e7;
Ea1 = 104174;   % kJ/kmol

A2 = 2.32e9; 
Ea2 = 146742; 

R = 8.314;

dH1 = -117000;   % kJ/kmol
dH2 = -157000;   % kJ/kmol

Cp = 650;

T_in = 345 + 273.15;  % kelvin

FA0 = 12.4919976+105.2237556;      % (kmol/h)
FB0 = 183.2470831;      
FC0 = 0;
FD0 = 0;

F0 = [FA0; FB0; FC0; FD0; T_in];

Vspan = [0 10];  % cubic meter

options = odeset('RelTol',1e-6, 'AbsTol',1e-8);
[V, F] = ode15s(@(V, F) reaction_odes(V, F, A1, Ea1, A2, Ea2, R, dH1, dH2, Cp), Vspan, F0, options);


FA = F(:,1);
FB = F(:,2);
FC = F(:,3);
FD = F(:,4);
T = F(:,5) - 273.15;
fprintf("PFR mass and energy balance\n");
fprintf("FA (Propylene) = %.4f kmol/h\n", FA(end));
fprintf("FB (Benzene) = %.4f kmol/h\n", FB(end));
fprintf("FC (Cumene) = %.4f kmol/h\n", FC(end));
fprintf("FD (DIPB) = %.8f kmol/h\n", FD(end));
fprintf("T_end = %.4f deg C\n", T(end));
fprintf("------------------------------------------------------------------------------------------\n")

figure;
plot(V, FA, 'LineWidth', 1.5, 'DisplayName', 'F_A (Propylene)');
hold on;
plot(V, FB , 'LineWidth', 1.5, 'DisplayName', 'F_B (Benzene)');
plot(V, FC , 'LineWidth', 1.5, 'DisplayName', 'F_C (Cumene)');
plot(V, FD , 'LineWidth', 1.5, 'DisplayName', 'F_D (DIPB)');
xlabel('Reactor Volume V (m^3)');
ylabel('Molar Flow Rate (kmol/h)');
title('Molar Flow Rate Profiles in Reactor');
legend;
grid on;

figure;
plot(V, T, 'r-', 'LineWidth', 2);
xlabel('Reactor Volume V (m^3)');
ylabel('Temperature (°C)');
title('Temperature Profile Along Reactor');
grid on;

% Flash
% Assuming that all the propane + propylene (i.e., A) are converted into vapor in flash since its low boiling point
% and all other component are in bottom liquid product (i.e., B, C and D)
% No reaction happen
% temp = 90 degC, Pressure = 1.75 bar

top_product = FA(end);
bottom_product = FB(end) + FC(end) + FD(end);

fprintf("Flash Mass balance\n\n");
fprintf("Mole flows in top product (Propane+Propylene) = %.4f kmol/h\n", top_product);
fprintf("Mole flows in bottom product (Benzene+Cumene+DIPB) = %.4f kmol/h\n", bottom_product);
fprintf("------------------------------------------------------------------------------------------\n")

% For 1st distillation
feed_components = {             
    'BENZENE',      FB(end);        % kmol/h
    'PROPANE',       0;
    'PROPYLENE',      0;
    'CUMENE',     FC(end);
    'DIPB',      FD(end);
};
F_total = FB(end)+FC(end)+FD(end);

F_benzene = feed_components{1,2};
F_cumene = feed_components{4,2};
F_DIPB = feed_components{5,2};

% Benzene: 99.9% to distillate
D_benzene = 0.999 * F_benzene;
B_benzene = F_benzene - D_benzene;

% Cumene: 99.9% to bottoms
B_cumene = 0.999 * F_cumene;
D_cumene = F_cumene - B_cumene;

% DIPB: 0% to distillate (all to bottoms)
D_DIPB = 0;
B_DIPB = F_DIPB;

% Total Distillate (D) and Bottoms (B)
D_total = D_benzene + D_cumene;
B_total = B_benzene + B_cumene + B_DIPB;

fprintf("Mass balance on 1st Distillation column (C1)\n")

% Mole Flows in Distillate
fprintf('\nMole flows in Distillate:\n');
fprintf('BENZENE:    %.6f kmol/h\n', D_benzene);
fprintf('CUMENE:   %.6f kmol/h\n', D_cumene);
fprintf('DIPB:   %.6f kmol/h\n', D_DIPB);

% Mole Flows in Bottom
fprintf('\nMole flows in Bottom:\n');
fprintf('BENZENE:    %.6f kmol/h\n', B_benzene);
fprintf('CUMENE:   %.6f kmol/h\n', B_cumene);
fprintf('DIPB:   %.6f kmol/h\n', B_DIPB);

% Mole Fractions in Distillate
fprintf('\nDistillate Mole Fractions:\n');
fprintf('BENZENE:    %.6f\n', D_benzene/D_total);
fprintf('CUMENE:   %.6f\n', D_cumene/D_total);
fprintf('DIPB:   %.6f\n', D_DIPB/D_total);

% Mole Fractions in Bottom
fprintf('\nBottom Mole Fractions:\n');
fprintf('BENZENE:    %.6f\n', B_benzene/B_total);
fprintf('CUMENE:   %.6f\n', B_cumene/B_total);
fprintf('DIPB:   %.6f\n', B_DIPB/B_total);

% Energy Balance
molar_enthalpy_feed = 1201.943296;      % cal/mol
molar_enthalpy_distillate = 8755.60461; % cal/mol
molar_enthalpy_bottoms = -1523.113939;  % cal/mol

% Convert flows to mol/s
D_mol_s = D_total * 1000 / 3600;
B_mol_s = B_total * 1000 / 3600;

% Enthalpy flows
H_distillate = D_mol_s * molar_enthalpy_distillate;
H_bottoms = B_mol_s * molar_enthalpy_bottoms;
H_feed = F_total * 1000 / 3600 * molar_enthalpy_feed;

% Energy balance equation: Q_reboiler - Q_condenser = H_distillate + H_bottoms - H_feed
Q_relation = H_distillate + H_bottoms - H_feed;
fprintf('\nEnergy Balance:\nQ_reboiler - Q_condenser = %.2f cal/s\n', Q_relation);

fprintf("------------------------------------------------------------------------------------------\n")

% For 2nd Distillation

F_benzene_2 = B_benzene;
F_cumene_2 = B_cumene;
F_DIPB_2 = B_DIPB;

% D_cumene 99.9% to distillate
D_cumene_2 = 0.999 * F_cumene_2;
B_cumene_2 = F_cumene_2 - D_cumene_2;

% B_DIPB: 99.9% to bottoms
B_DIPB_2 = 0.999 * F_DIPB_2;
D_DIPB_2 = F_DIPB_2 - B_DIPB_2;

% all benzene in the distillate
D_benzene_2 = F_benzene_2;

% Total Distillate (D) and Bottoms (B)
D_total_2 = D_benzene_2 + D_cumene_2 + D_DIPB_2;
B_total_2 = B_cumene_2 + B_DIPB_2;

fprintf("Mass balance on 2nd Distillation column (C2)\n")

% Mole Flows in Distillate
fprintf('\nMole flows in Distillate:\n');
fprintf('BENZENE:    %.6f kmol/h\n', D_benzene_2);
fprintf('CUMENE:   %.6f kmol/h\n', D_cumene_2);
fprintf('DIPB:   %.6f kmol/h\n', D_DIPB_2);

% Mole Flows in Bottom
fprintf('\nMole flows in Bottom:\n');
fprintf('CUMENE:   %.6f kmol/h\n', B_cumene_2);
fprintf('DIPB:   %.6f kmol/h\n', B_DIPB_2);

% Mole Fractions in Distillate
fprintf('\nDistillate Mole Fractions:\n');
fprintf('BENZENE:    %.6f\n', D_benzene_2/D_total_2);
fprintf('CUMENE:   %.6f\n', D_cumene_2/D_total_2);
fprintf('DIPB:   %.6f\n', D_DIPB_2/D_total_2);

% Mole Fractions in Bottom
fprintf('\nBottom Mole Fractions:\n');
fprintf('CUMENE:   %.6f\n', B_cumene_2/B_total_2);
fprintf('DIPB:   %.6f\n', B_DIPB_2/B_total_2);

fprintf("------------------------------------------------------------------------------------------\n")


function dF_dV = reaction_odes(V, F, A1, Ea1, A2, Ea2, R, dH1, dH2, Cp)
    FA = F(1);
    FB = F(2);
    FC = F(3);
    FD = F(4);
    T = F(5); 

    k1 = A1 * exp(-Ea1 / (R * T));
    k2 = A2 * exp(-Ea2 / (R * T));

    v = 9.6;
    
    CA = FA / v;
    CB = FB / v;
    CC = FC / v;
    
    r1 = k1 * CA * CB;
    r2 = k2 * CA * CC;  

    dFA_dV = - (r1 + r2);
    dFB_dV = - r1;
    dFC_dV = r1 - r2;
    dFD_dV = r2;
    dT_dV = (-dH1 * r1 - dH2 * r2) / ((FA + FB + FC + FD) * Cp);
    

    dF_dV = [dFA_dV; dFB_dV; dFC_dV; dFD_dV; dT_dV];
end
