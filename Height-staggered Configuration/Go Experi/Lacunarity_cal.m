classdef Lacunarity_cal
    methods(Static)
        function [Lsc,H] = calculation(model)
            B = model.geom('geom1').feature('blk2').getDouble('z');       % Ground-to-panel height [m]
            H = B*0.001;
            angle = 30;     % Panel inclination [deg]
            Lmod = model.geom('geom1').feature('blk2').getDouble('ly')*cos(angle);    % Module length [m] (lower-to-upper edge) 
            spacing_array = model.geom('geom1').feature('arr1').getDoubleArray('displ');
            S = (spacing_array(1,1)^2 + spacing_array(2,1)^2)^0.5;     % Module row-to-row spacing [m]
            GCR = Lmod/S;       % ground coverage ratio 
            thick = model.geom('geom1').feature('blk2').getDouble('lz');   % Panel Thickness [m]
            Depth = model.geom('geom1').feature('blk2').getDouble('lx');      % 'Spanwise' module width [m]
            showArray = 0;      % Show/plot Representative array after creation? (1 = true; 0 = false)
            row_num = model.geom('geom1').feature('arr1').getDouble('linearsize');        % Number of module rows within the array
            resolution = thick*0.5;    % Spatial resolution of created matrix [m] (pref.: res <= 0.5*L_{minimumFeatureLength})
            Lsc = Lacunarity_cal.Lsc_cal(B, GCR, Lmod, thick, angle, Depth, row_num, showArray, resolution);

        end
        function Lsc = Lsc_cal(B, GCR, Lmod, thick, angle, Depth, row_num, showArray, resolution)
            ArrLog = Solar_Logical3D(B, GCR, Lmod, thick, angle, Depth, row_num, showArray, resolution);
             % Define how many boxes for lacunarity.m
            n_p_Now = floor((1/2)*max(size(ArrLog)));
            tic
            
            %obtain lacunarity (L), box sizes
            [L, ~, R, ~, ~, ~] = lacunarity(ArrLog, n_p_Now);
        
            R_m = R.*resolution;        % translate box sizes into physical length
            
            asy = find(islocalmin(L),1,'first');    % Find largest relevant length scale
                
            Lsc = (sum(L(1:asy).*R_m(1:asy)))/length(R_m(1:asy))/1000;   % calculate lacunarity length scale as in Smith 2022.
        end
    end
end