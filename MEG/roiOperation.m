%% VERSION: FOR CONTINUOUS DATA
%% ROISET - Craddock
%% Routine repeats 3 times with different ROI orders:
%% Original ROI order, Ordered by network, Ordered by laterality (euclDist)

function [y,hilbEnv,corrMat] = roiOperation(D,bandName,bandFreq,descript_roiOrder,...
  CCID,subDir)

%% Settings
%% -------------
flag_saveFig = true;

descript_roiOrder = 'byNetwork';

%% Script
%% -------------
oN = fullfile(subDir,...
  ['hilbertEnvCorr_band-',bandName,'_roiOrder-',descript_roiOrder,'.mat']);

if ~exist(oN,'file') %% don't re-process ...
  
  y = D(:,:); %ROI x time
  
  %% Get ROI Labels (and, if OSL ROIs, re-order y (Colclough et al 2016 Neuroimage Fig. 1B))
  %   switch descript_roisName
  %     case 'OSL_noOverlap'
  %       [y,roiLabels] = reorderOSLROIs(y);
  %     case 'Craddock_LindaFC'
  [t] = readtable('ROIs/craddock-ROI-835_resampled-6mm.csv');
  %   end
  
  %% Reorder
  %% Get ROI Labels (and, if OSL ROIs, re-order y (Colclough et al 2016 Neuroimage Fig. 1B))
  switch descript_roiOrder
    case 'originalOrder'
      %As is
      error('Error\n Skip this original craddock ROI order')
    case 'byNetwork'
      [y,roiLabels,t] = reorder_craddock_byNetwork(y,t);
    case 'Laterality'
      %[y,roiLabels] = reorderOSLROIs(y); 
  end
  
  %% Remove badtrials
  y = y(:,good_samples(D)); % figure,imagesc(corrcoef(y'))
  fprintf('Dropped badSamples - %s\n',bandName);
  
  %% Symmetric orthogonalization (Colclough et al., 2016)
  %y = ROInets.remove_source_leakage(y,'symmetric'); % figure,imagesc(corrcoef(y'))
  
  %% Band-passed into the relevant frequency-band of interest
  y = ft_preproc_bandpassfilter(y, D.fsample, bandFreq, 5, 'but', 'twopass', 'reduce');
  fprintf('Filtered - %s\n',bandName);
    
  %% Hilbert transform to extract oscillatory amplitude envelopes
  hilbEnv = [];
  %options
  doWinSize = 1;      %1 = no moving average filter for hilbenv()
  doDownsample = 0;   %logical for hilbenv() - do manually after
  doEdgeEffects = 0;  %logical for hilbenv() - do manually after
  hilbEnv = hilbenv(y,[1:length(y)],...
    doWinSize,doDownsample,doEdgeEffects); % figure('position',[100,100,1200,1200]),plot(hilbEnv(1,:)); title('roi 1 timeseries'); for chanN = 1:39; subplot(5,8,chanN); p1 = plot(y(chanN,:,1)); p1.Color(4) = 0.25; end

  %% Despike to remove artefactual temporal transients using MAD filter.
  [hilbEnv, tf, ~, ~, ~]  = filloutliers(hilbEnv, 'clip' , 'median' , 'ThresholdFactor' ,5); % figure('position',[100,100,1200,1200]),plot(hEnv(1,:)); title('roi 1 timeseries'); for chanN = 1:39; subplot(5,8,chanN); p1 = plot(y(chanN,:,1)); p1.Color(4) = 0.25; end
  saveNSpikes(tf,hilbEnv,subDir,bandName,descript_roiOrder);
  fprintf('Despiked - %s\n',bandName);
    
  %% 1Hz downsample
  hilbEnv = resample(hilbEnv',1,D.fsample); %operates over columns (ROIs)
  
  %% Trim first 3 & last 3 samples (edge effects)
  hilbEnv = hilbEnv(4:end-3,:);
  fprintf('Trimmed edge effects - %s\n',bandName);
  
  %% Correlate <nRois e.g. 39>-node downsampled Hilbert envelopes 
  corrMat = corr(hilbEnv)+diag(nan(size(hilbEnv,2),1));
  
  %% Fisher transform
  corrMat = atanh(corrMat);
  
  %% Store fig
  if flag_saveFig
    figure('Position',[10 10 1250 750]),imagesc(corrMat); colorbar; %axis square; ca = [min(cm(:)) max(cm(:))];
    
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
    
    title(sprintf('%s Envelope Correlation %s roiOrder %s',bandName,CCID,descript_roiOrder));
    saveas(gcf,...
      sprintf('%s/hilbertEnvCorr_%s_roiOrder-%s',subDir,bandName,descript_roiOrder),...
      'jpeg');
    close all
    fprintf('Saved figure - %s\n',bandName);
  end
  
  %% Store cm
  save(oN,'corrMat','hilbEnv','roiLabels','t'); %connectivityMatrix,hilbertEnvelopeData
  fprintf('Saved output (connectivityMatrix + hilbertEnvelopeData):\n%s\n',oN)
  
end