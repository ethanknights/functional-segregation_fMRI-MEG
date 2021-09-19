function saveNSpikes(TF,h2,subDir,bandName)

[row,col] = find(TF);
check.nSpikesFilledByFilter.row = row;
check.nSpikesFilledByFilter.col = col;
check.nSpikesFilledByFilter.n = length(row);

%% filter again (to see how many outliers remain after filter done)
[~, TF, ~, ~, ~]  = filloutliers(h2, 'clip' , 'median' , 'ThresholdFactor' ,5);
[row,col] = find(TF);
check.nSpikesRemaining.row = row;
check.nSpikesRemaining.col = col;
check.nSpikesRemaining.n = length(row);


save(fullfile(subDir,...
    sprintf('check_nSpikes_%s.mat',bandName)),...
    'check');
end