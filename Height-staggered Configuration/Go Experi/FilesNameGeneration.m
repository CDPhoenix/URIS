

function [datatags,dataFilenames,expers] = FilesNameGeneration(physicals,Filepath,spacing,index)
    len = size(physicals,2);
    datatags = cell(1,len);
    dataFilenames = cell(1,len);
    expers = cell(1,len);
    for i = 1:len
        datatags{i} = ['data',num2str(i+10)];
        dataFilenames{i} = [Filepath,char(physicals{i}),spacing,num2str(index),'.csv'];
        expers{i} = char(physicals{i});
    end
end