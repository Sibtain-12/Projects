clc;
clear all;

%% Constants
Pb_range = linspace(12E+6, 15E+6, 30);      % Range of boiler pressures from 12 MPa to 15 MPa
Pc_range = linspace(5E+3, 10E+3, 30);       % Range of condenser pressures from 5 kPa to 10 kPa

%% Initialize arrays to store results
efficiency_results = zeros(length(Pc_range), length(Pb_range));
Wnet_results = zeros(length(Pc_range), length(Pb_range));

%% Loop through different values of Pb and Pc
for i = 1:length(Pb_range)
    for j = 1:length(Pc_range)
        % Set boiler and condenser pressures
        P6 = Pb_range(i);
        P3 = Pc_range(j);

        % Call the existing code to calculate efficiency and quality (x)
        [efficiency, Wnet] = calculate_cycle_performance(P6, P3);

        % Store results in arrays
        efficiency_results(j, i) = efficiency;
        Wnet_results(j, i) = Wnet;
    end
end

%% Create plots
figure;

% Plot for thermal efficiency
contourf(Pc_range, Pb_range, efficiency_results', 20, 'LineColor', 'none');
colorbar;
xlabel('Condenser Pressure (Pa)');
ylabel('Boiler Pressure (Pa)');
%title('Effect of Boiler and Condenser Pressures on Thermal Efficiency');

figure;
% Plot for net Work output (Wnet)
contourf(Pc_range, Pb_range, Wnet_results', 20, 'LineColor', 'none');
colorbar;
xlabel('Condenser Pressure (Pa)');
ylabel('Boiler Pressure (Pa)');
%title('Effect of Boiler and Condenser Pressures on net Work output (Wnet)');

%% Define a function to calculate cycle performance
function [efficiency, Wnet] = calculate_cycle_performance(P6, P3)
    h = Solution('liquidvapor.cti','water');

    %% State 3
    setState_Psat(h,[P3,0]);
    h3 = enthalpy_mass(h);
    s3 = entropy_mass(h);
    
    %% State 4
    P4 = 0.8E+6;                           % Vary
    s4 = s3;
    setState_SP(h,[s4,P4]);
    h4 = enthalpy_mass(h);
    
    %% State 5
    P5 = P4;
    setState_Psat(h,[P5,0]);
    h5 = enthalpy_mass(h);
    s5 = entropy_mass(h);
    
    %% State 6
    s6 = s5;
    setState_SP(h,[s6,P6]);
    h6 = enthalpy_mass(h);
    
    %% State 7
    P7 = P6;
    setState_Psat(h,[P7,0]);
    h7 = enthalpy_mass(h);
    
    %% State 8
    P8 = P6;
    setState_Psat(h,[P8,1]);
    h8 = enthalpy_mass(h);
    
    %% State 9
    P9 = P6;
    T9 = 500+273.15;
    set(h,'P',P9,'T',T9);
    h9 = enthalpy_mass(h);
    s9 = entropy_mass(h);
    
    %% State 10
    P10 = 7E+6;                               % vary
    s10 = s9;
    setState_SP(h,[s10,P10]);
    h10 = enthalpy_mass(h);
    
    %% State 11
    P11 = P10;
    T11 = 500+273.15;
    set(h,'P',P11,'T',T11);
    h11 = enthalpy_mass(h);
    s11 = entropy_mass(h);
    
    %% State 12
    P12 = 3E+6;                                % vary
    s12 = s11;
    setState_SP(h,[s12,P12]);
    h12 = enthalpy_mass(h);
    
    %% State 1
    P1 = P12;
    T1 = 500+273.15;  
    set(h,'P',P1,'T',T1);
    h1 = enthalpy_mass(h);
    s1 = entropy_mass(h);
    
    %% State 1_
    P1_ = P4;
    s1_ = s1;
    setState_SP(h,[s1_,P1_]);
    h1_ = enthalpy_mass(h);
    
    %% State 2
    P2 = P3;
    s2 = s1;
    setState_SP(h,[s2,P2]);
    h2 = enthalpy_mass(h);
    
    setState_Psat(h,[P2,0]);
    hf = enthalpy_mass(h);
    
    setState_Psat(h,[P2,1]);
    hg = enthalpy_mass(h);
    
    hfg = hg-hf;
    
    x = (h2-hf)/hfg;
    
    m4_5 = ((h1_-h5)/(h1_-h4));
    qout = m4_5*(h2-h3);
    qin = h9-h6+h11-h10+h1-h12;
    
    efficiency = (1-(qout/qin))*100;
    
    Wnet = qin-qout;
end
