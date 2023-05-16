%model = mphload('3D Cases_Matrix_turbulent_New');

%获得对应几何区域的坐标

%bulk = model.geom('geom1').feature('blk2');

%获取坐标例子：获得几何体在x轴的延展量：
%x = bulk.getDouble('x');

%坐标求解矢量生成 coord = diag(state);
%获取点的坐标
%pos = model.geom('geom1').feature('pt1').getDoubleMatrix('pvalid');

%获得阵列的数量
%array_quan = model.geom('geom1').feature('arr3').getDoubleArray('size');

%获得位移坐标
%sep = model.geom('geom1').feature('arr3').getDoubleArray('displ');

%获取某一个几何体上所有标注点的坐标
%points = zeros(array_quan,3);
%for i = 0:array_quan-1
%    points(i,:) = (pos + i*sep)'; 
%end

%建议直接开navigator获取所有对应几何体点的API，随后求解


model = mphload('3D Cases_Matrix_turbulent_New');
feature = 'T';
precision = 50;
values = featureValues(model,precision,feature);

function values = featureValues(model,precision,feature)
    start_coordinates = model.geom('geom1').feature('blk2').getDoubleArray('pos');
    SIZE = model.geom('geom1').feature('blk2').getDoubleArray('size');

    x_init = start_coordinates(1,:)+100;
    x_size = SIZE(1,:);

    y_init = start_coordinates(2,:);
    y_size = SIZE(2,:);

    z_init = start_coordinates(3,:);
    z_size = SIZE(3,:)+10;

    x_range = (x_init:precision:x_init+x_size)';
    y_range = (y_init:precision:y_init+y_size)';
    z_range = (z_init:precision:x_init+z_size)';

    coordinates = vectorcoordinateform(x_range,y_range,z_range);

    values = zeros(size(coordinates));



    for i = 1:size(coordinates,1)
        coord = diag(coordinates(i,:)');
        values(i,:) = mphinterp(model,feature,'coord',coord);
    end

end

function coordinates = vectorcoordinateform(x_range,y_range,z_range)
    UnitmatrixZ = transfer_matrix(z_range,y_range);
    UnitmatrixY = transfer_matrix(y_range,z_range);
    
    z_new = UnitmatrixZ*z_range;
    y_new = UnitmatrixY*y_range;
    yz_plane = [y_new z_new];

    UnitmatrixYZ = transfer_matrix(yz_plane,x_range);
    UnitmatrixX = transfer_matrix(x_range,yz_plane);

    yz_new = UnitmatrixYZ*yz_plane;
    x_new = UnitmatrixX*x_range;

    coordinates = [x_new yz_new];


end

function Tmatrix = transfer_matrix(coord1,coord2)
     len1 = size(coord1,1);
     len2 = size(coord2,1);
     unit_matrix1 = eye(len1);
     total_scale = len1*len2;
     Tmatrix = zeros(total_scale,len1);
     for i = 1:size(coord2,1)
         if i == 1
             Tmatrix(1:len1,:) = unit_matrix1;
         else
             Tmatrix((i-1)*len1+1:i*len1,:) = unit_matrix1;
         end
     end
end