
%DataExport for COMSOL Multiphysics Model in Matlab (URIS Project)
%WANG Dapeng Phoenix 20074734d Department of Mechanical Engineering
%THE HONG KONG POLYTECHNIC UNIVERSITY
%Contact: 20074734d@connect.polyu.hk

%Put all the files in the same root with COMSOL Model
%Parameters:
% modelFilename: The file name of the model
% datafilename: The FULL file name where you want to export
% range_txt_x,range_txt_y,range_txt_z: The coordinate grid range you want
% datatag: label tag of the data you export
% to extract the data
% X,Y,Z: numerical range corresponding to range_txt_~
% exper: expression of the expected export data. 'T' for temperature,
% 'spf.U'for velocity

% Example:

% modelFilename = '3D Cases_Matrix_turbulent_New.mph';
% datafilename = 'D:\PolyU\test.csv';
% datatag = 'data1';
% range_txt_x = 'range(250,15,925)';
% range_txt_y = 'range(100,15,775)';
% range_txt_z = 'range(5,10,50)';
% X = 250:15:925;
% Y = 100:15:775;
% Z = 5:10:50;
% exper = 'T';


function [dataset,range_numerical] = DataExport(modelFilename,datafilename,datatag,range_txt_x,range_txt_y,range_txt_z,X,Y,Z,exper)

    [range_txt,range_numerical] = range_settle(range_txt_x,range_txt_y,range_txt_z,X,Y,Z);

    dataset = DataProcess(modelFilename,datafilename,datatag,exper,range_txt);

end
