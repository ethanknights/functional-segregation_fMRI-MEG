parfor s = 1:nSubs;  CCID = CCIDList{s}; 
  
  
subDir = fullfile(rootDir,'data','pp',['sub-',CCID]);

% subDir_old = fullfile('/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG/.snapshot/CBU_working_hours_imaging.2021-09-22_0810',...
%   'data','pp','craddock',['sub-',CCID]);

%dirCont = dir(fullfile(subDir,'hilbertEnv*'))
%dirCont = dir(fullfile(subDir,'note_beamform*'))
dirCont = dir(fullfile(subDir,'check_nSpikes*'))

for f = 1:length(dirCont)
  
  fN = fullfile(dirCont(f).folder,dirCont(f).name)
  
  %% link to ROI subDir
  subDir_ROI = fullfile(subDir,['ROIs-',descript_roisName]);
  
    cmdStr = sprintf('/usr/bin/mv %s %s',...
    fN,...
    subDir_ROI)
  system(cmdStr)
  
%   cmdStr = sprintf('/usr/bin/cp %s %s',...
%     fullfile(subDir_old,...
%     [epochPrefix,'broadband_ffdp',...
%     'spm12_mf2pt2_sub-',CCID,'_ses-rest_task-rest_meg-1.mat']),...
%     subDir_ROI)
%   system(cmdStr)
%   
%   cmdStr = sprintf('/usr/bin/cp %s %s',...
%     fullfile(subDir_old,...
%     [epochPrefix,'broadband_ffdp',...
%     'spm12_mf2pt2_sub-',CCID,'_ses-rest_task-rest_meg-1.dat']),...
%     subDir_ROI)
%   system(cmdStr)
  
end
end