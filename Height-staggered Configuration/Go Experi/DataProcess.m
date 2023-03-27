

function [dataset,model] = DataProcess(modelFilename,datafilename,datatag,exper,range_txt)
    model = mphload(modelFilename);
    model.result.export.create(datatag,'dset1','Data');
    model.result.export(datatag).set('filename', datafilename);
    model.result.export(datatag).set('location', 'grid');
    model.result.export(datatag).set('gridx3', range_txt.X);
    model.result.export(datatag).set('gridy3', range_txt.Y);
    model.result.export(datatag).set('gridz3', range_txt.Z);
    model.result.export(datatag).setIndex('expr',exper,0);
    model.result.export(datatag).run;
    dataset = readmatrix(datafilename);
end

