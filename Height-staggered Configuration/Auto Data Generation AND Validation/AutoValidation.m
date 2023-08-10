%heights1 = {'3.3'};
%heights2 = {'3.3'};
%heights3 = {'3.3'};

%heights1 = {'3.3','4.85'};
%heights2 = {'3.3','4.85'};
%heights3 = {'3.3','4.85'};

row_spacing = cell(1,6);

exper = cell(1,2);
plotgroup = cell(1,4);

exper{1} = 'q';
exper{2} = 'T';
%exper{3} = 'q2';
%exper{4} = 'T2';

plotgroup{1} = 'plot1';
plotgroup{2} = 'plot2';

row_spacing{1} = 5.81;
row_spacing{2} = 6.54;
row_spacing{3} = 7.26;
row_spacing{4} = 7.99;
row_spacing{5} = 8.72;
row_spacing{6} = 9.45;

%row_spacing = cell(1,3);

%row_spacing{1} = 5.81;
%row_spacing{2} = 7.26;
%row_spacing{3} = 9.45;


dataset = Arrangement(row_spacing);
save('dataset.mat','dataset');

dataset = load('dataset.mat');
Heights = dataset.dataset(:,1:3);
Heights = unique(Heights,'rows');
row_spacings = unique(dataset.dataset(:,end));

datapath = 'D:\WANG Dapeng_20074734D\ValidationForLES\Automia\data\';
modelpath = 'D:\WANG Dapeng_20074734D\ValidationForLES\Automia\';

La_cal = Lacunarity_cal;
cal = ParameterCalculator;

export = 0;
U=2.30;
k_cond = 0.028;
Kv = 1.57e-5;
T_ref =300.15;

Pr = 0.69;


calMethod = 0; 
ResearchDataX = zeros(length(Heights),length(row_spacings));
ResearchDataY = zeros(length(Heights),length(row_spacings));

%ResearchDataX = zeros(1,length(row_spacing));
%ResearchDataY = zeros(1,length(row_spacing));

figure(1);

for i=1:length(heights1)
    
    data = dataset.dataset((i-1)*6 + 1:i*6,:);
    
    heights1 = num2str(data(1,1));
    heights2 = num2str(data(1,2));
    heights3 = num2str(data(1,3));
    row_spacing = data(:,4);
    
    filename_prime = [datapath,heights1{i},'_',heights2{i},'_',heights3{i},'_'];
    modelname_prime = [heights1{i},'_',heights2{i},'_',heights3{i},'_'];
    
    x_axis = zeros(1,length(row_spacing));
    y_axis = zeros(1,length(row_spacing));
    
    for j = 1:length(row_spacing)
        row = num2str(row_spacing{j});
        model = mphload([modelname_prime,row,'.mph']);
        modelname = [modelname_prime,row,'_'];
        %model = mphload(modelname);
        for z = 1:length(exper)
            datafilename = [filename_prime,'_',row,'_',exper{z},'.csv'];
            model.result.export(plotgroup{z}).set('filename', datafilename);
            model.result.export(plotgroup{z}).run;
            if z == 1
                q = readmatrix(datafilename);
            else
                T = readmatrix(datafilename);
            end
        end
        
        %q = q(:,end);
        %T = T(:,end);
        [Lsc,H] = La_cal.calculation(model,modelname,export);
        %H = 3.3;
        Nu = cal.NusseltNumber_cal(q,T,T_ref,H,k_cond,calMethod);
        %U = 3.6;
        %if i == 3
        %    U = 3.6;
        %end
        Re = cal.Reynolds_cal(U,Lsc,Kv);
        
        x_axis_data = Re^(1/5)*Pr^(1/12);
        y_axis_data = Nu;
        
        x_axis(1,j) = x_axis_data;
        y_axis(1,j) = Nu;
        
    end
    ResearchDataX(i,:) = x_axis;
    ResearchDataY(i,:) = log10(y_axis);
    plot(x_axis,y_axis,'o');
    hold on
    
end
%p = [0.09,1.91];

%ResearchDataX = reshape(ResearchDataX,[1,length(Heights)*length(row_spacings)]);
%ResearchDataY = reshape(ResearchDataY,[1,length(Heights)*length(row_spacings)]);

x_axis2 = linspace(11,19,100);
y_axis2 = 10.^(0.09.*x_axis2+1.91);
%p = polyfit(ResearchDataX,ResearchDataY,1);
%y_axis_RSQ = polyval(p,ResearchDataX);

%Rsq = 1- sum((ResearchDataY-y_axis_RSQ).^2)/sum((ResearchDataY-mean(ResearchDataY)).^2);


plot(x_axis2,y_axis2);
grid on