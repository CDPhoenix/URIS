
modelnames = cell(1,7);
%modelnames = cell(1,1);
rownames = '88';
exper = cell(1,2);
plotgroup = cell(1,2);

modelnames{1} = '38_38_38_';
modelnames{2} = '38_76_38_';
modelnames{3} = '38_114_38_';
modelnames{4} = '38_114_76_';
modelnames{5} = '38_38_114_';
modelnames{6} = '38_76_114_';
modelnames{7} = '76_76_76_';
exper{1} = 'ht.dfluxMag';
%exper{1} = 'ht.cfluxMag';
exper{2} = 'T';
plotgroup{1} = 'pg6';
plotgroup{2} = 'pg7';
export = 0;
SimulExport = 0;

%range_txt_x = 'range(2550,0.1,3500)';
%range_txt_y = 'range(0,0.1,160)';
%X = 2550:5:2850;
%Y = 0:5:160;


k = 0.028;
U = 308;
Kv = 1.57e-5;
T_ref =293.15;
%T_ref = 293.15
%T_abs = 309;

T_ref1 = 330;
Pr = 0.69;
A = 1;


datapath = 'D:\PolyU\year3 sem02\URIS\COMSOL Practice\3DCases\2023.05.11\';
x_data = zeros(size(modelnames));
y_data = zeros(size(modelnames));
PRs = zeros(size(modelnames));
NU = zeros(size(modelnames));
LSC = zeros(size(modelnames));
RE = zeros(size(modelnames));

for i = 1:length(modelnames)

    modelFilename = [modelnames{i},rownames,'.mph'];
    for j = 1:length(exper)
        datafilename = [datapath,modelnames{i},exper{j},'.csv'];
        datatag = num2str(j);
        [dataset,model] = DataExport(modelFilename,datafilename,datatag,plotgroup{j});
    end
    La_cal = Lacunarity_cal;
    [Lsc,H] = La_cal.calculation(model,modelnames{i},rownames,export);
    q = readmatrix([modelnames{i},exper{1},'.csv']);
    T = readmatrix([modelnames{i},exper{2},'.csv']);
    cal = ParameterCalculator;
    Nu = cal.NusseltNumber_cal(q,T,T_ref,H,k);
    Re = cal.Reynolds_cal(U,Lsc,Kv);
    PR = cal.PowerRatio(T,T_ref1);
    x_axis_data = Re.^(1/5).*Pr.^(1/12);
    y_axis_data = Nu;
    x_data(1,i) = x_axis_data;
    y_data(1,i) = y_axis_data;
    NU(1,i) = Nu;
    RE(1,i) = Re.^(1/5);
    LSC(1,i) = Lsc;
    PRs(1,i) = PR;


end

if SimulExport == 1
    save('NU.mat','NU');
    save('LSC.mat','LSC');
    save('RE.mat','RE');
end

figure(1)
plot(x_data,y_data)
grid on
title('Nusselt Number vs Lacunarity')
xlabel('Re^{1/5}Pr^{1/12}')
ylabel('Nusselt Number')
figure(2)
x = linspace(1,7,7);
plot(x,PRs)
title('Temperature Reduction evaluation')
xticklabels({'38-38-38','38-76-38','38-114-38','38-114-76','38-38-114','38-76-114','76-76-76'})
xlabel('Case number')
ylabel('mean(T)')
grid on

