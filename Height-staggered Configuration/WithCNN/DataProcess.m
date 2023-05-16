

function [dataset,model] = DataProcess(modelFilename,datafilename,datatag,plotgroup)%,range_txt)
    model = mphload(modelFilename);
    %model.result.export.create(datatag,'dset1','Data');
    model.result.export.create(datatag,plotgroup,'Plot');
    model.result.export(datatag).set('filename', datafilename);
    %model.result.export(datatag).set('location', 'grid');
    %model.result.export(datatag).set('gridx2', range_txt.X);
    %model.result.export(datatag).set('gridy2', range_txt.Y);
    %model.result.export(datatag).set('gridz3', range_txt.Z);
    %model.result.export(datatag).setIndex('expr',exper,0);
    model.result.export(datatag).run;
    dataset = readmatrix(datafilename);
end