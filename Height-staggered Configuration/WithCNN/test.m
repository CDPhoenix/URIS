modelFilename = '38_114_38_88.mph';

model = mphload(modelFilename);

La_cal = Lacunarity_cal;


[Lsc,H] = La_cal.calculation(model);
