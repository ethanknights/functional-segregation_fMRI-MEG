

%%=========================================================================
%% REST
task = 'rest'; %Set this - to match string in megdata/CCID/date/<session>
%%=========================================================================

clear; tmpDir = 'tmp'; try rmdir(tmpDir,'s'); catch; end; mkdir(tmpDir);


[dDir,CCIDList,uniqueCCIDList] = identifySubjectDicoms(task);

%% Examine datasets for issues
for s = 1:length(uniqueCCIDList); CCID = uniqueCCIDList{s};
  idx{s} = find(contains(dDir,CCID));
  if length(idx{s}) ~= 1
    fprintf('s=%d: unexpected #files found. Will check which to use and hardcode fix:\nCC%s\nUse: dDir(idx{%d})\n',s,CCID,s)
  end
end
%% Problem subjects: du -skh shows both subs have 2 files each of similar size. 
%% So actually acquired twice? Use last (via MNE-BIDS)
% dDir(idx{135})
%     {'/megdata/camcan/camcan_two/meg13_0461_cc420241/131024/rest_raw.fif'}
%     {'/megdata/camcan/camcan_two/meg14_0302_cc420241/140710/rest_raw.fif'}
% dDir(idx{243})
%     {'/megdata/camcan/camcan_two/meg13_0328_cc720329/130729/rest_raw.fif'}
%     {'/megdata/camcan/camcan_two/meg13_0396_cc720329/130909/rest_raw.fif'}
%

%% Dump .fif's to ./tmp
parfor s = 1:length(dDir); CCID = CCIDList{s};  fN = split(dDir{s},'/');
  subDir_root = fullfile(tmpDir,['sub-CC',CCID]); mkdir(subDir_root);
  %subDir = fullfile(subDir_root,['ses-',task],'meg'); mkdir(subDir);
  copyfile( dDir{s}, fullfile(subDir_root,[char(fN(end-1)),'_',char(fN(end))]) )
end

%- Remove some subjects who fail in MNE-BIDS -%
% scrapSubsDir = fullfile(newBidsDirRoot,'scrapSubs')
% mkdir(scrapSubsDir)
% 
% mkdir(fullfile(scrapSubsDir,'sub-CC122016'))
% movefile(fullfile(newBidsDirRoot,'sub-CC122016/ses-smt'),fullfile(scrapSubsDir,'sub-CC122016')) %raw data corrupt



%% Use MNE-BIDS to create proper BIDS (with event files etc.)
%% Run these scripts:
%% Ensure terminal matlab was already loaded with:
% conda activate --stack mne0.21
% !python MNE-BIDS_rest.py
% Once done!: rmdir(tmpDir,'s')



%---- fix SMT/Passive event files ----%
%%Run these script:
% fixEvents_smt
% fixEvents_passive


%% generate ./BIDS 

%% TARGET:
%% ls /imaging/camcan/cc700/meg/pipeline/release005/BIDSsep/rest/sub-CC110033/ses-rest/meg/sub-CC110033_ses-rest_coordsystem.json
%% BIDSsep/rest/sub-CC110033/ses-rest/meg/sub-CC110033_ses-rest_coordsystem.json


% outDir = 'BIDS'; mkdir(outDir);

%   
%   subDir_root = fullfile(outDir,['sub-CC',CCID]); mkdir(subDir_root);
%   subDir = fullfile(subDir_root,['ses-',task],'meg'); mkdir(subDir);
% 
%   
%   
% end



%% FUNCTIONS
%%=========================================================================

function [dDir,CCIDnum,uniqueCCID,idx] = identifySubjectDicoms(task)
%% task is a string of series name like 'SNG':
%!ls -d /mridata/camcan280/*/*/*SNG/ > dicomfN.txt
%uniqueCCID output is important for BIDS conversion

if ~exist(sprintf('dicomfN_%s.txt',task),'file')
    cmdStr = sprintf('ls -d /megdata/camcan/camcan_two/*/*/%s_raw.fif > rawDatafN_%s.txt',task,task); %get all dirs per task
    system(cmdStr)
end
fid = fopen(sprintf('rawDatafN_%s.txt',task)); tmp = textscan(fid,'%s','delimiter','\n'); fclose(fid); %read them
dDir = tmp{:};

%% re-order numerically via CCIDnum (just for preference)
[CCIDnum,idx] = sort(cellfun(@strTrimCell,dDir,'UniformOutput',0));
dDir = dDir(idx);

%% get the unique CCIDs
idx = [];
[uniqueCCID,idx] = unique(CCIDnum);

end


function x = strTrimCell(x)
x = x(41:46); %idx for meg CCID in raw data path
end

% function rmBadDirs(idx,FullCCIDList,task,BIDSRoot)
% 
% for s = 1:length(idx)
%     fN = sprintf('%s/sub-CC%s/ses-%s/',BIDSRoot,num2str(FullCCIDList(idx(s))),task);
%     try
%         rmdir(fN,'s')
%         fprintf('Deleted: %s \n',fN)
%     catch
%         fprintf('Skipping deletion as doesnt exist: %s \n',fN) %i.e. already deleted in a rerun?
%     end
% end
% 
% end

