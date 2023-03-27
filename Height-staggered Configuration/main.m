
%Codes for conducting experiment on staggerd height problems of solar PV
%arrays
%WANG Dapeng Phoenix 20074734d Department of Mechanical Engineering
%THE HONG KONG POLYTECHNIC UNIVERSITY
%Contact: 20074734d@connect.polyu.hk


%Set parameters, we are going to use 3 spacings X 3 velocities

modelFilenames = cell(1,3);
velocity = cell(1,3);
physicals = cell(1,3);
spacing = cell(1,3);

%Containers for collecting and generating datas
dataX = zeros(3,3);
dataY = zeros(3,3);

%Velocities we used: 2.0m/s, 4.0m/s, 8.0m/s

velocity{1} = '2.0';
velocity{2} = '4.0';
velocity{3} = '8.0';

%Row spacings used: 88mm, 100mm, 125mm
spacing{1} = '88_';
spacing{2} = '100_';
spacing{3} = '125_';

%physical data collected

physicals{1} = 'T';  %Temperature
physicals{2} = 'ht.cfluxMag'; %Heat flux
physicals{3} = 'spf.nuT'; %Kinematics viscosity of fluid


module = '3D Cases_Matrix_turbulent_New_';%Standard part of file name

%Expected file path for storing collecting datas from COMSOL
Filepath = 'D:\PolyU\year3 sem02\URIS\COMSOL Practice\3DCases\Go Experi\';

%Data selection region setting in COMSOL
range_txt_x = 'range(250,15,925)';
range_txt_y = 'range(100,15,795)';
range_txt_z = 'range(5,10,50)';
X = 250:15:925;
Y = 100:15:775;
Z = 5:10:50;

k = 0.031;%Heat conduction coefficient of air 
T_ref = 293;%Reference temperature
Pr = 0.69;%Prandlt number for air
La_cal = Lacunarity_cal;%Initial the lacunarity calculator
cal = ParameterCalculator;%Initial the parameters calculator


for space = 1:size(spacing,2)
    x_data = zeros(1,3);
    y_data = zeros(1,3);
    for i = 1:3
        modelFilenames{i} = [module,char(spacing{space}),char(velocity(i)),'.mph'];
    end

    for i = 1:size(modelFilenames,2)
    %Generated selected file's name
    [datatags,dataFilenames,expers] = FilesNameGeneration(physicals,Filepath,char(spacing{space}),i);
        %Generated the physical parameters' data we need in that file
        for j = 1:size(physicals,2)
            [dataset,model,range_numerical]=DataExport(char(modelFilenames{i}),char(dataFilenames{j}),char(datatags{j}),range_txt_x,range_txt_y,range_txt_z,X,Y,Z,char(expers{j}));
        end
        U = str2num(model.physics('spf').feature('inl1').getStringArray('u0'));
        U = U(2);% Get the velocity
        T = readmatrix(char(dataFilenames{1}));% Get the temperature
        q = readmatrix(char(dataFilenames{2}));% Get the heat flux
        Kv = 15.7e-5;% Set the Kinematics viscosity of air
        [Lsc,H] = La_cal.calculation(model);% Calculate the lacunarity
        Nu = cal.NusseltNumber_cal(q,T,T_ref,H,k);% Calculate the Nusselt Number
        Re = cal.Reynolds_cal(U,Lsc,Kv);% Calculate the Reynolds Number
        x_axis_data = Re.^(1/5).*Pr.^(1/12);
        y_axis_data = Nu;
        x_data(1,i) = x_axis_data;
        y_data(1,i) = y_axis_data;
    end
    %Store the calculated data
    dataX(space,:) = x_data;
    dataY(space,:) = y_data;


end

figure();

%Plot the data
for space = 1:size(spacing,2)
    plot(dataX(space,:),dataY(space,:));
    hold on
end

title('Nusselt Number & Lacunarity');
legend('88mm','100mm','125mm');
