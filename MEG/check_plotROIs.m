%% Plot group average hilbEnv matrix
%% ==========================================================================

%--- data ---%
rootDir = pwd;
load('CCIDList','CCIDList','age');
nSubs = length(CCIDList);
descript_roisName = 'craddock';
list_bandNames = {'delta','theta','alpha','beta','lGamma', ...
  'broadband'};
descript_roiOrder = 'byNetwork';

%% manual ...
%% ------------------------------
bandName = list_bandNames{1}; %delta
%bandName = list_bandNames{2}; %theta

%% loop
%% ------------------------------
for bandName = list_bandNames; bandName = bandName{:};
  
  
  rootOutDir = 'data/group_corrMat'; mkdir(rootOutDir)
  outDir = fullfile(rootOutDir,['ROIs-',descript_roisName]); mkdir(outDir)
  
  
  close all
  
  
  fileStr = sprintf('data/pp/sub-CC*/ROIs-%s/hilbertEnvCorr_band-%s_roiOrder-%s.mat',...
    descript_roisName,bandName,descript_roiOrder);
  dirContents = dir(fileStr);
  nSubs = length(dirContents);
  fprintf('%d subs found for query:\n%s\n',nSubs,fileStr)
  
  parfor s = 1:nSubs
    parLoad(fullfile(dirContents(s).folder,dirContents(s).name));
    corrM(:,:,s) = corrMat;
  end
  group_corrM = nanmean(corrM,3);
  
  %% plot
  figure('Position',[10 10 1250 750]),imagesc(group_corrM); colorbar; %axis square; ca = [min(cm(:)) max(cm(:))];
  %manage labels
  switch descript_roiOrder
    case 'byNetwork'
      roiLabels2 = cell(1, height(t)); roiLabels2(:) = {''};
      [tmp,idx] = unique(roiLabels);
      for r=1:length(tmp); roiLabels2{idx(r)}=tmp{r}; end
      yticks(1:length(roiLabels2)); set(gca, 'YTicklabel',roiLabels2);
      xticks(1:length(roiLabels2)); set(gca, 'xTicklabel',roiLabels2); xtickangle(90);
  end
  h = gca; h.XAxis.TickLength = [0 0]; h.YAxis.TickLength = [0 0]; colormap(hot);
  
  title(sprintf('%s Envelope Correlation N=%d roiOrder %s',bandName,nSubs,descript_roiOrder));
  saveas(gcf,...
    sprintf('%s/groupCorrMat_band-%s_N=%d_roiOrder-%s',outDir,bandName,nSubs,descript_roiOrder),...
    'jpeg');
  fprintf('Saved figure - %s\n',bandName);
  
  %% append to allResults.pdf
  % export_fig allResults.pdf -append %so slow
  
  %% repeat without noNetworks
  group_corrM_dropNoNetwork = group_corrM(1:724,1:724);
  
  %% plot
  figure('Position',[10 10 1250 750]),imagesc(group_corrM_dropNoNetwork); colorbar; %axis square; ca = [min(cm(:)) max(cm(:))];
  %manage labels
  switch descript_roiOrder
    case 'byNetwork'
      roiLabels2 = cell(1, height(t)); roiLabels2(:) = {''};
      [tmp,idx] = unique(roiLabels);
      for r=1:length(tmp); roiLabels2{idx(r)}=tmp{r}; end
      yticks(1:length(roiLabels2)); set(gca, 'YTicklabel',roiLabels2);
      xticks(1:length(roiLabels2)); set(gca, 'xTicklabel',roiLabels2); xtickangle(90);
  end
  h = gca; h.XAxis.TickLength = [0 0]; h.YAxis.TickLength = [0 0]; colormap(hot);
  
  title(sprintf('%s Envelope Correlation N=%d roiOrder %s dropped noNetworks',bandName,nSubs,descript_roiOrder));
  saveas(gcf,...
    sprintf('%s/groupCorrMat_band-%s_N=%d_roiOrder-%s_dropped-noNetworks',outDir,bandName,nSubs,descript_roiOrder),...
    'jpeg');
  fprintf('Saved figure - %s\n',bandName);
  
  %% append to allResults.pdf
  %export_fig allResults.pdf -append %so slow
  
  close all
  
end