%Purpose:
%Read CR data from Chan et al., 2018 Neuaging and store fMRI filenames
%Main data is stored in d
%
% fMRI data is NOT wavelet despiked, as will use spike covariates during
% modelling

function storeRawData(outDir)

mkdir(outDir)

%---- Read data from Chan et al.m, 2018 ----%
% rawDataDir = fullfile(rootDir,'rawData_Chanetal2018_neuaging');
% rawD = readtable(fullfile(rawDataDir,'LEQ-MRI-N196.csv'));
% d = rawD;

%rawD = readtable(fullfile(rawDataDir,'LEQ-N205.csv')); %no MRI, so probably not useful here
%rawD = readtable(fullfile(rawDataDir,'MA_split_by_question.csv'); %maybe use specific CR items later?



%---- Add neuroimaging filenames to table ----%

%-- Setup filenames --%
% queryStr_fMRI_smoothDespiked = {'fMRI_smoothDespiked', ...
%   'cc700/mri/pipeline/release004/data_fMRI/aamod_waveletdespike_00001/<CCID>/Rest/*_wds.nii'};
queryStr_fMRI_smoothDespiked = {'fMRI_smoothDespiked', ...
   'cc700/mri/pipeline/release004/data_fMRI/aamod_norm_write_dartel_00001/<CCID>/Rest/swauf*.nii'};
   
queryStr_fMRI_smoothDespiked_RP = {'fMRI_smoothDespiked_RP', ...
  'cc700/mri/pipeline/release004/data_fMRI/aamod_realignunwarp_00001/<CCID>/Rest/rp_*.txt'};

queryStr_fMRI_compSignal = {'fMRI_compSignal', ...
  'cc700/mri/pipeline/release004/data_fMRI/aamod_compSignal_00001/<CCID>/Rest/compSignal.mat'};

% queryStr_fMRI_rawBIDS = {'fMRI_rawBIDS', ...
%   'cc700/mri/pipeline/release004/BIDS/sub-<CCID>/sub-<CCID>_task-Rest_bold.nii.gz'};

% queryStr_MEG_parcellated = {'MEG_parcellated', ...
%   'sandbox/ek03/APOE/meg/data2/data/<CCID>/alpha_fmri_d100_parcellation_with_PCC_tighterMay15_v2_6mm_exclusive_bfeffdpspmeeg_*.mat'};

% queryStr_anat = {'anat', ...
% %   'cc700/mri/pipeline/release004/BIDS/sub-<CCID>/anat/sub-<CCID>_T1w.nii.gz'};
%    'cc700/mri/pipeline/release004/data_Mod1mm_smoothed/aamod_structural_smoothsegment_*/<CCID>/structurals/smwc1msMR*.nii'};
%     
% queryStr_freesurfer = {'FS_v6', ...  %Not sure which surface file is needed yet so change that
%   'LifeBrain/freesurfer6-long/FS_Long/subs/<CCID>_cc700.long.<CCID>/surf/lh.area.pial'};

%-- Query --%
DAT = [];
DAT.rootdir = '/imaging/camcan/';
DAT.SessionList = {
  
  %- fMRI Rest -%
  queryStr_fMRI_smoothDespiked{1}, queryStr_fMRI_smoothDespiked{2};
  queryStr_fMRI_smoothDespiked_RP{1}, queryStr_fMRI_smoothDespiked_RP{2};
  queryStr_fMRI_compSignal{1}, queryStr_fMRI_compSignal{2};
  
%   %- MEG Rest -%
%   queryStr_MEG_parcellated{1}, queryStr_MEG_parcellated{2};
%   
%   %- Freesurfer -%
%   queryStr_freesurfer{1}, queryStr_freesurfer{2} %To coregister surface (Chan et al 2018 PNAS)
% 
%   %- Anat -%
%   queryStr_anat{1}, queryStr_anat{2}; %Probly needed for surface coregister
%   
  };
DAT = CCQuery_CheckFiles(DAT);

%-- Put filenames in data table for simplicity later --%
fN_fMRI             = DAT.FileNames.fMRI_smoothDespiked;
fN_fMRI_RP          = DAT.FileNames.fMRI_smoothDespiked_RP;
fN_fMRI_compSignal	= DAT.FileNames.fMRI_compSignal;
% fN_MEG              = DAT.FileNames.MEG_parcellated
% fN_anat             = DAT.FileNames.anat;
% fN_FS               = DAT.FileNames.FS_v6;

I = LoadSubIDs;
d = table(DAT.SubCCIDc');
d.Properties.VariableNames = {'CCID'};
d = appendToTable(I.Age,{'Age'},d);



headers = {'fN_fMRI_Rest','fN_fMRI_Rest_rp','fN_fMRI_Rest_compSignal'}; %,'fN_MEG_OSLParcellation_alpha','fN_FSv6','fN_T1w'};
d = appendToTable([fN_fMRI',fN_fMRI_RP',fN_fMRI_compSignal'], ... ;%,fN_MEG',fN_FS',fN_anat'], ...
  headers,d);

%Drop MEG stuff
% idx = find(strcmp(d.Properties.VariableNames,'fN_MEG_OSLParcellation_alpha'));
% d(:,idx) = [];

headers = {'fN_fMRI_Rest','fN_fMRI_Rest_rp','fN_fMRI_Rest_compSignal'}; %,'fN_FSv6','fN_T1w'};


%-- Drop subjects without every file --%
%could remove this later, but lets keep simple to start
for h = 1:length(headers)
  loc(:,h) = cellfun('isempty', d{:,headers{h}} );
end
idx = any(loc,2);
d(idx,:) = [];


% %-- Trim freesurfer filenames to just the dirName for caret later --%
% for s = 1:height(d)
%   [d.fN_FSv6{s},~] = fileparts(d.fN_FSv6{s});
%   [d.fN_FSv6{s},~] = fileparts(d.fN_FSv6{s});
% end



save(fullfile(outDir,'rawData.mat'),'d');

end