clc;
clear all;

% 1 reheater

w = Solution('liquidvapor.cti', 'water');

P3 = 10e+3;
P2 = P3;

P4 = 15e+6;
P5 = P4;
P6 = P4;
T6 = 500 + 273.15;

set(w, 'P', P6, 'T', T6);
h6 = enthalpy_mass(w);
s6 = entropy_mass(w);

s7 = s6;
P7 = 3e+6;
setState_SP(w, [s7, P7]);
h7 = enthalpy_mass(w);

P1 = P7;
T1 = T6;
set(w, 'P', P1, 'T', T1);
h1 = enthalpy_mass(w);
s1 = entropy_mass(w);


s2 = s1;
setState_SP(w, [s2, P2]);
h2 = enthalpy_mass(w);

setState_Psat(w, [P3, 0]);
h3 = enthalpy_mass(w);
s3 = entropy_mass(w); 

s4 = s3;
setState_SP(w, [s4, P4]);
h4 = enthalpy_mass(w);

% Calculating the efficiency

efficiency = 1 - (h2 - h3)/(h6 - h4 + h1 - h7);

% quality at state 2
setState_Psat(w, [P2, 0.0]);
sf = entropy_mass(w);
setState_Psat(w, [P2, 1.0]);
sg = entropy_mass(w);

sfg = sg - sf;

x = (s2 - sf)/sfg;

%% Printing the final results

fprintf("The efficiency of this cycle is %.4f %%\n", efficiency*100);
fprintf("The quality at condenser inlet is %.4f %%\n", x*100);
