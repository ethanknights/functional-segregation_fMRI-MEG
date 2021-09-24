%% Purpose:
%% Extract craddock atlas ROI timeseries & compute system segregation (SyS)
%% ROIs assigned to 1 of 16 networks (Geerligs et al. 2015).
%% Compute SyS for association networks (i.e. > effects Chan et al. 2014).
%%
%% Version Notes:
%% - Using DARTEL normalised images 
%% (i.e. no wavelet despiked images. Instead spikes identified in GLM)
%%
%% - Using craddock ROIs in a 'byNetwork' order
%% (i.e. the .nii is rewritten in new order. See end of: setupAtlas.m)
%%
%% Ethan Knights
%% ========================================================================

%% ========================================================================
%% Set Paths & Switches
%% ========================================================================
qSPM %start spm fmri

clear; close all
rootDir = pwd;
outDir = 'data'; mkdir(outDir)

%% Choose atlas (this is for outDir only atm)
% atlasName = 'power5mm';
atlasName = 'craddock'; %i.e. craddock

%% ========================================================================
%% Get raw cog Data & imaging filenames % i.e. put data in 'd'
%% ========================================================================

%% 000. Read Chan et al. 2018 neubiolAging + add neuroimaging filenames
taskDir = fullfile(outDir,'rawData');
try
  load(fullfile(taskDir,'rawData.mat'),'d')
catch
  storeRawData(taskDir)
  load(fullfile(taskDir,'rawData.mat'),'d')
end

%% 001. Setup the atlas
taskDir = fullfile(outDir,'001_getAtlas',atlasName);
try
   load(fullfile(taskDir,'atlasInfo.mat'),'atlasInfo')
catch
  setupAtlas(taskDir,atlasName)
  load(fullfile(taskDir,'atlasInfo.mat'),'atlasInfo')
end


%% 002. Extract ROI Data & run GLM
taskDir = fullfile(outDir,'002_getRestingStateFC',atlasName);
try
  %load(fullfile(rootDir,taskDir,'data',atlasName,'roi_extract-y.mat'),'y') %rois x subjects (261 volumes)
  load(fullfile(taskDir,'connectivity-betaMatrix.mat'),'corrM'); %subjects x roi x roi (already removed NaN ROIs)
catch
  extractROIwrapper(taskDir,d,atlasInfo)
  load(fullfile(taskDir,'connectivity-betaMatrix.mat'),'corrM'); %subjects x roi x roi (already removed NaN ROIs)
end

clear atlasInfo   %to avoid confusion with corrM.atlasInfo



%% 003. Discard ROIs if poor coverage
% taskDir = fullfile('003_discardROIs');
% try
%   load(fullfile(rootDir,taskDir,'data',atlasName,'connectivity-betaMatrix.mat'),'corrM') %subjects x roi x roi (already removed NaN ROIs)
% catch
%   cd(fullfile(rootDir,taskDir))
%   run_thisStep(rootDir,d,corrM,y)
%   cd(rootDir)
% end
%


%% 004. Compute system segregation (Chan et al. 2014)
taskDir = fullfile(outDir,'004_computeSyS',atlasName);
%[W,B,S] = computeSystemSegregation(taskDir,corrM);
[W,B,S] = computeSystemSegregation2_associationOnly(taskDir,corrM);
plot_SyS(taskDir) %% Nicer SyS plot




return




% %% 005. Store System Segregation for LEQ only...
% DirToWriteTo = 'output_SyS_Linda16_associationOnly';
% mkdir(DirToWriteTo);
% [d,noMRI_d] = storeData(rootDir,DirToWriteTo,S,corrM);
