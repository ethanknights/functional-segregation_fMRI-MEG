%% Purpose:
%% Compute RSFC system segregation:
%% - With within-network normalisation (within - between / within) (Chan et al. 2014)
%% - And without (within-between)
%% Measure for SyS is currently ZStatistic (rather than corrM.BMat)

function [W,B,S] = computeSyS_associationOnly(outDir,corrM)

outDir = [outDir,'_associationOnly'];
mkdir(outDir)

%% Setup Subjects
CCIDList = corrM.CCIDList;
nSubs = length(CCIDList);

%% grab subjects ages (as might have dropped some so d.age useless)
I = LoadSubIDs;
for s = 1:nSubs
  idx = contain(CCIDList{s},I.SubCCIDc);
  age(s) = I.Age(idx);
end
age = age';

%% drop networks
%listNetworkStrToDrop = {'noNetwork'};
% listNetworkStrToDrop = {'Limbic'};
listNetworkStrToDrop = {'Limbic','Vis','SomMot'};
for n = 1:length(listNetworkStrToDrop)
    idx = contains(corrM.atlasInfo.networkLabel_str,listNetworkStrToDrop{n});
    corrM.Bmat(:,idx,:) = []; corrM.Bmat(idx,:,:) = [];
    corrM.Zmat(:,idx,:) = []; corrM.Zmat(idx,:,:) = [];
    corrM.atlasInfo.networkLabel_num(idx) = [];
    corrM.atlasInfo.networkLabel_str(idx) = [];
%     corrM.atlasInfo.numVox(idx) = [];
end


% %% print number of ROis per network left
% u = unique(corrM.atlasInfo.networkLabel_num);
% for uu= 1:length(u)
%   corrM.atlasInfo.nRoisPerNetwork(uu) = sum(corrM.atlasInfo.networkLabel_num == u(uu));
%   fprintf('nROis for Network: %s %s\n',corrM.atlasInfo.networkLabel_str{uu},num2str(corrM.atlasInfo.nRoisPerNetwork(uu)));
% end


%% WIGG'S VERSION: calculate system segregation
for s = 1:length(CCIDList)
  
  %Get main data (i.e. subs connectivity matrix & roi labels)
  M = squeeze(corrM.Bmat(:,:,s));
  Ci = corrM.atlasInfo.networkLabel_num;
  
  nCi = unique(Ci);
  
  Wv = [];
  Bv = [];
  
  for i = 1:length(nCi) % loop through communities
    Wi = Ci == nCi(i); % find index for this system (i.e. within  communitiy)
    Bi = Ci ~= nCi(i); % find index for diff system (i.e. between communitiy)
    
    Wv_temp = M(Wi,Wi); % extract this system
    Bv_temp = M(Wi,Bi); % extract diff system
    
    Wv = [Wv, Wv_temp(logical(triu(ones(sum(Wi)),1)))'];
    Bv = [Bv, Bv_temp(:)'];
  end
  
  W(s) = mean(Wv); % mean this system
  B(s) = mean(Bv); % mean diff system
  S(s) = (W(s)-B(s))/W(s); % system segregation
  S2(s) = W(s) - B(s); % system segregation (without within-network normalisation)
  
end
%% plots
plotRegression(S',age)
title('System segregation - rest FC'); 
xlabel('age'); ylabel('mean within - between system')
outName = fullfile(outDir,'SystemSegregation');
cmdStr = sprintf('export_fig %s.png',outName)
eval(cmdStr);

plotRegression(B',age)
title('Between System mean - rest FC');
xlabel('age'); ylabel('mean between system')
outName = fullfile(outDir,'BetweenSystemMean');
cmdStr = sprintf('export_fig %s.png',outName)
eval(cmdStr);

plotRegression(W',age)
title('Within System mean - rest FC');
xlabel('age'); ylabel('mean within system')
outName = fullfile(outDir,'WithinSystemMean');
cmdStr = sprintf('export_fig %s.png',outName)
eval(cmdStr);

%% write SyS table
toWrite = table(CCIDList,S',age);
toWrite.Properties.VariableNames = {'CCID','SyS','Age'};
writetable(toWrite,fullfile(outDir,'SySTable.csv'))
%% check = readtable(fullfile(outDir,'SySTable.csv'))

%% write SyS table without within-network normalisation
toWrite = table(CCIDList,S2',age);
toWrite.Properties.VariableNames = {'CCID','SyS','Age'};
writetable(toWrite,fullfile(outDir,'SySTable_noNormalisation.csv'))
%% check = readtable(fullfile(outDir,'SySTable_noNormalisation.csv'))

return 

%% Repeat with ZMatrix - this doesnt work: inf values
%% ========================================================================

%% WIGG'S VERSION: calculate system segregation
for s = 1:length(CCIDList)
  
  %Get main data (i.e. subs connectivity matrix & roi labels)
  M = squeeze(corrM.Zmat(:,:,s));
  Ci = corrM.atlasInfo.networkLabel_num;
  
  nCi = unique(Ci);
  
  Wv = [];
  Bv = [];
  
  for i = 1:length(nCi) % loop through communities
    Wi = Ci == nCi(i); % find index for this system (i.e. within  communitiy)
    Bi = Ci ~= nCi(i); % find index for diff system (i.e. between communitiy)
    
    Wv_temp = M(Wi,Wi); % extract this system
    Bv_temp = M(Wi,Bi); % extract diff system
    
    Wv = [Wv, Wv_temp(logical(triu(ones(sum(Wi)),1)))'];
    Bv = [Bv, Bv_temp(:)'];
  end
  
  W(s) = mean(Wv); % mean this system
  B(s) = mean(Bv); % mean diff system
  S(s) = (W(s)-B(s))/W(s); % system segregation
  S2(s) = W(s) - B(s); % system segregation (without within-network normalisation)
  
end
%% plots
plotRegression(S',age)
title('System segregation - rest FC'); 
xlabel('age'); ylabel('mean within - between system')
outName = fullfile(outDir,'SystemSegregation_ZMat');
cmdStr = sprintf('export_fig %s.png',outName)
eval(cmdStr);

plotRegression(B',age)
title('Between System mean - rest FC');
xlabel('age'); ylabel('mean between system')
outName = fullfile(outDir,'BetweenSystemMean_ZMat');
cmdStr = sprintf('export_fig %s.png',outName)
eval(cmdStr);

plotRegression(W',age)
title('Within System mean - rest FC');
xlabel('age'); ylabel('mean within system')
outName = fullfile(outDir,'WithinSystemMean_ZMat');
cmdStr = sprintf('export_fig %s.png',outName)
eval(cmdStr);

%% write SyS table
toWrite = table(CCIDList,S',age);
toWrite.Properties.VariableNames = {'CCID','SyS','Age'};
writetable(toWrite,fullfile(outDir,'SySTable_ZMat.csv'))
%% check = readtable(fullfile(outDir,'SySTable.csv'))

%% write SyS table without within-network normalisation
toWrite = table(CCIDList,S2',age);
toWrite.Properties.VariableNames = {'CCID','SyS','Age'};
writetable(toWrite,fullfile(outDir,'SySTable_noNormalisation_ZMat.csv'))
%% check = readtable(fullfile(outDir,'SySTable_noNormalisation.csv'))

end