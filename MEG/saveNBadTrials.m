function saveNBadTrials(D,subDir,epochFlag)

if epochFlag
  
  check.nBadTrials = D.badtrials;
  
else %continuous
  
  check.nBadSamples = length( find(~good_samples(D)) );
  
end

save(fullfile(subDir,...
    'check_nBadTrials.mat'),...
    'check');
  
end