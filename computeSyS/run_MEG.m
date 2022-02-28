clear

list_bandNames = {'delta','theta','alpha','beta','lGamma', ...
  'broadband'};

%% Setup
I = LoadSubIDs;
t = table(I.SubCCIDc',I.Age);
t.Properties.VariableNames = {'CCID','age'};

projectDir = '/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG';
rawDir = 'MEG/data/pp/';
dwDir = fullfile(projectDir,rawDir);

%% ROI Info that corresponds to the [ROI x tS] matrix
tmp = readtable(fullfile(projectDir,'MEG/ROIs/Schaefer/Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm_labels.txt'));
%to drop unneeded ROIs before corrMat:
roi_str = tmp.Var2;
%to calculate SyS
roi_networkIdx = tmp.Var6;
clear tmp


%% expected number of ROIs (after potneially dropping any) to assert later
expected_nROIs = 64;
%expected_ntS = []; %cant determine for MEG!

%% Correlation method (for netmats) e.g.,'corr', 'ridgep'
method_corr = 'corr';
%method_corr = 'ridgep';

%% DescriptName (prefix for SyS column names)
modality = 'MEG';
atlasName = 'schaefer';

for band = 1:length(list_bandNames); bandName = list_bandNames{band}
  descriptStr = [modality,'_',bandName,'_',atlasName,'_',method_corr];
  doMEG %create table t
  writetable(t,sprintf('csv/t_%s.csv',descriptStr))
end
