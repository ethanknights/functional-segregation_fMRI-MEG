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
outDir = 'images_cc280'; mkdir(outDir)

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
  'fMRI_Schaefer_cc280/data/002_getRestingStateFC/schaefer');
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
tmp = load(fullfile(projectDir,'MEG_cc280/data/group_corrMat/ROIs-Schaefer_100parcels_7networks_version-noOrthogDespikeEnvel/group_corrMat_roiOrder-dropSchaefer_doOrthog-0.mat'));
doMEG


%% MEG
%% B. with orthog, despike envelope (i.e. despike after downsampling), no partial correlation
%% ========================================================================
%% normalise output
%% ------------------------------------------------------------------------
descriptStr = 'orthog';
tmp = load(fullfile(projectDir,'MEG_cc280/data/group_corrMat/ROIs-Schaefer_100parcels_7networks_version-orthogDespikeEnvel/group_corrMat_roiOrder-dropSchaefer_doOrthog-1.mat'));
doMEG


%% MEG
%% C. with orthog, despike envelope (i.e. despike after downsampling), with partial correlation
%% ========================================================================
%% normalise output
%% ------------------------------------------------------------------------
descriptStr = 'orthog_partialCorr';
tmp = load(fullfile(projectDir,'MEG_cc280/data/group_corrMat/ROIs-Schaefer_100parcels_7networks_version-orthogDespikeEnvelPartialCorr/group_corrMat_roiOrder-dropSchaefer_doOrthog-1.mat'));
doMEG


%% Write table
writetable(t,'lateralityTable_cc280.csv');

return

%% doHists_cc280.m for other bespoke plots

%% ========================================================================
%% fMRI corrMat for cc700 + cc280
%% ========================================================================
projectDir = '/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/';
%% fMRI 700
%% ========================================================================
descriptStr = '';
dirfN = fullfile(projectDir,...
  'fMRI_Schaefer/data/002_getRestingStateFC/schaefer');
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
cc700 = mean(tmpD,3);
cc700( logical( eye( size(cc700) ) ) ) = nan; %diagonal

%% fMRI 280
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
cc280 = mean(tmpD,3);
cc280( logical( eye( size(cc280) ) ) ) = nan; %diagonal

%% axis Labels
roiLabels2 = cell(1, length(roiLabels)); roiLabels2(:) = {''};
[tmp,idx] = unique(roiLabels);
for r=1:length(tmp); roiLabels2{idx(r)}=tmp{r}; end 
halfOfLabels = roiLabels2(1:length(roiLabels2)/2);
roiLabels2(length(roiLabels2)/2+1:end) = halfOfLabels;
  

figure('Position',[0,0,2000,2000])
subplot(1,2,1), imagesc(cc700); colormap(hot); axis square; colorbar; caxis([0,1]);
yticks(1:length(roiLabels2)); set(gca, 'YTicklabel',roiLabels2);
xticks(1:length(roiLabels2)); set(gca, 'xTicklabel',roiLabels2); xtickangle(90);
title('CC700')
subplot(1,2,2), imagesc(cc280); colormap(hot); axis square; colorbar; caxis([0,1])
yticks(1:length(roiLabels2)); set(gca, 'YTicklabel',roiLabels2);
xticks(1:length(roiLabels2)); set(gca, 'xTicklabel',roiLabels2); xtickangle(90);
title('CC280')

sgtitle('fMRI BMatrix')
oN = sprintf('%s/corrM-fMRI_Measure-Betas_cc700ANDcc280',outDir); %.jpg
saveas(gcf,...
  oN,'jpeg');
   
   
ccDiff = cc700 - cc280
figure('Position',[0,0,1000,1000])
imagesc(ccDiff); colormap(hot); axis square; colorbar; %caxis([0,1]);
yticks(1:length(roiLabels2)); set(gca, 'YTicklabel',roiLabels2);
xticks(1:length(roiLabels2)); set(gca, 'xTicklabel',roiLabels2); xtickangle(90);

sgtitle('fMRI BMatrix CC700 CC280 Difference')
oN = sprintf('%s/corrM-fMRI_Measure-Betas_Diff-cc700cc280',outDir); %.jpg
saveas(gcf,...
  oN,'jpeg');


%% ========================================================================
%% fMRI corrMat for cc700 + cc280 - Partial Correlation
%% ========================================================================
projectDir = '/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/';
%% fMRI 700
%% ========================================================================
descriptStr = '';
dirfN = fullfile(projectDir,...
  'fMRI_Schaefer/data/002_getRestingStateFC/schaefer');
load(fullfile(dirfN,'connectivity-betaMatrix.mat'),...
  'corrM');
%% normalise output
%% ------------------------------------------------------------------------
%% data
tmpD = corrM.pBmat;
%drop non-association networks from data + roiLabel_strigns
listNetworkStrToDrop = {'_Limbic_','_Vis_','_SomMot_'};
for i = 1:length(listNetworkStrToDrop)
  idx = find(contains(corrM.atlasInfo.networkLabel_str,listNetworkStrToDrop{i}));
  tmpD(idx,:,:) = [];   tmpD(:,idx,:) = [];
  corrM.atlasInfo.networkLabel_str(idx) = [];
end
%% ROILabels
[roiLabels] = makeROILabels(corrM.atlasInfo.networkLabel_str);
cc700 = mean(tmpD,3);
cc700( logical( eye( size(cc700) ) ) ) = nan; %diagonal

%% fMRI 280
%% ========================================================================
descriptStr = '';
dirfN = fullfile(projectDir,...
  'fMRI_Schaefer_cc280/data/002_getRestingStateFC/schaefer');
load(fullfile(dirfN,'connectivity-betaMatrix.mat'),...
  'corrM');
%% normalise output
%% ------------------------------------------------------------------------
%% data
tmpD = corrM.pBmat;
%drop non-association networks from data + roiLabel_strigns
listNetworkStrToDrop = {'_Limbic_','_Vis_','_SomMot_'};
for i = 1:length(listNetworkStrToDrop)
  idx = find(contains(corrM.atlasInfo.networkLabel_str,listNetworkStrToDrop{i}));
  tmpD(idx,:,:) = [];   tmpD(:,idx,:) = [];
  corrM.atlasInfo.networkLabel_str(idx) = [];
end
%% ROILabels
[roiLabels] = makeROILabels(corrM.atlasInfo.networkLabel_str);
cc280 = mean(tmpD,3);
cc280( logical( eye( size(cc280) ) ) ) = nan; %diagonal

%% axis Labels
roiLabels2 = cell(1, length(roiLabels)); roiLabels2(:) = {''};
[tmp,idx] = unique(roiLabels);
for r=1:length(tmp); roiLabels2{idx(r)}=tmp{r}; end 
halfOfLabels = roiLabels2(1:length(roiLabels2)/2);
roiLabels2(length(roiLabels2)/2+1:end) = halfOfLabels;
  

figure('Position',[0,0,2000,2000])
subplot(1,2,1), imagesc(cc700); colormap(hot); axis square; colorbar; caxis([0,1]);
yticks(1:length(roiLabels2)); set(gca, 'YTicklabel',roiLabels2);
xticks(1:length(roiLabels2)); set(gca, 'xTicklabel',roiLabels2); xtickangle(90);
title('CC700')
subplot(1,2,2), imagesc(cc280); colormap(hot); axis square; colorbar; caxis([0,1])
yticks(1:length(roiLabels2)); set(gca, 'YTicklabel',roiLabels2);
xticks(1:length(roiLabels2)); set(gca, 'xTicklabel',roiLabels2); xtickangle(90);
title('CC280')

sgtitle('fMRI BMatrix partialCorr')
oN = sprintf('%s/corrM-fMRI_Measure-Betas_cc700ANDcc280_partialCorr',outDir); %.jpg
saveas(gcf,...
  oN,'jpeg');
   
   
ccDiff = cc700 - cc280
figure('Position',[0,0,1000,1000])
imagesc(ccDiff); colormap(hot); axis square; colorbar; %caxis([0,1]);
yticks(1:length(roiLabels2)); set(gca, 'YTicklabel',roiLabels2);
xticks(1:length(roiLabels2)); set(gca, 'xTicklabel',roiLabels2); xtickangle(90);

sgtitle('fMRI BMatrix CC700 CC280 Difference partialCorr')
oN = sprintf('%s/corrM-fMRI_Measure-Betas_Diff-cc700cc280_partialCorr',outDir); %.jpg
saveas(gcf,...
  oN,'jpeg');
