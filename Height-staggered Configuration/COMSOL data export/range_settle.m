


function [range_txt,range_numerical] = range_settle(range_txt_x,range_txt_y,range_txt_z,X,Y,Z)
            range_t = cell(1,3);
            range_n = cell(1,3);
            
            range_t{1}=range_txt_x;
            range_t{2}=range_txt_y;
            range_t{3}=range_txt_z;
            
            range_n{1} = X;
            range_n{2} = Y;
            range_n{3} = Z;
            
            range_txt = cell2struct(range_t,{'X','Y','Z'},2);
            range_numerical = cell2struct(range_n,{'X','Y','Z'},2);
end
