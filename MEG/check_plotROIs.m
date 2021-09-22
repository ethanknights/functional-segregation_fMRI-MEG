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




%% manual ... wip
%% ------------------------------
close all

bandName = list_bandNames{1}; %delta
bandName = list_bandNames{2}; %theta


dirContents = dir(...
  sprintf('data/pp/craddock/sub-CC*/hilbertEnvCorr_band-%s_roiOrder-byNetwork.mat',bandName)); 
nSubs = length(dirContents);

for s = 1:nSubs
  load(fullfile(dirContents(s).folder,dirContents(s).name))
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
h = gca; h.XAxis.TickLength = [0 0]; h.YAxis.TickLength = [0 0];

title(sprintf('%s Envelope Correlation N=%d roiOrder %s',bandName,nSubs,descript_roiOrder));
saveas(gcf,...
  sprintf('groupCorrMat_band-%s_N=%d_roiOrder-%s',bandName,nSubs,descript_roiOrder),...
  'jpeg');
fprintf('Saved figure - %s\n',bandName);

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
h = gca; h.XAxis.TickLength = [0 0]; h.YAxis.TickLength = [0 0];

title(sprintf('%s Envelope Correlation N=%d roiOrder %s',bandName,nSubs,descript_roiOrder));
saveas(gcf,...
  sprintf('groupCorrMat_band-%s_N=%d_roiOrder-%s_dropped-noNetworks',bandName,nSubs,descript_roiOrder),...
  'jpeg');
fprintf('Saved figure - %s\n',bandName);