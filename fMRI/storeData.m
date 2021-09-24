function [d1,d2] = storeData(rootDir,outDir,S,corrM)

d = [];
rawDataDir = fullfile(rootDir,'data','rawData_Chanetal2018_neuaging');
rawD = readtable(fullfile(rawDataDir,'LEQ-MRI-N196.csv'));
tmpD = [];
for s = 1:length(rawD.CCID)
  idx = contain(rawD.CCID{s},corrM.CCIDList);
  if idx
    tmpD(s) = S(idx);
  else
    tmpD(s) = nan;
  end
end
d = appendToTable(tmpD',{'SystemSegregation_fMRIRest'},rawD);
writetable(d,fullfile(outDir,'LEQ-MRI-N196_withSystemSegregation.csv'));
%check ages of people missing: sort(d.Age(isnan(d.SystemSegregation_fMRIRest)))'
d1 = d;

%no MRI worksheet
d = [];
rawDataDir = fullfile(rootDir,'data','rawData_Chanetal2018_neuaging');
rawD = readtable(fullfile(rawDataDir,'LEQ-N205.csv'));
tmpD = [];
for s = 1:length(rawD.CCID)
  idx = contain(rawD.CCID{s},corrM.CCIDList);
  if idx
    tmpD(s) = S(idx);
  else
    tmpD(s) = nan;
  end
end
d = appendToTable(tmpD',{'SystemSegregation_fMRIRest'},rawD);
writetable(d,fullfile(outDir,'LEQ-N205_withSystemSegregation.csv'));
%check ages of people missing: sort(d.Age(isnan(d.SystemSegregation_fMRIRest))'
d2 = d;


plotRegression(d.SystemSegregation_fMRIRest,d.Age,'Segregation','Age','System Segregation In Chan et al. 2018 N=196')

end

