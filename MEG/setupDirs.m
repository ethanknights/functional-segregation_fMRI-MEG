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
sourceDir = ['/imaging/camcan/cc700/meg/pipeline/release005/BIDSsep/', ...
  'derivatives_rest/aa/AA_movecomp/aamod_meg_convert_00002/'];
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
%'t1',
%'/imaging/camcan/cc700/mri/pipeline/release004/BIDS_20190411/anat/sub-<CCID>/anat/*_T1w.nii.gz' %defaced
't1w', '/imaging/camcan/cc700/mri/pipeline/release004/data/aamod_convert_structural_00001/<CCID>/structurals/sMR1*.nii' %non-defaced
'json', '/imaging/camcan/cc700/mri/pipeline/release004/BIDS_20190411/anat/sub-<CCID>/anat/*_T1w.json'
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
end


%% Finally save CCIDList and ages for later
CCIDList = [];
age = [];

I = LoadSubIDs;
CCIDList = dir(fullfile(outDir,'sub-CC*')); %update CCIDs
CCIDList = {CCIDList.name}';
CCIDList = cellfun(@(x) x(5:end), CCIDList, 'Uniform', 0); 
age = cell2mat(cellfun(@(x) I.Age(contain(x,I.SubCCIDc)), CCIDList, 'Uniform', 0));
age = age';
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
end %hist(nSamples)
[a,b] = sort(nSamples)
min(nSamples)
%% Decision - drop 2 very short subjects from rest MEG
% CCIDList(b(1:2))
%    {'CC520775'}
%    {'CC710131'}
!rm -rf data/*/sub-CC520775

!rm -rf data/*/sub-CC710131

%% Generate CCIDList again
a = dir('data/AA_movecomp/sub-CC*');
CCIDList = {a.name}';
CCIDList = cellfun(@(x) x(5:end), CCIDList, 'Uniform', 0); 
I = LoadSubIDs;
age = cell2mat(cellfun(@(x) I.Age(contain(x,I.SubCCIDc)), CCIDList, 'Uniform', 0));
save('CCIDList.mat','CCIDList','age');

nSamples = [];
parfor s=1:length(CCIDList); CCID = CCIDList{s};
  D = spm_eeg_load(sprintf(...
    'data/pp/sub-%s/spm12_mf2pt2_sub-%s_ses-rest_task-rest_meg-1.dat',...
    CCID,CCID));
    nSamples(s) = D.nsamples;
end %hist(nSamples)
fprintf('Min - Max nSamples: %d %d\n',[min(nSamples), max(nSamples)]); %Min - Max nSamples: 542000 1101000
