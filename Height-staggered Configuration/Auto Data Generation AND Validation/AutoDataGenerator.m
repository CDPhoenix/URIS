%heights1 = {'3.3'};
%heights2 = {'4.85'};
%heights3 = {'3.3'};
%heights1 = cell(1,3);
%heights2 = cell(1,3);
%heights3 = cell(1,3);

%row_spacing = cell(1,3);


row_spacing = {5.81,6.54,7.26,7.99,8.72,9.45};


 
solidomain = [2,3,4,5,6,7,8,9,10,11];

isosurfs = [6,8,9,11,12,14,15,17,18,20,21,23,24,26,27,29,...
    30,32,33,35,36,38,39,41,42,44,45,47,48,50,51,53,54,56,57,59,60,62,63,65];

heatsurfs = [7,13,19,25,31,37,43,49,55,61];

counting = 1;

model = mphload('container.mph');

dataset = Arrangement(row_spacing);
save('dataset.mat','dataset');

for i = 15:length(dataset)
    
    data = dataset(i,:);
    
    heights1 = num2str(data(1,1));
    heights2 = num2str(data(1,2));
    heights3 = num2str(data(1,3));
    row_spacing = data(1,4);
    
    model.param.set('Panel_height1', [heights1,'[m]']);
    model.param.set('Panel_height2', [heights2,'[m]']);
    model.param.set('Panel_height3', [heights3,'[m]']);
    
    model.param.set('row_spacing', [num2str(row_spacing),'[m]']);
    
    
    if strcmp(heights1,heights2) ~= 1
       
       model.geom('geom1').feature('arr1').set('linearsize', '3');
       model.geom('geom1').feature('arr1').set('displ', [row_spacing*4;0;0]);
       model.geom('geom1').feature('arr2').set('linearsize', '5');
       model.geom('geom1').feature('arr2').set('displ', [row_spacing*2;0;0]);
       model.geom('geom1').feature('arr3').set('linearsize', '2');
       model.geom('geom1').feature('arr3').set('displ', [row_spacing*4;0;0]);
            
    else
            
       model.geom('geom1').feature('arr1').set('linearsize', '4');
       model.geom('geom1').feature('arr1').set('displ', [row_spacing*3;0;0]);
       model.geom('geom1').feature('arr2').set('linearsize', '3');
       model.geom('geom1').feature('arr2').set('displ', [row_spacing*3;0;0]);
       model.geom('geom1').feature('arr3').set('linearsize', '3');
       model.geom('geom1').feature('arr3').set('displ', [row_spacing*3;0;0]);
            
    end
    model.geom('geom1').run
    disp('Geometry Modification Completed');
        
    model.material('mat2').selection().set(solidomain);
    model.physics('ht').feature('solid2').selection().set(solidomain);
    model.physics('ht').feature('ins2').selection().set(isosurfs);
    model.physics('ht').feature('temp1').selection().set(heatsurfs);
        
    disp('Parameters Modification Completed');
        
    Filename = [heights1,'_',heights2,'_',heights3,'_',num2str(row_spacing),'.mph'];
    
    disp(datestr(now))   
    disp(['Caes_',num2str(counting),'_Studying']);
    model.study('std1').run;
    disp(['Case_',num2str(counting),'_Complete']);
    counting = counting + 1;
        
    mphsave(model,Filename);
    disp('model saving complete')
    disp(datestr(now))
    
   
    
end
