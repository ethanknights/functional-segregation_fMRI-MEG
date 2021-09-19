%% VERSION: FOR CONTINUOUS DATA
function [y,hilbEnv,corrMat] = roiOperation(D,y,roiLabels,bandName,bandFreq,...
    CCID,subDir,flag_overwrite)

%% Settings
%% -------------
flag_saveFig = false;


%% Script
%% -------------
oN = fullfile(subDir,...
  ['hilbertEnvCorr_',bandName,'.mat']);

if ~exist(oN,'file') %% don't re-process ...

  %% Remove badtrials
  y = y(:,good_samples(D)); % figure,imagesc(corrcoef(y'))
  
  %% Symmetric orthogonalization (Colclough et al., 2016)
  %y = ROInets.remove_source_leakage(y,'symmetric'); % figure,imagesc(corrcoef(y'))
  
  %% Band-passed into the relevant frequency-band of interest
  y = ft_preproc_bandpassfilter(y, D.fsample, bandFreq, 5, 'but', 'twopass', 'reduce');
  
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
  saveNSpikes(tf,hilbEnv,subDir,bandName);
  
  %% 1Hz downsample
  hilbEnv = resample(hilbEnv',1,D.fsample); %operates over columns (ROIs)
  
  %% Trim first 3 & last 3 samples (edge effects)
  hilbEnv = hilbEnv(4:end-3,:);
  
  %% Correlate <nRois e.g. 39>-node downsampled Hilbert envelopes 
  corrMat = corr(hilbEnv)+diag(nan(size(hilbEnv,2),1));
  
  %% Fisher transform
  corrMat = atanh(corrMat);
  
  %% Store fig
  if flag_saveFig
    figure('Position',[10 10 1250 750]),imagesc(corrMat); colorbar; %axis square; ca = [min(cm(:)) max(cm(:))];
    yticks(1:length(roiLabels)); set(gca, 'YTicklabel',roiLabels);
    xticks(1:length(roiLabels)); set(gca, 'xTicklabel',roiLabels); xtickangle(90);
    title(sprintf('%s Envelope Correlation %s',bandName,CCID)); 
    saveas(gcf,sprintf('%s/hilbertEnvCorr_%s',subDir,bandN{band}),'jpeg'); 
    close all
  end
  
  %% Store cm
  save(oN,'corrMat','hilbEnv','roiLabels'); %connectivityMatrix,hilbertEnvelopeData
  fprintf('Saved output (connectivityMatrix + hilbertEnvelopeData):\n%s\n',oN)

end