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
queryStr_fMRI_smoothDespiked = {'fMRI_smoothDespiked', ...
  'sandbox/ek03/aa/aa_cc280_rest/data_fMRI/aamod_norm_write_dartel_00001/sub-<CCID>/RestingState/swa*.nii'}; 
queryStr_fMRI_smoothDespiked_RP = {'fMRI_smoothDespiked_RP', ...
 'sandbox/ek03/aa/aa_cc280_rest/data_fMRI/aamod_realign_00001/sub-<CCID>/RestingState/rp_*.txt'};
%% unwarp version, like cc700 (needed fieldmaps in aa)
% queryStr_fMRI_smoothDespiked = {'fMRI_smoothDespiked', ...
%    'cc700/mri/pipeline/release004/data_fMRI/aamod_norm_write_dartel_00001/sub-<CCID>/RestingState/swau*.nii'}; 
% queryStr_fMRI_smoothDespiked_RP = {'fMRI_smoothDespiked_RP', ...
%  'sandbox/ek03/aa/aa_cc280_rest/data_fMRI/aamod_realignunwarp_00001/sub-<CCID>/RestingState/rp_*.txt'};
queryStr_fMRI_compSignal = {'fMRI_compSignal', ...
  'sandbox/ek03/aa/aa_cc280_rest/data_fMRI/aamod_compSignal_00001/sub-<CCID>/RestingState/compSignal.mat'};

%-- Query --%
DAT = [];
DAT.rootdir = '/imaging/camcan/';
DAT.SessionList = {
  queryStr_fMRI_smoothDespiked{1}, queryStr_fMRI_smoothDespiked{2};
  queryStr_fMRI_smoothDespiked_RP{1}, queryStr_fMRI_smoothDespiked_RP{2};
  queryStr_fMRI_compSignal{1}, queryStr_fMRI_compSignal{2};
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


d.Age = cell2mat( cellfun(@(x) I.cc280.Age(contain(x,I.cc280.SubCCIDc)), d.CCID, 'Uniform', 0) );

save(fullfile(outDir,'rawData.mat'),'d');

end