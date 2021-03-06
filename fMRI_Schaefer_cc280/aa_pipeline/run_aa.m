%% Purpose:
%% Put Resting state CC280 subjects (+ their structurals) through standard 
%% Cam-CAN MRI/fMRI branches of aa pipeline (from cc700)

function run_aa

clear
close all

%% ========================================================================
%% Setup 
%% ========================================================================

%% Setup Subjects
taskDir = '/imaging/camcan/sandbox/ek03/fixCC280/CC280_BIDS_MRI/create_task_epi/BIDS_Sep/restingstate'; %root BIDS path - fMRI task
Q = dir(fullfile(taskDir,'sub-CC*'));
CCIDList = {Q.name}';
%% All Subjects or subset for debugging?
runSubjects = CCIDList; %runSubjects = CCIDList(1);
CCIDList = runSubjects; 
nSubs = length(CCIDList);
for s = 1:nSubs; CCIDList{s} = CCIDList{s}(5:end); end

%% Setup paths
restoredefaultpath
addpath('/imaging/camcan/QueryFunction/QueryFun_v1')
rootDir = pwd;
aa_path = fullfile(pwd,'release-5.4.0_202008'); %updated ones wont work (toolbox update)
if any(ismember(regexp(path,pathsep,'Split'),aa_path))
else
  addpath(genpath(aa_path))
end 
aa_close
BIDSDir = fullfile(rootDir,'BIDS');


%% Setup ./BIDS
done_createBIDSDir = 0; %copy | symlink relevant data to ./BIDS/
if ~done_createBIDSDir
  try rmdir(BIDSDir,'s'); catch; end; mkdir(BIDSDir)
  parfor s = 1:nSubs
    
    CCID = ['sub-',CCIDList{s}];
    
    subDir = fullfile(BIDSDir,CCID);
    mkdir(subDir)
    
    %Structurals
    mkdir(fullfile(subDir,'anat'))
    tmp_root = '/imaging/camcan/cc280/mri/pipeline/release004/BIDSsep/structurals/';
    source =  fullfile(tmp_root,  CCID,'anat',[CCID,'_T1w.nii.gz']);
    dest =    fullfile(BIDSDir,   CCID,'anat',[CCID,'_T1w.nii.gz']);
    system(sprintf('cp -f %s %s',source,dest));
    source =  fullfile(tmp_root,  CCID,'anat',[CCID,'_T1w.json']);
    dest =    fullfile(BIDSDir,   CCID,'anat',[CCID,'_T1w.json']);
    system(sprintf('cp -f %s %s',source,dest));
    
    %Func
    mkdir(fullfile(subDir,'func'))
    tmp_root = taskDir;
    source =  fullfile(tmp_root,  CCID,'func',[CCID,'_task-RestingState_bold.nii.gz']);
    dest =    fullfile(BIDSDir,   CCID,'func',[CCID,'_task-RestingState_bold.nii.gz']);
    system(sprintf('cp -f %s %s',source,dest));
    source =  fullfile(tmp_root,  CCID,'func',[CCID,'_task-RestingState_bold.json']);
    dest =    fullfile(BIDSDir,   CCID,'func',[CCID,'_task-RestingState_bold.json']);
    system(sprintf('cp -f %s %s',source,dest));
  end
  try
    rmdir(fullfile(BIDSDir,'sub-CC320218'),'s'); %missing anat
    rmdir(fullfile(BIDSDir,'sub-CC610405'),'s'); %missing anat
    rmdir(fullfile(BIDSDir,'sub-CC620164'),'s'); %missing fmri/rest
    rmdir(fullfile(BIDSDir,'sub-CC711158'),'s'); %missing anat
    rmdir(fullfile(BIDSDir,'sub-CC721585'),'s'); %missing anat
  catch
  end
end


%% ========================================================================
%% AA
%% ========================================================================

%% Initialise aa
fprintf('initialising AA session\n');
aa_ver5
aap = [];
aap = aarecipe('aap_parameters_defaults_CBSU.xml','aa_taskList.xml');

aap.options.wheretoprocess = 'qsub'; %qsub | matlab_pct
if strcmp(aap.options.wheretoprocess,'qsub')
  aap.options.aaparallel.numberofworkers = 96;
  aap.options.aaparallel.memory = 8;
  aap.options.aaparallel.walltime = 72;
  aap.options.NIFTI4D = 1;
  aap.options.email = 'ethan.knights@mrc-cbu.cam.a.u';
  aap.options.aaworkerGUI = false;
  aap.options.maximumretry = 1;
end


%% Pipeline customisation
%Paths
aap.directory_conventions.rawdatadir = fullfile(rootDir,'BIDS');% The bids parser only supports a single rawdatadir. Pick the one that has bids in it.
aap.acq_details.root = ''; %so that output is stored in root(see analaysisid next)
aap.directory_conventions.analysisid = fullfile(rootDir,'data'); %for analysed data
aap = aas_processBIDS(aap); %aas_processBIDS(aap,[],{'anat','dwi'}); %not all modalities
%MRI - Segmentation + DARTEL
aap.tasksettings.aamod_norm_write_meanepi_dartel.vox = [3 3 3];
aap.tasksettings.aamod_norm_write_dartel.vox = [3 3 3];
aap.tasksettings.aamod_mask_fromsegment.threshold = 0.8;
%fMRI - slicetiming
aap.tasksettings.aamod_slicetiming.sliceorder= [32:-1:1];
%aap.tasksettings.aamod_slicetiming.autodetectSO = 1; % descending
aap.tasksettings.aamod_slicetiming.refslice = 16;
%fMRI - BWT's WDS
aap.tasksettings.aamod_waveletdespike.maskingthreshold = 0.9;

aap = aas_renamestream(aap,'aamod_mask_fromsegment_00001','reference','meanepi');
aap = aas_renamestream(aap,'aamod_mask_fromsegment_00001','grey','normalised_grey');
aap = aas_renamestream(aap,'aamod_mask_fromsegment_00001','white','normalised_white');
aap = aas_renamestream(aap,'aamod_mask_fromsegment_00001','csf','normalised_csf');

%aap = aas_renamestream(aap,'aamod_norm_write_meanepi_dartel_00001','dartel_templatetomni_xfm','aamod_dartel_createtemplate_00001.dartel_templatetomni_xfm');

%% Analysis
aa_doprocessing(aap);

end