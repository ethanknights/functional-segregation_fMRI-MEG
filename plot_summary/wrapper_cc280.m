%% For key Schaefer atlas corrMats - 
%% - Plot group corrMatrices
%% - Calculate Laterality Index scores
%%
%% ------------------------------------------------------------------------
%%
%% fMRI: original vs. partial correlation
%%
%% MEG:
%% 1. with Orthog                       | (Original)
%% 2. without orthog                    | (To see effect of orthog!)
%% 3. with orthog, partial correlation  | (is there more lateralised structure?)
%% 4. with orthog, despike envelope (i.e. despike after downsampling), no partial correlation
%% 5. with orthog, despike envelope (i.e. despike after downsampling), with partial correlation
%%
%% NOTES:
%% 1. fMRI drops non-association networks to match parcels in MEG.
%% ========================================================================
clear; close all

projectDir = '/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/';
outDir = 'images/cc280'; mkdir(outDir)

list_bandNames = {'delta','theta','alpha','beta','lGamma', ...
  'broadband'};

%% output table (t)
load(fullfile(projectDir,'fMRI_Schaefer_cc280/data/rawData/rawData.mat'));
t = table(d.CCID); t.Properties.VariableNames{1} = 'CCID_fMRI'; clear d
%% confirm all MEG CCIDs exist in fMRI 
% load(fullfile(projectDir,'MEG/CCIDList.mat'));
% for s = 1:length(CCIDList)
%   idx(s) = find(strcmp(CCIDList{s},t.CCID_fMRI))
% end
t.Properties.VariableNames{1} = 'CCID';

%% fMRI
%% ========================================================================
descriptStr = '';
dirfN = fullfile(projectDir,...
  'fMRI_Schaefer_cc280/data/002_getRestingStateFC/schaefer');
load(fullfile(dirfN,'connectivity-betaMatrix.mat'),...
  'corrM');
%% normalise output
%% ------------------------------------------------------------------------
%% data
tmpD = corrM.Bmat;
%drop non-association networks from data + roiLabel_strigns
listNetworkStrToDrop = {'_Limbic_','_Vis_','_SomMot_'};
for i = 1:length(listNetworkStrToDrop)
  idx = find(contains(corrM.atlasInfo.networkLabel_str,listNetworkStrToDrop{i}));
  tmpD(idx,:,:) = [];   tmpD(:,idx,:) = [];
  corrM.atlasInfo.networkLabel_str(idx) = [];
end
%% ROILabels
[roiLabels] = makeROILabels(corrM.atlasInfo.networkLabel_str);
%% titleStr
atlasName = 'Schaefer';
nSubs = size(tmpD,3);
titleStr = sprintf('Correlation Matrix-fMRI Measure-Betas Atlas-%s N-%d',atlasName,nSubs);
%% outName
oN = sprintf('%s/corrM-fMRI_Measure-Betas_Atlas-%s_N-%d',outDir,atlasName,nSubs); %.jpg
%% doPlot
%% ------------------------------------------------------------------------
doPlot(nanmean(tmpD,3),roiLabels,titleStr,oN);
%% doLaterality
%% ------------------------------------------------------------------------
[lS,lSReduced] = doLaterality(tmpD,corrM.atlasInfo.networkLabel_str);
t.fMRI_lS = lS;
t.fMRI_lSReduced = lSReduced;


%% fMRI - Partial Correlation
%% ========================================================================
dirfN = fullfile(projectDir,...
  'fMRI_Schaefer_cc280/data/002_getRestingStateFC/schaefer');
load(fullfile(dirfN,'connectivity-betaMatrix.mat'),...
  'corrM');
%% normalise output
%% ------------------------------------------------------------------------
%% data
tmpD = corrM.pBmat; %pBmat!
%drop non-association networks from data + roiLabel_strigns
listNetworkStrToDrop = {'_Limbic_','_Vis_','_SomMot_'};
for i = 1:length(listNetworkStrToDrop)
  idx = find(contains(corrM.atlasInfo.networkLabel_str,listNetworkStrToDrop{i}));
  tmpD(idx,:,:) = [];   tmpD(:,idx,:) = [];
  corrM.atlasInfo.networkLabel_str(idx) = [];
end
%% ROILabels
[roiLabels] = makeROILabels(corrM.atlasInfo.networkLabel_str);
%% titleStr
atlasName = 'Schaefer';
nSubs = size(tmpD,3);
titleStr = sprintf('Correlation Matrix-fMRI Measure-Betas Atlas-%s N-%d (Partial Correlation)',atlasName,nSubs);
%% outName
oN = sprintf('%s/corrM-fMRI_Measure-Betas_Atlas-%s_N-%d_PartialCorr',outDir,atlasName,nSubs); %.jpg
%% doPlot
%% ------------------------------------------------------------------------
doPlot(nanmean(tmpD,3),roiLabels,titleStr,oN);
%% doLaterality
%% ------------------------------------------------------------------------
[lS,lSReduced] = doLaterality(tmpD,corrM.atlasInfo.networkLabel_str);
t.fMRI_partialCorr_lS = lS;
t.fMRI_partialCorr_lSReduced = lSReduced;



%% Write table
writetable(t,'lateralityTable_cc280.csv');

return

%% doHists.m for other bespoke plots
