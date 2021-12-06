%% For key Schaefer atlas corrMats - 
%% - Plot group corrMatrices
%% - Calculate Laterality Index scores
%%
%% (The doHists.m script is typically used after)
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
outDir = 'images'; mkdir(outDir)

list_bandNames = {'delta','theta','alpha','beta','lGamma', ...
  'broadband'};

%% output table (t)
load(fullfile(projectDir,'fMRI_Schaefer/data/rawData/rawData.mat'));
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
  'fMRI_Schaefer/data/002_getRestingStateFC/schaefer');
load(fullfile(dirfN,'connectivity-betaMatrix.mat'),...
  'corrM');
%% normalise output
%% ------------------------------------------------------------------------
%% data
tmpD = corrM.Zmat; %or Bmat
%replace inf vals with min/max
for s = 1:length(tmpD); tmpD(:,:,s) = fixInf_Zmat(tmpD(:,:,s)); end
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
titleStr = sprintf('Correlation Matrix-fMRI Measure-ZStatistic Atlas-%s N-%d',atlasName,nSubs);
%% outName
oN = sprintf('%s/corrM-fMRI_Measure-ZStatistic_Atlas-%s_N-%d',outDir,atlasName,nSubs); %.jpg
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
  'fMRI_Schaefer/data/002_getRestingStateFC/schaefer');
load(fullfile(dirfN,'connectivity-betaMatrix.mat'),...
  'corrM');
%% normalise output
%% ------------------------------------------------------------------------
%% data
tmpD = corrM.pZmat; %pBmat / pZmat!
%replace inf vals with min/max
for s = 1:length(tmpD); tmpD(:,:,s) = fixInf_Zmat(tmpD(:,:,s)); end
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
titleStr = sprintf('Correlation Matrix-fMRI Measure-ZStatistic Atlas-%s N-%d (Partial Correlation)',atlasName,nSubs);
%% outName
oN = sprintf('%s/corrM-fMRI_Measure-ZStatistic_Atlas-%s_N-%d_PartialCorr',outDir,atlasName,nSubs); %.jpg
%% doPlot
%% ------------------------------------------------------------------------
doPlot(nanmean(tmpD,3),roiLabels,titleStr,oN);
%% doLaterality
%% ------------------------------------------------------------------------
[lS,lSReduced] = doLaterality(tmpD,corrM.atlasInfo.networkLabel_str);
t.fMRI_partialCorr_lS = lS;
t.fMRI_partialCorr_lSReduced = lSReduced;


%% MEG
%% A. no orthog, despike envelope (i.e. despike after downsampling), no partial correlation
%% ========================================================================
%% normalise output
%% ------------------------------------------------------------------------
descriptStr = 'noOrthog';
tmp = load(fullfile(projectDir,'MEG/data/group_corrMat/ROIs-Schaefer_100parcels_7networks_version-noOrthogDespikeEnvel/group_corrMat_roiOrder-dropSchaefer_doOrthog-0.mat'));
doMEG


%% MEG
%% B. with orthog, despike envelope (i.e. despike after downsampling), no partial correlation
%% ========================================================================
%% normalise output
%% ------------------------------------------------------------------------
descriptStr = 'orthog';
tmp = load(fullfile(projectDir,'MEG/data/group_corrMat/ROIs-Schaefer_100parcels_7networks_version-orthogDespikeEnvel/group_corrMat_roiOrder-dropSchaefer_doOrthog-1.mat'));
doMEG


%% MEG
%% C. with orthog, despike envelope (i.e. despike after downsampling), with partial correlation
%% ========================================================================
%% normalise output
%% ------------------------------------------------------------------------
descriptStr = 'orthog_partialCorr';
tmp = load(fullfile(projectDir,'MEG/data/group_corrMat/ROIs-Schaefer_100parcels_7networks_version-orthogDespikeEnvelPartialCorr/group_corrMat_roiOrder-dropSchaefer_doOrthog-1.mat'));
doMEG


 
%% Write table
writetable(t,'lateralityTable.csv');

return

%% doHists.m for other bespoke plots
