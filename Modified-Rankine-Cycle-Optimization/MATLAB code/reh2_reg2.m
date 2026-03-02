clc;
clear all;

%2reh_2reg

%% 
h = Solution('liquidvapor.cti','water');

%% State 3
P3 = 10E+3;
setState_Psat(h,[P3,0]);
h3 = enthalpy_mass(h);
s3 = entropy_mass(h);

%% State 4
P4 = 0.05E+6;                % Vary
s4 = s3;
setState_SP(h,[s4,P4]);
h4 = enthalpy_mass(h);

%% State 5
P5 = P4;
setState_Psat(h,[P5,0]);
h5 = enthalpy_mass(h);
s5 = entropy_mass(h);

%% State 6
P6 = 2.1E+6;                % vary
s6 = s5;
setState_SP(h,[s6,P6]);
h6 = enthalpy_mass(h);

%% State 7
P7 = P6;
setState_Psat(h,[P7,0]);
h7 = enthalpy_mass(h);
s7 = entropy_mass(h);

%% State 8
P8 = 15E+6;
s8 = s7;
setState_SP(h,[s8,P8]);
h8 = enthalpy_mass(h);

%% State 9
P9 = P8;
setState_Psat(h,[P9,0]);
h9 = enthalpy_mass(h);

%% State 10
P10 = P8;
setState_Psat(h,[P10,1]);
h10 = enthalpy_mass(h);

%% State 11
P11 = P8;
T11 = 500+273.15;
set(h,'P',P11,'T',T11);
h11 = enthalpy_mass(h);
s11 = entropy_mass(h);

%% State 12
P12 = 1.8E+6;          % vary 
s12 = s11;
setState_SP(h,[s12,P12]);
h12 = enthalpy_mass(h);

%% State 13
P13 = P12;
T13 = 500+273.15;
set(h,'P',P13,'T',T13);
h13 = enthalpy_mass(h);
s13 = entropy_mass(h);

%% State 14
P14 = P6;
s14 = s13;
setState_SP(h,[s14,P14]);
h14 = enthalpy_mass(h);

%% State 1
P1 = P6;
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

x = ((h2-hf)/hfg)*100;

m4_5 = ((h1_-h5)/(h1_-h4));
m7_5 = ((h6-h12)/(h7-h12));

qout = m4_5*( h2 - h3 );
qin = ( m7_5 * (h11-h8+h13-h12) )+h1-h14;

efficiency = (1-(qout/qin))*100;

fprintf("The quality of the modified rankine cycle is %.4f %%\n", x);
fprintf("The efficiency of the modified rankine cycle is %.4f %%\n", efficiency);
