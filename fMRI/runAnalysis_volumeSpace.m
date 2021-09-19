%Purpose:
%Main wrapper script to run RSFC Boundary Mapping analysis
%
%Requisite software/files:
%Caret (fs_LR and downsamping script)
%Connectome workbench (wb)
%Node maps from Wig's Lab


%=========================================================================%
% Set Paths & Switches
%=========================================================================%


% addpath('OSF_utils') %note other users might need to add this path to shell too:
%e.g. in bash before matlab starts: export PATH=$PATH:/Path/To/OSF_utilsDirectory
% addpath /imaging/ek03/toolbox/gifti

clear
rootDir = pwd;

%start spm fmri
spmDir = '/imaging/henson/users/ek03/toolbox/SPM12_v7219';
if any(ismember(regexp(path,pathsep,'Split'),spmDir)); else; addpath(spmDir);
   spm('Defaults','fMRI'); spm_jobman('initcfg'); end 

%Choose atlas from: 'craddock' 'power5mm'
% atlasName = 'power5mm';
atlasName = 'Linda16';

outDir = 'data';
tmpDir = 'tmp';




%=========================================================================%
% Get raw cog Data and imaging filenames % i.e. put data in 'd'
%=========================================================================%

%-- 000. Read Chan et al. 2018 neubiolAging + add neuroimaging filenames --%
taskDir = fullfile(outDir,'rawData');
try
  load(fullfile(taskDir,'rawData.mat'),'d')
catch
  storeRawData(taskDir)
  load(fullfile(taskDir,'rawData.mat'),'d')
end

%-- 001. Setup the atlas --%
taskDir = fullfile(outDir,'001_getAtlas',atlasName);
try
   load(fullfile(taskDir,'atlasInfo.mat'),'atlasInfo')
catch
  setupAtlas(taskDir,d,atlasName)
  load(fullfile(taskDir,'atlasInfo.mat'),'atlasInfo')
end


%-- 002. Extract ROI Data --%
taskDir = fullfile(outDir,'002_getRestingStateFC',atlasName);
try
  %load(fullfile(rootDir,taskDir,'data',atlasName,'roi_extract-y.mat'),'y') %rois x subjects (261 volumes)
  load(fullfile(taskDir,'connectivity-betaMatrix.mat'),'corrM') %subjects x roi x roi (already removed NaN ROIs)
catch
  extractROIwrapper(taskDir,d,atlasInfo)
  load(fullfile(taskDir,'connectivity-betaMatrix.mat'),'corrM') %subjects x roi x roi (already removed NaN ROIs)
end

clear atlasInfo   %to avoid confusion with corrM.atlasInfo



%-- 003. Discard ROIs if poor coverage --%
% taskDir = fullfile('003_discardROIs');
% try
%   load(fullfile(rootDir,taskDir,'data',atlasName,'connectivity-betaMatrix.mat'),'corrM') %subjects x roi x roi (already removed NaN ROIs)
% catch
%   cd(fullfile(rootDir,taskDir))
%   run_thisStep(rootDir,d,corrM,y)
%   cd(rootDir)
% end
% 
% 
%-- 004. Compute system segregation (Chan et al. 2014) --%
taskDir = fullfile('004_computeSystemSegregation',atlasName);
[W,B,S] = computeSystemSegregation(taskDir,corrM);

[W,B,S] = computeSystemSegregation2_associationOnly(taskDir,corrM);

return


%--- 005. Store System Segregation ---%
DirToWriteTo = 'output_SyS_Linda16_associationOnly';
mkdir(DirToWriteTo);
[d,noMRI_d] = storeData(rootDir,DirToWriteTo,S,corrM);
    








