clear; mkdir csv

%% Setup
I = LoadSubIDs;
t = table(I.SubCCIDc',I.Age);
t.Properties.VariableNames = {'CCID','age'};

projectDir = '/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG';
rawDir = 'fMRI_Schaefer_cc280/data/002_getRestingStateFC/schaefer';
dwDir = fullfile(projectDir,rawDir);

%% ROI Info that corresponds to the [ROI x tS] matrix
tmp = load(fullfile(dwDir,'connectivity-betaMatrix.mat'));
%to drop unneeded ROIs before corrMat:
roi_str = tmp.corrM.atlasInfo.networkLabel_str;
%to calculate SyS
roi_networkIdx = tmp.corrM.atlasInfo.networkLabel_num;
clear tmp


%% expected number of ROIs (after potneially dropping any) to assert later
expected_nROIs = 64;
%expected_ntS = []; %cant determine for MEG!

%% Correlation method (for netmats) e.g.,'corr', 'ridgep'
list_method_corr = {'corr','ridgep'};

%% DescriptName (prefix for SyS column names)
modality = 'fMRI_cc280';
atlasName = 'schaefer';

for meth = 1:length(list_method_corr); method_corr = list_method_corr{meth};
  descriptStr = [modality,'_',atlasName,'_',method_corr];

  %% Setup
  I = LoadSubIDs;
  t = table(I.SubCCIDc',I.Age);
  t.Properties.VariableNames = {'CCID','age'};
  
  dofMRI %create table t
  writetable(t,sprintf('csv/t_%s.csv',descriptStr))
  
end
%% d = readtable(sprintf('csv/t_%s.csv',descriptStr))
