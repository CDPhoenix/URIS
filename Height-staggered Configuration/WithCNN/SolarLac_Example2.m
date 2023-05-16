%% 
% This Script acts as an example template for calculating lacunarity of
% Solar Photovoltaic (PV) systems as discussed in Smith et al (2022), using
% the lacunarity framework as in Scott et al (2022)> Lacunarity describes
% the spatial heterogeneity by calculating a measure of 'gappiness' within
% a space (1, 2, or 3D)>
%
% The function <lacunarity.m>, as described and created by Ryan Scott (2022),
% requires a set of logical spatial data (i.e. true = 1 and false = 0) 
% representing a given space in terms of the objects present within 
% (i.e. true = 1) and the empty volume or area (i.e false = 0). 
%
% The function <Solar_Logical3D.m> creates a
% a functional (logical spatial matrix) representation of a PV plant for 
% calculating volumetric lacunarity of the system. An application
% of this method can be found in Smith et all 2022 "Viewing convection as 
% a solar farm phenomenon...")
%
% The user is required to input the relevant geometric plant parameters into 
% <SolarLogical3D.m>. Note, is it recommended that the resolution is at
% least 0.5 times the thickness of the smallest dimension.
%
% The resulting spatial matrix can then be used as an input into the
% function <lacunarity.m>
%
% The length scale introduced in Smith et al. is calculated here as <Lsc>


%%

B = 1.5;        % Ground-to-panel height [m]
Lmod = 3.35;    % Module length [m] (lower-to-upper edge) 
S = 5.8092;     % Module row-to-row spacing [m]
GCR = Lmod/S;       % ground coverage ratio 
thick = 0.1;       % Panel Thickness [m]
angle = 30;     % Panel inclination [deg]
Depth = 2;      % 'Spanwise' module width [m]
showArray = 0;      % Show/plot Representative array after creation? (1 = true; 0 = false)
row_num = 9;        % Number of module rows within the array
resolution = 0.05;    % Spatial resolution of created matrix [m] (pref.: res <= 0.5*L_{minimumFeatureLength})

 % create logical matrix representing PV plant volumetric geometry
    ArrLog = Solar_Logical3D(B, GCR, Lmod, thick, angle, Depth, row_num, showArray, resolution);
    
    % Define how many boxes for lacunarity.m
    n_p_Now = floor((1/2)*max(size(ArrLog)));
    tic
    
    %obtain lacunarity (L), box sizes
    [L, ~, R, ~, Z, ~] = lacunarity(ArrLog, n_p_Now);

    R_m = R.*resolution;        % translate box sizes into physical length
    
        asy = find(islocalmin(L),1,'first');    % Find largest relevant length scale
        
    Lsc = (sum(L(1:asy).*R_m(1:asy)))/length(R_m(1:asy));   % calculate lacunarity length scale as in Smith 2022.  

