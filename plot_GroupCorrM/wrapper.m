%% Plot key Schaefer atlas corrMats
%%
%%
%% fMRI: original vs. partial correlation
%%
%% MEG:
%% 1. with Orthog                       | (Original)
%% 2. without orthog                    | (To see effect of orthog!)
%% 3. with orthog, partial correlation  | (is there more lateralised structure?)
%% 4. with orthog, despike envelope (i.e. despike after downsampling), no partial correlation
%% 5. with orthog, despike envelope (i.e. despike after downsampling), with partial correlation
%% ========================================================================
clear; close all

projectDir = '/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/';
outDir = 'images'; mkdir(outDir)

list_bandNames = {'delta','theta','alpha','beta','lGamma', ...
  'broadband'};


%% fMRI
%% ========================================================================
dirfN = fullfile(projectDir,...
  'fMRI_Schaefer/data_original_noPartialCorrelation/002_getRestingStateFC/schaefer');
load(fullfile(dirfN,'connectivity-betaMatrix.mat'),...
  'corrM');
%% normalise output
%% ------------------------------------------------------------------------
%% data
tmpD = mean(corrM.Bmat,3);
%% ROILabels
[roiLabels] = makeROILabels(corrM.atlasInfo.networkLabel_str);
%% titleStr
atlasName = 'Schaefer';
nSubs = length(corrM.Bmat);
titleStr = sprintf('Correlation Matrix-fMRI Measure-Betas Atlas-%s N-%d',atlasName,nSubs);
%% outName
oN = sprintf('%s/corrM-fMRI_Measure-Betas_Atlas-%s_N-%d',outDir,atlasName,nSubs); %.jpg
%% doPlot
%% ------------------------------------------------------------------------
doPlot(tmpD,roiLabels,titleStr,oN)


%% fMRI v2 - Partial Correlation
%% ========================================================================
dirfN = fullfile(projectDir,...
  'fMRI_Schaefer/data_partialCorrelation/002_getRestingStateFC/schaefer');
load(fullfile(dirfN,'connectivity-betaMatrix.mat'),...
  'corrM');
%% normalise output
%% ------------------------------------------------------------------------
%% data
tmpD = mean(corrM.Bmat,3);
%% ROILabels
[roiLabels] = makeROILabels(corrM.atlasInfo.networkLabel_str);
%% titleStr
atlasName = 'Schaefer';
nSubs = length(corrM.Bmat);
titleStr = sprintf('Correlation Matrix-fMRI Measure-Betas Atlas-%s N-%d (Partial Correlation)',atlasName,nSubs);
%% outName
oN = sprintf('%s/corrM-fMRI_Measure-Betas_Atlas-%s_N-%d_withPartialCorrelation',outDir,atlasName,nSubs); %.jpg
%% doPlot
%% ------------------------------------------------------------------------
doPlot(tmpD,roiLabels,titleStr,oN)

%% MEG
%% 1. with Orthog                       | (Original)
%% ========================================================================
dirfN = fullfile(projectDir,...
  'MEG/data/group_corrMat/ROIs-Schaefer_100parcels_7networks_v1_orthog');
load(fullfile(dirfN,'group_corrMat_roiOrder-dropSchaefer_doOrthog-1.mat'),...
  'corrMat','roiLabels'); 
%% normalise output
%% ------------------------------------------------------------------------
networkLabel_str = roiLabels; clear roiLabels
for b=1:length(list_bandNames); bandName = list_bandNames{b};
  %% data
  eval(sprintf('tmpD = corrMat.%s;',bandName)); %tmpD
  %% ROILabels
  %roiLabels = networkLabel_str; %TMP!!
  [roiLabels] = makeROILabels(networkLabel_str);
  %% titleStr
  atlasName = 'Schaefer';
  nSubs = 619; %HARDCODED!!
  titleStr = sprintf('Correlation Matrix-MEG Measure-%s Atlas-%s N-%d (With Orthogonalisation)',bandName,atlasName,nSubs);
  %% outName
  oN = sprintf('%s/corrM-MEG_Measure-%s_Atlas-%s_N-%d_WithOrthogonalisation',outDir,bandName,atlasName,nSubs); %.jpg
  %% doPlot
  %% ------------------------------------------------------------------------
  doPlot(tmpD,roiLabels,titleStr,oN)
end


%% MEG


