


function plot_drawing(dataset,X,Y,Z,height,flag)

    x_size = size(X,2);
    y_size = size(Y,2);
    z_size = size(Z,2);
    count_num = 1;
    value = zeros(x_size,y_size,z_size);
    for i = 1:x_size
        for j = 1:y_size
            for k = 1:z_size
                value(i,j,k) = dataset(count_num,1);    %按照矩阵顺序存储磁通密度模值
                count_num = count_num + 1;
            end
        end
    end
    figure(flag);
    surfc(X',Y',squeeze(value(:,:,height)));
    colorbar
end