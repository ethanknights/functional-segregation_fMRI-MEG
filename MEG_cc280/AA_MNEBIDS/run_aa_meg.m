%Purpose:
%Run aa for new camcan MNE BIDS i.e. repeat the MEG AA pipeline for each
%session separetely (to make data portal sharing simple).


%Instructions for excluding subjects (due to maxfilter movecomp crashing):
%For each session:
%1. Run AA, with done_firstBranch = 0.
%   This will start AA from the basic no_movecomp branch where maxfilter
%   should not crash.
%2. Once AA crashes in 2nd/3rd branch (movecomp/movecomp_transdef), manually
% add the offending subject's CCID to vector in the relevant
% 'switch sessionforAA' within the Add Subjects section:
%       ~any(subj == [711244,999999]) %vector of sub CCID's who'll fail

clear
close all


%% CHOOSE 1 SESSION FOR AA (not combined because that complicates external sharing on portal)
sessionForAA = 'rest';

done_firstBranch = 0; %0 = run all subjects (e.g. for no_movecomp) | 1 = drop subjects where maxfilter will fail


%==========================================
% Setup
%==========================================
%--- Setup Paths ---%
restoredefaultpath

rootDir = fullfile(pwd,'data'); %must be absolute

addpath('/imaging/camcan/QueryFunction/QueryFun_v1')

aa_path = fullfile('resources','automaticanalysis');
if any(ismember(regexp(path,pathsep,'Split'),aa_path))
else
    addpath(genpath(aa_path))
end
aa_close

BIDSDirRoot = '../create_MNE-BIDS/MNE-BIDS'; %i.e. /imaging/camcan/sandbox/ek03/fixCC280/CC280_BIDS_MEG/rest
BIDSDir = fullfile(BIDSDirRoot);

outDir = fullfile(rootDir,sprintf('BIDS_derivatives_%s',sessionForAA));
mkdir(outDir);

fprintf('AA input:\n%s\nAA output:\n%s\n',BIDSDir,outDir)

%==========================================
% AA
%==========================================

%--- Initialise aa ---%
fprintf('initialising AA session\n');
aa_ver5

%%--- Recipe ---%%
aap = [];
aap = aarecipe('aap_parameters_defaults_CBSU.xml','run_aa_meg_tasklist.xml');

SPM = aas_inittoolbox(aap,'spm');
SPM.load;

%--- Settings ---%
aap=aas_addinitialstream(aap,'channellabels',{'/imaging/henson/users/rh01/VectorView_MAG_GRD_EOG_ECG_STI101.mat'});
aap=aas_addinitialstream(aap,'topography',{'/imaging/henson/users/rh01/Methods/MEGArtifactTemplateTopographies.mat'});

aap = aas_renamestream(aap,'aamod_meg_maxfilt_00001','meg','meeg','input'); 
aap = aas_renamestream(aap,'aamod_meg_maxfilt_00002','meg','meeg','input'); 
aap = aas_renamestream(aap,'aamod_meg_maxfilt_00003','meg','meeg','input'); 
aap = aas_renamestream(aap,'aamod_meg_convert_00003','meg','trans_meg','input'); 

aap.directory_conventions.neuromagdir = '/imaging/local/software/neuromag';

aap.options.wheretoprocess = 'qsub'; %localsingle | qsub | matlab_pct
if strcmp(aap.options.wheretoprocess,'qsub')
    aap.options.aaparallel.numberofworkers = 96;
    aap.options.aaparallel.memory = 8;
    aap.options.aaparallel.walltime = 72;
    aap.options.NIFTI4D = 1;
    aap.options.email = 'ethan.knights@mrc-cbu.cam.ac.uk';
    aap.options.aaworkerGUI = false;
    aap.options.maximumretry = 1;
end


%--- Study info ---%
aap.directory_conventions.rawdatadir = BIDSDir; % The bids parser only supports a single rawdatadir. Pick the one that has bids in it.
aap.acq_details.root = outDir; %so that output is stored in root(see analaysisid next)
aap.directory_conventions.analysisid = 'AA'; %for analysed data


%--- Add Subjects ---%
fileID = fopen(fullfile(BIDSDir,'participants.tsv'));
tmp = textscan(fileID, '%s %s %s %s','delimiter', '\t'); 
fclose(fileID);
headerRow = 1;
for h = 1:length(tmp); headers{h} = tmp{h}{headerRow}; end
CCIDList = tmp{contains(headers,'participant_id')}(headerRow+1:end);
%%check they all exist:
tmp=[];
for s=1:length(CCIDList)
    tmp(s) = exist(fullfile(BIDSDir,CCIDList{s}),'dir');
end
assert(all(tmp == 7),'A CCID is in participants.tsv but not in BIDSDir/<CCID>');

% - meeg
aap.directory_conventions.meegsubjectoutputformat = 'sub-CC%06d';
aap.directory_conventions.rawmeegdatadir = BIDSDir;
% - mri
% aap.directory_conventions.subjectoutputformat = 'sub-CC%06d';
% aap.directory_conventions.rawdatadir = BIDSDir);
aap.directory_conventions.subject_directory_format = 1;

for s = 1:length(CCIDList)
  
  subj = str2double(CCIDList{s}(7:end));
  
  eegacq = cellstr(spm_select('FPListRec',meeg_findvol(aap,subj,'fullpath',true),'.*fif'));
  
  if ~done_firstBranch %just run everyone (e.g. no_movecomp where maxfilter shouldnt fail)
    aap = aas_addsubject(aap,{subj, []},'functional',eegacq);
    fprintf('Added MEG Session: %s\n',cell2mat(aap.acq_details.subjects(s).meegseriesnumbers{:}))
    
    %% To add t1... go back to setupDirs.m & add t1w's to BIDSdir/sub-<CCID>/anat/sub-<CCID>_t1w.nii.gz
    %mriacq = cellstr(spm_select('FPListRec',mri_findvol(aap,subj,'fullpath',true),'.*_ses-01_acq-mp2rage_T1w.nii.gz'));
    %aap = aas_addsubject(aap,{subj subj},'structural',mriacq,'functional',eegacq);
    %fprintf('Added MRI Session: %s\n',cell2mat(aap.acq_details.subjects(s).mriseriesnumbers{s}));
    
  else %if 1stbranch done (no_movecomp), lets drop specific subjects from branches 2/3 who will fail maxfilter for specific sessions
    
    if ~any(subj == [999999]) %vector of sub CCID's who'll fail %only for 3rd branch!?
      aap = aas_addsubject(aap,{subj, []},'functional',eegacq);
      fprintf('Added MEG Session: %s\n',cell2mat(aap.acq_details.subjects(end).meegseriesnumbers{:}))
    else
      fprintf('========= SKIPPING: %s ==========\n',['sub-CC',num2str(subj)])
    end
    
  end
end




%--- Analysis ---%
aa_doprocessing(aap);
aa_report(fullfile(aas_getstudypath(aap),aap.directory_conventions.analysisid));
aas_garbagecollection(aap,true);
cd ../ %back to root!

%% DEBUG:
%  aaq_qsub_debug()

