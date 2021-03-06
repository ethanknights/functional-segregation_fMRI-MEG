%% Purpose:
%% Create symlinks to MEG/T1's in ./data/BIDSsep
%%
%% 1. Create symlinks to:
%% - SMT AA data (i.e. SMT maxfiltered, move compensation)
%% - T1w (NOT DEFACED) / BIDS JSONs (for fiducials)
%% - For SMT: MNE-BIDS events files
%% 2. Save CCIDList.mat (CCIDList + age)

clear

root_outDir = 'data'; mkdir(root_outDir)

%% Symlink BIDS MEG SMT AA dir
sourceDir = ['/imaging/camcan/sandbox/ek03/fixCC280/CC280_BIDS_MEG/rest/AA_MNE-BIDS/data/', ...
  'BIDS_derivatives_rest/AA_movecomp/aamod_meg_convert_00002/'];
outDir = fullfile(root_outDir,'AA_movecomp'); mkdir(outDir)

cmdStr = sprintf('lndir.sh %s %s',sourceDir,outDir)
system(cmdStr);

%% get CCIDList
CCIDList = [];
nSubs = [];

DAT = [];
DAT.SelectFirstFile = 1; %avoid '_wds.nii' for norm_write_dartel_masked
DAT.SessionList = {
  'epi',  fullfile(outDir,'sub-<CCID>/spm12_mf2pt2_sub-<CCID>_ses-rest_task-rest_meg-1.mat');
  };
DAT = CCQuery_CheckFiles(DAT);

CCIDList = DAT.SubCCIDc(DAT.FileCheck);
fN = DAT.FileNames.epi(DAT.FileCheck);

nSubs = length(CCIDList);

%% Grab T1s (NOT DEFACED, FOR NASION)
DAT = [];
DAT.SelectFirstFile = 1;
DAT.SessionList = {
't1w', '/imaging/camcan/cc700/mri/pipeline/release004/data/aamod_convert_structural_00001/<CCID>/structurals/sMR1*.nii' %non-defaced
'json', '/imaging/camcan/cc700/mri/pipeline/release004/BIDS_20190411/anat/sub-<CCID>/anat/*_T1w.json' 
%%USING ORIG CC700 - NOT THESE CC280 T1w's: (FIDS NOT IN JSON)% 't1w', '/imaging/camcan/cc280/mri/pipeline/release004/BIDSsep/archive/non-defaced_structurals/sub-<CC280ID>/anat/*.nii.gz' %non-defaced
%%USING ORIG CC700 - NOT THESE CC280 T1w's: (FIDS NOT IN JSON)% 'json', '/imaging/camcan/cc280/mri/pipeline/release004/BIDSsep/archive/non-defaced_structurals/sub-<CC280ID>/anat/*.json' %non-defaced
};
DAT = CCQuery_CheckFiles(DAT);
parfor s = 1:length(CCIDList);  CCID = CCIDList{s};  idx = contain(CCID,DAT.SubCCIDc);
  %% check T1w and json (fid) exist
  check(s) = all(DAT.FileCheck(idx,:),2);
  
  if ~check(s) %no T1
    fprintf('Deleting MEG dir because T1w and/or json missing:');
    destDir = [outDir,'/','sub-',CCID]
    rmdir(destDir,'s')
  else
    fprintf('Symlink t1w & json to:')
    destDir = [outDir,'/','sub-',CCID]
    cmdStr = sprintf('/usr/bin/cp -sf %s %s',DAT.FileNames.t1w{idx},fullfile(destDir,[CCID,'.nii']))
    system(cmdStr);
    cmdStr = sprintf('/usr/bin/cp -sf %s %s',DAT.FileNames.json{idx},fullfile(destDir,[CCID,'.json']))
    system(cmdStr);
  end
end 


%% Finally save CCIDList and ages for later
CCIDList = [];
age = [];
I = LoadSubIDs;
CCIDList = dir(fullfile(outDir,'sub-CC*')); %update CCIDs
CCIDList = {CCIDList.name}';
CCIDList = cellfun(@(x) x(5:end), CCIDList, 'Uniform', 0);
idx = [];
for s = 1:length(CCIDList);  CCID = CCIDList{s}
  tmp = find(contains(I.cc280.SubCCIDc,CCID))
  if isempty(tmp)
    idx(s) = nan;
  else
    idx(s) = tmp;
  end
end
%% Some missing!
missingIdx = find(isnan(idx)); CCIDList(missingIdx)
% ans =
% 
%   5??1 cell array
% 
%     {'CC120326'}
%     {'CC420486'}
%     {'CC420766'}
%     {'CC520203'}
%     {'CC610932'}
%% These certainly exist , maybe DP ignored from query purposefully? 
% ls /megdata/camcan/camcan_two/*cc120326/*
% /imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG_cc280
% mmn_raw.fif  rest_raw.fif  scenerep_raw.fif  sng_run1_raw.fif  sng_run2_raw.fif
% ls /megdata/camcan/camcan_two/*cc420486/*
% /imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG_cc280
% mmn_raw.fif  rest_raw.fif  scenerep_raw.fif  sng_run1_raw.fif  sng_run2_raw.fif
% ls /megdata/camcan/camcan_two/*cc420766/*
% /imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG_cc280
% picnaming_raw.fif  syntask_run1_raw.fif  wordrecog_raw.fif
% rest_raw.fif	   syntask_run2_raw.fif
% ls /megdata/camcan/camcan_two/*cc520203/*
% /imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG_cc280
% picnaming_raw.fif  syntask_run1_raw.fif  wordrecog_raw.fif
% rest_raw.fif	   syntask_run2_raw.fif
% ls /megdata/camcan/camcan_two/*cc610932/*
% /imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG_cc280
% mmn_raw.fif  rest_raw.fif  scenerep_raw.fif  sng_run1_raw.fif  sng_run2_raw.fif
%% (Maybe they're typo CCIDs? as they dont have data from CC700 either):
%/imaging/camcan/cc700/meg/pipeline/release004/data/aamod_meg_get_fif_00001/CC610932
%
%% Will delte symlinks to these for now (for purpose of this analysis). 
%% They still exist in BIDS, so need to find if proper cohort member + ages later!
!rm -rf data/*/sub-CC120326
!rm -rf data/*/sub-CC420486
!rm -rf data/*/sub-CC420766
!rm -rf data/*/sub-CC520203
!rm -rf data/*/sub-CC610932

%% regen CCIDList
CCIDList = [];
CCIDList = dir(fullfile(outDir,'sub-CC*')); %update CCIDs
CCIDList = {CCIDList.name}';
CCIDList = cellfun(@(x) x(5:end), CCIDList, 'Uniform', 0);
age = cell2mat(cellfun(@(x) I.cc280.Age(contain(x,I.cc280.SubCCIDc)), CCIDList, 'Uniform', 0));
age = age';
assert(length(age) == length(CCIDList))
save('CCIDList.mat','CCIDList','age');

%% Important: 
symLinkNewStartingDir

%% === %%
%% GENERAL END
%% === %%

%% ========================================================================
%% Check shortest acquisition length (for Crop end of window)
%% ========================================================================
qOSL %osl_startup

load('CCIDList.mat')
parfor s=1:length(CCIDList); CCID = CCIDList{s};
  D = spm_eeg_load(sprintf(...
    'data/pp/sub-%s/spm12_mf2pt2_sub-%s_ses-rest_task-rest_meg-1.dat',...
    CCID,CCID));
    nSamples(s) = D.nsamples;
end % histogram(nSamples)
[a,b] = sort(nSamples)
%% No subjects being dropped so crop this max nSamples:
fprintf('Min - Max nSamples: %d %d\n',[min(nSamples), max(nSamples)]); %Min - Max nSamples: 319000 483000
