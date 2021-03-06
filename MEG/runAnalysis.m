%% Adapted from
%% https://github.com/delshadv/BioFIND-data-paper/blob/master/preproc_beamform_ROI.m 
%% Pre-Process, Beamform, ROI Extraction, Hilb. Env. Correlation %%
%% ========================================================================

%% Settings
%% ========================================================================
clear

%% Specify Analysis Branch (e.g. which ROIs for directory name)
%% ------------------------------------------------------------------------
descript_roisName = 'Schaefer_100parcels_7networks';
switch descript_roisName
  case 'OSL_noOverlap'
    parcellation_fN = 'fmri_d100_parcellation_with_PCC_tighterMay15_v2_6mm_exclusive.nii.gz'; % 6mm version of Quinn et al. (2018). Task-evoked dynamic network analysis through hidden markov modeling. Frontiers in neuroscience, 12, 603.
  case 'craddock'
    parcellation_fN = '/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG/ROIs/craddock_ROI-835_dim-4D_resampled-6mm.nii';
  case 'Schaefer_100parcels_7networks'
    parcellation_fN = '/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG/ROIs/Schaefer/Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm-dim-4D_resampled-6mm.nii';
end

%% Specify Analysis Branch (e.g. which ROIs for directory name)
%% ------------------------------------------------------------------------
%descript_roiOrder = 'byNetwork';
%descript_roiOrder = 'lateralised';
%descript_roiOrder = 'originalOrder';
descript_roiOrder = 'dropSchaefer';

%% Processing Stage
%% ------------------------------------------------------------------------
done_crop         = true;
done_epoch        = true;
done_coreg        = true;
done_beamform     = false;
done_roiOperation = false;
done_plotGroup    = true;

%% toolboxes
%% ------------------------------------------------------------------------
qOSL


%% data
%% ------------------------------------------------------------------------
keepdata = false; %If false, intermediate files will be deleted to save disk space
rootDir = pwd;
load('CCIDList','CCIDList','age');
nSubs = length(CCIDList);
%nSubs = 1;

%% source localisation
%% ------------------------------------------------------------------------
p = parcellation(parcellation_fN);
mni_coords = p.template_coordinates;

%% frequency bands
%% ------------------------------------------------------------------------
list_bandFreq = [1,4; 4,8; 8,13; 13,30; 30,48; ...  % Brookes et al. 2011 PNAS; Hall et al. 2014 Neuroimage
  1,48];
list_bandNames = {'delta','theta','alpha','beta','lGamma', ...
  'broadband'};

%% epoch
%% ------------------------------------------------------------------------
doEpoch = false; %% continuofalseus vs. epoch
switch doEpoch; case true; epochPrefix = 'e'; case false; epochPrefix = ''; end

%% crop
%% ------------------------------------------------------------------------
startSample = 20001; %20.409s is earliest onset in SMT
endSample   = 542000; %min(length(allSubsAcquisitionLengths))

%% Orthogonalisation (adjust for source leakage)
%% -------------------------false-----------------------------------------------
doOrthog = true; %must be false unless OSL or Schaefer atlas ROIs

%% parellelise
%% ------------------------------------------------------------------------
%par(16)

%% Pipeline
%% ========================================================================

%% Crop, Filter (No Downsample)
%% ------------------------------------------------------------------------
if ~done_crop
  parfor s = 1:nSubs;  CCID = CCIDList{s};  subDir = fullfile(rootDir,'data','pp',['sub-',CCID]);
    
    D = spm_eeg_load(fullfile(subDir,...
      ['', ...
      'spm12_mf2pt2_sub-',CCID,'_ses-rest_task-rest_meg-1.mat']));
    
    % Crop (discard initial 20s (before HPI & earliest smt onset) & cut to min(nSamples) across subjects
    S = [];
    S.D = D;
    S.timewin = [startSample endSample];
    freqwin = [-inf inf];
    channels = 'all';
    prefix = 'p';
    D = spm_eeg_crop(S);
    
    % Down-sample to 200 Hz (from 1000)
    S               = [];
    S.D             = D;
    S.fsample_new   = 200;
    S.prefix        = 'd';
    D               = spm_eeg_downsample(S);
    if ~keepdata, delete(S.D); end
    
    % High-pass filter above 1 Hz
    S = [];
    S.D = D;
    S.type = 'butterworth';
    S.band = 'high';
    S.freq = 1; % Cutoff frequency
    S.dir = 'twopass';
    S.order = 5;
    S.prefix = 'f';
    D = spm_eeg_filter(S);
    if ~keepdata, delete(S.D); end
    
    % Low-pass filter below 49Hz
    S = [];
    S.D = D;
    S.type = 'butterworth';
    S.band = 'low';
    S.freq = 48; % Cutoff frequency
    S.dir = 'twopass';
    S.order = 5;
    S.prefix = 'f';
    D = spm_eeg_filter(S);
    if ~keepdata, delete(S.D); end
  end
end

%% Epoching, Artefact detection, Normalise Sensors
%% ------------------------------------------------------------------------
if ~done_epoch
  parfor s = 1:nSubs;  CCID = CCIDList{s};  subDir = fullfile(rootDir,'data','pp',['sub-',CCID]);
    
    D = spm_eeg_load(fullfile(subDir,...
      ['ffdp', ...
      'spm12_mf2pt2_sub-',CCID,'_ses-rest_task-rest_meg-1.mat']));
    
    %% ? 2s Epochs ?
    if doEpoch
      time = 2; %Epoch length in sec
      EpochLength = time * D.fsample; % in samples
      t = [1:EpochLength:(D.nsamples-EpochLength)]';
      nt = length(t);
      S = [];
      S.D = D;
      S.trl = [t t+EpochLength-1 zeros(nt,1)];
      S.conditionlabels = repmat({'EYES_CLOSED'},1,nt);
      S.prefix= 'e';
      S.bc = 0;
      D = spm_eeg_epochs(S);
      if ~keepdata, delete(S.D); end
    end
    
    %% OSL artefact detection
    D = osl_detect_artefacts(D,'modalities',unique(D.chantype(D.indchantype('MEGANY'))),'badchannels',false);
    D.save;
    
    saveNBadTrials(D,subDir,doEpoch);
    
    %% Normalise sensors (equal their beamform contributions)
    S = [];
    S.D = D;
    S.datatype = 'neuromag';
    D = osl_normalise_sensor_data(S);
    D.save;
    
  end
end

%% Coregistration
%% ------------------------------------------------------------------------
if ~done_coreg
  for s = 441:449;  CCID = CCIDList{s};  subDir = fullfile(rootDir,'data','pp',['sub-',CCID]);
    disp(sprintf('s=%d %s',s,CCID));
    D = spm_eeg_load(fullfile(subDir,...
      [epochPrefix, 'ffdp', ...
      'spm12_mf2pt2_sub-',CCID,'_ses-rest_task-rest_meg-1.mat']));
    
    %% Forward Modelling
    try D = rmfield(D,'inv'); catch; end
    
    S   = [];
    S.D = D;
    S.mri = fullfile(subDir,...
      [CCID,'.nii']);
    
    %% Deal with MRI
    [F,fid] = saveFid_DifferenceToDP(...
      subDir,CCID,S); % Get fiducial json info (mm) (& save difference to DP)
    
    S.useheadshape      = 1;
    S.use_rhino         = 1;
    S.forward_meg       = 'Single Shell';
    S.fid.label.nasion  = 'Nasion'; S.fid.label.lpa = 'LPA'; S.fid.label.rpa = 'RPA';
    S.fid.coords.nasion =  fid.BIDS.mm.Nasion(1:3)';
    S.fid.coords.lpa    =  fid.BIDS.mm.LPA(1:3)';
    S.fid.coords.rpa    =  fid.BIDS.mm.RPA(1:3)';
    S.fid.coordsys      =  'Native';
    D=osl_headmodel(S);
    D.save;
    
    %% Check registration
    checkFidDist_DP_RT(D,subDir); %Roni/Darren
    %checkFidError(D,fid,subDir);  %% FIX THIS
  end
end

%% Beamforming
%% ------------------------------------------------------------------------
%% 1. Bandpass to broadband, 
%% 2. Beamform to broadband (roiOperations bandpasses to desired freq band)
if ~done_beamform
  parfor s = 1:nSubs;  CCID = CCIDList{s};  subDir = fullfile(rootDir,'data','pp',['sub-',CCID]);
    
    %% link D to ROI subDir
    subDir_ROI = fullfile(subDir,['ROIs-',descript_roisName]); mkdir(subDir_ROI);
    
    cmdStr = sprintf('/usr/bin/ln -s %s %s',...
      fullfile(subDir,...
      [epochPrefix,'ffdp',...
      'spm12_mf2pt2_sub-',CCID,'_ses-rest_task-rest_meg-1.mat']),...
      fullfile(subDir_ROI,...
      [epochPrefix,'ffdp',...
      'spm12_mf2pt2_sub-',CCID,'_ses-rest_task-rest_meg-1.mat'])...
      )
    system(cmdStr)
    
    cmdStr = sprintf('/usr/bin/ln -s %s %s',...
      fullfile(subDir,...
      [epochPrefix,'ffdp',...
      'spm12_mf2pt2_sub-',CCID,'_ses-rest_task-rest_meg-1.dat']),...
      fullfile(subDir_ROI,...
      [epochPrefix,'ffdp',...
      'spm12_mf2pt2_sub-',CCID,'_ses-rest_task-rest_meg-1.dat'])...
      )
    system(cmdStr)
    
    
    D = spm_eeg_load(fullfile(subDir_ROI,...
      [epochPrefix,'ffdp', ...
      'spm12_mf2pt2_sub-',CCID,'_ses-rest_task-rest_meg-1.mat']));
    D0 = D;
    
    idxBand = contain(list_bandNames,'broadband');
    
    for bandN = idxBand
      bandName = list_bandNames{bandN};
      bandFreq = list_bandFreq(bandN,:);
      
      if ~exist(fullfile(subDir_ROI,...
          ['note_beamformDone_',bandName,'.txt']),'file')
        
        try
          %% Source-localisation
          S                   = [];
          switch doEpoch
            case true
              S.timespan = [0 inf];
            case false
              S.timespan = [(startSample/1000) (endSample/1000)]; %in secs
          end
          S.modalities        = {'MEG','MEGPLANAR'}; %meg = magnometer  /  gradiometer = megplanar
          S.fuse              = 'all';
          S.pca_order         = 64;
          S.type              = 'Scalar';
          S.inverse_method    = 'beamform';
          S.prefix            = [bandName,'_'];
          mni_coords = p.template_coordinates; %native >> MNI
          D = osl_inverse_model(D,mni_coords,S);
          
          D = ROInets.get_node_tcs(D,p.to_matrix(p.binarize),'pca');
          D.save;
          
          writeNoteFile(subDir_ROI,sprintf('note_beamformDone_%s',bandName));
        catch
          writeNoteFile(subDir_ROI,sprintf('note_beamformFailed_%s',bandName));
        end
      else
        fprintf('Beamform already done:\n%s\n%s\n%s\n\n',CCID,bandName,subDir_ROI);
      end
    end
    try rmdir(fullfile(subDir_ROI,'osl_bf_temp_*'),'s'); catch; end
  end
end

%% Hilbert Amplitude Envelope Correlations
%% ------------------------------------------------------------------------
%% restart Schaefer: !rm data/pp/sub-CC*/ROIs-Schaefer_100parcels_7networks/*Schaefer*.* -f
if ~done_roiOperation
  parfor s = 1:nSubs;  CCID = CCIDList{s};  subDir = fullfile(rootDir,'data','pp',['sub-',CCID]);
    
    subDir_ROI = fullfile(subDir,['ROIs-',descript_roisName]); mkdir(subDir_ROI);
        
    idxBand = contain(list_bandNames,'broadband'); %to load
    idxBandName = list_bandNames{idxBand};
    
    try
      D = spm_eeg_load(fullfile(subDir_ROI,...
        [idxBandName,'_',epochPrefix,'ffdp', ...
        'spm12_mf2pt2_sub-',CCID,'_ses-rest_task-rest_meg-1.mat']));
      
      for bandN = 1:length(list_bandNames)
        bandName = list_bandNames{bandN};
        bandFreq = list_bandFreq(bandN,:);
        fprintf(['%s\nBeamform band file is: %s\n'...
          'roiOperation.m will Filter this source localised file to: %s [Freq: %s]\n'],...
          CCID,idxBandName,bandName,num2str(bandFreq))
        
        %% roiOperation (epoch or continuous)
        if doEpoch
          %roiOperation_epoch(D,y,roiLabels,bandName,bandFreq,CCID,subDir_ROI); % FIX!! (or better, adapt roiOperation for either)
        else %continuous

          roiOperation(D,bandName,bandFreq,descript_roiOrder,descript_roisName,...
            doOrthog,...
            CCID,subDir_ROI);
        end
      end
      
    catch
      fprintf('failed - perhaps missing beamform output file: %s\n',CCID)
    end
  end
end


if ~done_plotGroup
  try
    %% Group Correlation Matrix
    %% ------------------------------------------------------------------------
    store_groupCorrMat(descript_roisName,descript_roiOrder,doOrthog)
    
    %% System Segregation (associationOnly
    %% ------------------------------------------------------------------------
    computeSystemSegregation(descript_roisName,descript_roiOrder,doOrthog)
    
    %% Nicer SyS plot in R/plot_sys.R
  catch
    fprintf('failed to plot group results')
  end
end

return

%% ========================================================================
%% ADDITIONAL: CHECKS
%% ========================================================================
%% Clean up
%% ------------------------------------------------------------------------
!rm data/pp/*/sub*/*/osl_bf_temp* -rf

%% ------------------
%% CHECK: Whose finished?
%% ------------------
load('CCIDList.mat','CCIDList')

%% Craddock
%Part 1
!ls data/pp/craddock/sub-CC*/ffdpspm12_mf2pt2_sub-CC*_ses-rest_task-rest_meg-1.mat | wc -l
%Part 2
%only if epoched %!ls data/pp/craddock/sub-CC*/effdpspm12_mf2pt2_sub-CC*_ses-rest_task-rest_meg-1.mat | wc -l
%Part 3
!ls data/pp/craddock/sub-CC*/check_fDist_DP_RT.mat | wc -l
%Part 4 - broadband
!ls data/pp/craddock/sub-CC*/note_beamformDone_broadband.txt | wc -l
!ls data/pp/craddock/sub-CC*/note_beamformFailed_broadband.txt | wc -l
%Part 5 - hilbEnv
!ls data/pp/sub-CC*/ROIs-craddock/hilbertEnvCorr_band-delta_roiOrder-byNetwork.mat | wc -l
!ls data/pp/sub-CC*/ROIs-craddock/hilbertEnvCorr_band-theta_roiOrder-byNetwork.mat | wc -l
!ls data/pp/sub-CC*/ROIs-craddock/hilbertEnvCorr_band-alpha_roiOrder-byNetwork.mat | wc -l
!ls data/pp/sub-CC*/ROIs-craddock/hilbertEnvCorr_band-beta_roiOrder-byNetwork.mat | wc -l
!ls data/pp/sub-CC*/ROIs-craddock/hilbertEnvCorr_band-lGamma_roiOrder-byNetwork.mat | wc -l
!ls data/pp/sub-CC*/ROIs-craddock/hilbertEnvCorr_band-broadband_roiOrder-byNetwork.mat | wc -l
!ls data/pp/sub-CC*/ROIs-craddock/hilbertEnvCorr_band-delta_roiOrder-lateralised.mat | wc -l


%% ------------------
%% CHECK: nSpikes (predicted by age?)
%% ------------------
load('CCIDList.mat')
for bandN = 1:length(list_bandNames)
  
  bandName = list_bandNames{bandN};

  DAT = [];
  DAT.SessionList = {
    'tmpD',['data/pp/',descript_roisName,'/sub-<CCID>/check_nSpikes_',bandName,'.mat']
    };
  DAT = CCQuery_CheckFiles(DAT);
  
  clear tmpD;
  for s = 1:length(DAT.SubCCIDc)
    fN = DAT.FileNames.tmpD{s};
    if exist(fN,'file'); load(fN)

      tmpD(s) = check.nSpikesFilledByFilter.n;
    else
      tmpD(s) = nan;
    end
    
  end
  cmdStr = sprintf('nSpikes.%s = tmpD;',bandName);
  eval(cmdStr);
  
end
for s = 1:length(nSpikes.delta)
  nSpikes.meanAllBands(s) = nanmean ( [ ...
    nSpikes.delta(s), ...
    nSpikes.theta(s), ...
    nSpikes.alpha(s), ...
    nSpikes.beta(s), ...
    nSpikes.lGamma(s) ...
    ] );
end

I = LoadSubIDs;
plotRegression(nSpikes.delta',I.Age,'nSpikes','Age',[2,4,1],'delta')
plotRegression(nSpikes.theta',I.Age,'nSpikes','Age',[2,4,2],'theta')
plotRegression(nSpikes.alpha',I.Age,'nSpikes','Age',[2,4,3],'alpha')
plotRegression(nSpikes.beta',I.Age,'nSpikes','Age',[2,4,4],'beta')
plotRegression(nSpikes.lGamma',I.Age,'nSpikes','Age',[2,4,5],'lGamma')
plotRegression(nSpikes.broadband',I.Age,'nSpikes','Age',[2,4,6],'broadband')
plotRegression(nSpikes.meanAllBands',I.Age,'nSpikes','Age',[2,4,7],'meanAllBands')


%% ------------------
%% CHECK: VIEW DATA
%% ------------------
y = D(:,:,:); %D(channels, samples, trials)
% size(y)
% plot(y(1,:))
% plot(y(1,1:1201))

figure('position',[100,100,1200,1200])
for chanN = 1:39
  subplot(5,8,chanN)
  p1 = plot(y(chanN,:,1));
  p1.Color(4) = 0.25;
end

y = D(:,:);
y = y(:,good_samples(D))
 