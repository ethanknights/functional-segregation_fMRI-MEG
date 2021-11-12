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
[roiLabels] = makeROILabels_fMRI(corrM.atlasInfo.networkLabel_str);
%% titleStr
atlasName = 'Schaefer';
nSubs = length(corrM.Bmat);
otherStr = ' ';
titleStr = sprintf('Correlation Matrix-fMRI Measure-Betas Atlas-%s N-%d%s',atlasName,nSubs,otherStr);
%% outName
oN = sprintf('corrM-fMRI_Measure-Betas_Atlas-%s_N-%d',atlasName,nSubs); %.jpg
%% doPlot
%% ------------------------------------------------------------------------
doPlot(tmpD,roiLabels,titleStr,oN)


%% fMRI v2 - Partial Correlation
%% ========================================================================
dirfN = fullfile(projectDir,...
  'fMRI_Schaefer/data/002_getRestingStateFC/schaefer');
load(fullfile(dirfN,'connectivity-betaMatrix.mat'),...
  'corrM');
%% normalise output
%% ------------------------------------------------------------------------
%% data
tmpD = mean(corrM.Bmat,3);
%% ROILabels
[roiLabels] = makeROILabels_fMRI(corrM.atlasInfo.networkLabel_str);
%% titleStr
atlasName = 'Schaefer';
nSubs = length(corrM.Bmat);
otherStr = ' ';
titleStr = sprintf('Correlation Matrix-fMRI Measure-Betas Atlas-%s N-%d%s (Partial Correlation)',atlasName,nSubs,otherStr);
%% outName
oN = sprintf('corrM-fMRI_Measure-Betas_Atlas-%s_N-%d_withPartialCorrelation',atlasName,nSubs); %.jpg
%% doPlot
%% ------------------------------------------------------------------------
doPlot(tmpD,roiLabels,titleStr,oN)




%% plot function
%% ========================================================================
function doPlot(tmpD,roiLabels,titleStr,oN)
  tmpD( logical( eye( size(tmpD) ) ) ) = nan; %diagonal
  figure('Position',[0,0,1000,1000]), imagesc(tmpD)
  title(titleStr)
  %axis labels
  roiLabels2 = cell(1, length(roiLabels)); roiLabels2(:) = {''};
  [tmp,idx] = unique(roiLabels);
  for r=1:length(tmp); roiLabels2{idx(r)}=tmp{r}; end 
  halfOfLabels = roiLabels2(1:length(roiLabels2)/2);
  roiLabels2(length(roiLabels2)/2+1:end) = halfOfLabels;
  yticks(1:length(roiLabels2)); set(gca, 'YTicklabel',roiLabels2);
  xticks(1:length(roiLabels2)); set(gca, 'xTicklabel',roiLabels2); xtickangle(90);
  h = gca; h.XAxis.TickLength = [0 0]; h.YAxis.TickLength = [0 0]; colormap(hot); colorbar
  %% write
  saveas(gcf,...
     oN,'jpeg');
end



%% ROILabels functions
%% ========================================================================
function [roiLabels, t] = makeROILabels_fMRI(networkLabels_str)
  t = table(networkLabels_str); finalCol = width(t) + 1;
  idx=find(contains(t.Var1,'_Vis_'));         t(idx,finalCol) = array2table(ones * 1); t(idx,finalCol+1) = cell2table({'Vis'});
  idx=find(contains(t.Var1,'_SomMot_'));      t(idx,finalCol) = array2table(ones * 2); t(idx,finalCol+1) = cell2table({'SomMot'});
  idx=find(contains(t.Var1,'_DorsAttn_'));    t(idx,finalCol) = array2table(ones * 3); t(idx,finalCol+1) = cell2table({'DorsAttn'});
  idx=find(contains(t.Var1,'_SalVentAttn_')); t(idx,finalCol) = array2table(ones * 4); t(idx,finalCol+1) = cell2table({'SalVentAttn'});
  idx=find(contains(t.Var1,'_Limbic_'));      t(idx,finalCol) = array2table(ones * 5); t(idx,finalCol+1) = cell2table({'Limbic'});
  idx=find(contains(t.Var1,'_Cont'));         t(idx,finalCol) = array2table(ones * 6); t(idx,finalCol+1) = cell2table({'Cont'});
  idx=find(contains(t.Var1,'_Default'));      t(idx,finalCol) = array2table(ones * 7); t(idx,finalCol+1) = cell2table({'Default'});
  roiLabels = t.Var3;
end