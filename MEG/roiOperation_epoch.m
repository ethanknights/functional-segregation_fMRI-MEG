%% VERSION: FOR EPOCHED DATA (NOT CONTINUOUS)
function [y,h,cm] = roiOperation_epoch(D,bandName,bandFreq,descript_roisName,...
    CCID,subDir)
  
  %% NEED TO ADD SWITCH CASE FOR descript_roisName for Craddoc ROIs!!
  
%% Concatenate epochs to generate continuous virtual-sensor timecourse per voxel
y = D(:,:,:);

y(:,:,D.badtrials)=[];
y = reshape(y,D.nchannels,D.nsamples*(D.ntrials-size(D.badtrials,2))); %nTrials = allTrials - badTrials

%% Band-passed into the relevant frequency-band of interest.
y = ft_preproc_bandpassfilter(y, D.fsample, bandFreq, 5, 'but', 'twopass', 'reduce'); %this filter selects frequency band (beamfored to broadband)

%% Symmetric orthogonalization (Colclough et al., 2016).
y0 = ROInets.remove_source_leakage(y,'symmetric');

%% Hilbert transform for oscillatory amplitude envelopes
y = [];
y = reshape(y0,D.nchannels,D.nsamples,D.ntrials-size(D.badtrials,2)); %nTrials - badTrials

%% (Re-order rois (Colclough et al 2016 Neuroimage Fig. 1B))
y_reorder = [];
[labels,order,new_labels,new_order] = fmri_d100reduced_labels;
for i = 1:length(labels)
  y_reorder(i,:,:) = y(new_order(i),:,:);
end
labels_cm = new_labels; %to save
y = y_reorder;

doWinSize = 1;      %logical for hilbenv() - 1 = no moving average filter
doDownsample = 0;   %logical for hilbenv() - do manually after
doEdgeEffects = 0;  %logical for hilbenv() - do manually after
h = [];
for t=1:size(y_reorder,3)
  h(:,:,t) = hilbenv(squeeze(y(:,:,t)),1:D.nsamples,...
    doWinSize,doDownsample,doEdgeEffects);
end
h = reshape(h,D.nchannels,D.nsamples*(D.ntrials-size(D.badtrials,2))); %nTrials - badTrials

%% Despike to remove artefactual temporal transients using a median filter.
[h, tf, ~, ~, ~]  = filloutliers(h, 'clip' , 'median' , 'ThresholdFactor' ,5);
saveNSpikes(tf,h,subDir,bandName);

%% 1Hz downsample
h = resample(h',1,D.fsample);

%% Trim first 3 & last 3 samples (edge effects)
h = h(4:end-3,:);

%% Correlate <nRois e.g. 39>-node downsampled Hilbert envelopes 
cm = corr(h)+diag(nan(size(h,2),1));

%% Fisher transform
cm = atanh(cm);

%% Store fig
% figure('Position',[10 10 1250 750]),imagesc(cm); colorbar; %axis square; ca = [min(cm(:)) max(cm(:))];
% yticks(1:39); set(gca, 'YTicklabel',new_labels);
% xticks(1:39); set(gca, 'xTicklabel',new_labels); xtickangle(90);
% title(sprintf('%s Envelope Correlation %s',bandName,CCID)); 
% %saveas(gcf,sprintf('%s/hilbertEnvCorr_%s',subDir,bandN{band}),'jpeg'); 
% close all

%% Store cm
oN = fullfile(subDir,...
  ['hilbertEnvCorr_',bandName,'.mat']);
save(oN,'cm','h','labels_cm'); %connectivityMatrix,hilbertEnvelopeData
fprintf('Saved output (connectivityMatrix + hilbertEnvelopeData):\n%s\n',oN)

end