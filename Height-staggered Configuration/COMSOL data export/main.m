

modelFilename = '3D Cases_Matrix_turbulent_New.mph';
datafilename = 'D:\PolyU\test.csv';
datatag = 'random';
range_txt_x = 'range(250,15,925)';
range_txt_y = 'range(100,15,775)';
range_txt_z = 'range(5,10,50)';
X = 250:15:925;
Y = 100:15:775;
Z = 5:10:50;
exper = 'T';

La_cal = Lacunarity_cal;

[Lsc,H] = La_cal.calculation(model);

q = readmatrix('heat flux.csv');
k = 83.5;
U = 3.9;
T = readmatrix('Temperature.csv');
Kv = readmatrix('Kinematics Viscosity.csv');
T_ref = 292.15;

Pr = readmatrix('Prt.csv');
Pr = Pr(:,end);
A = 1;
cal = ParameterCalculator;
Nu = cal.NusseltNumber_cal(q,T,T_ref,H,k);
Re = cal.Reynolds_cal(U,Lsc,Kv);
