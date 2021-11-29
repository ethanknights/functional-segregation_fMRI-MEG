%% Plot group average hilbEnv matrix (VERSION : NaN THe LEFT and RIGHT 
%% subgrids for lateralised)
%%
%% Available:
%% plot_groupCorrMat('craddock','lateralised')
%% ==========================================================================
function plot_groupCorrMat(descript_roisName,descript_roiOrder)

%--- data ---%
rootDir = pwd;
load('CCIDList','CCIDList','age');
nSubs = length(CCIDList);
list_bandNames = {'delta','theta','alpha','beta','lGamma', ...
  'broadband'};


rootOutDir = 'data/group_corrMat'; mkdir(rootOutDir)
outDir = fullfile(rootOutDir,['ROIs-',descript_roisName]); mkdir(outDir)

%% Get ROI Labels & Reorder (for axis labels only)
switch descript_roisName
%--------------------------------------------------------------------------
  %-------- 
  case 'craddock'
  %--------
    [t] = readtable('ROIs/craddock-ROI-835_resampled-6mm.csv');
    switch descript_roiOrder
      case 'byNetwork'
        load('reorderIdx_atlas-craddock_order-byNetwork_nRois-835.mat','idx')
        t = t(idx,:);      roiLabels = t.networkName; %reorder
      case 'lateralised'
        load('reorderIdx_atlas-craddock_order-lateralised_nRois-782.mat','idx_a_ROIPairs','idx_b_LR');
        t = t(idx_a_ROIPairs,:);
        t = t(idx_b_LR,:);
        roiLabels = t.networkName;
    end

  %--------  
  case 'OSL_noOverlap' %legacy set
  %--------  
    switch descript_roiOrder
      case 'originalOrder'
        [y,roiLabels] = reorderOSLROIs(y); %this wont work right now... need idx
    end
%--------------------------------------------------------------------------
end




%% manual ...
%% ------------------------------
%bandName = list_bandNames{1}; %delta
%bandName = list_bandNames{2}; %theta

%% loop
%% ------------------------------
%% store mean of all subjects in corrMat.delta, corrMat.theta etc
for b=1:length(list_bandNames); bandName = list_bandNames{b};
  
  fileStr = sprintf('data/pp/sub-CC*/ROIs-%s/hilbertEnvCorr_band-%s_roiOrder-%s.mat',...
    descript_roisName,bandName,descript_roiOrder);
  dirContents = dir(fileStr);
  nSubs = length(dirContents);
  fprintf('%d subs found for query:\n%s\n',nSubs,fileStr)
  
  parfor s = 1:nSubs
    tmpD = parLoad(fullfile(dirContents(s).folder,dirContents(s).name));
    corrM(:,:,s) = tmpD.corrMat;
  end
  
  % save(fullfile(outDir,['corrMat_',bandName,'.mat']),'corrM') %huge file if saving all subjects
  
  eval(sprintf('corrMat.%s = nanmean(corrM,3)',bandName)); %mean corrMat
  
  
  %% plot group corrMat - WITH NaNs
  %% ======================================================================
  group_corrM = [];
  eval(sprintf('group_corrM = corrMat.%s;',bandName));
  
  group_corrM(1:391,1:391) = nan; %left
  group_corrM(392:end,392:end) = nan;

  figure('Position',[10 10 1250 750]),imagesc(group_corrM); colorbar; %axis square; ca = [min(cm(:)) max(cm(:))];
  %manage labels
  switch descript_roiOrder
    case 'byNetwork'
      roiLabels2 = cell(1, height(t)); roiLabels2(:) = {''};
      [tmp,idx] = unique(roiLabels);
      for r=1:length(tmp); roiLabels2{idx(r)}=tmp{r}; end
      yticks(1:length(roiLabels2)); set(gca, 'YTicklabel',roiLabels2);
      xticks(1:length(roiLabels2)); set(gca, 'xTicklabel',roiLabels2); xtickangle(90);
    otherwise
      yticks(1:length(roiLabels)); set(gca, 'YTicklabel',roiLabels);
      xticks(1:length(roiLabels)); set(gca, 'xTicklabel',roiLabels); xtickangle(90);
  end
  h = gca; h.XAxis.TickLength = [0 0]; h.YAxis.TickLength = [0 0]; colormap(hot);
  
  title(sprintf('%s Envelope Correlation N=%d roiOrder %s',bandName,nSubs,descript_roiOrder));
  saveas(gcf,...
    sprintf('%s/groupCorrMat_band-%s_N=%d_roiOrder-%s_VersionNaN',outDir,bandName,nSubs,descript_roiOrder),...
    'jpeg');
  fprintf('Saved figure - %s\n',bandName);
  
  
end

save(fullfile(outDir,sprintf('group_corrMat_Order-%s_VersionNaN.mat',descript_roiOrder)),'corrMat')
close all