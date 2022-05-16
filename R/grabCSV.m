%% Copy .csv files from SyS matlab pipeline to this R analysis directory
%% ========================================================================
clear

outDir = 'csv'; mkdir csv
projectDir = ...
  '/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/';
projectDir_SMT = ...
  '/imaging/camcan/sandbox/ek03/projects/functional-segregation_SMT/rest_pipeline/';


%% No Global Signal
fN = fullfile(projectDir,'computeSyS_craddock_noGlobalSignal/csv/merged_t.csv')
oN = fullfile(outDir,'SyS-NoGlobalSignal.csv');
copyfile(fN,oN);

%% With Global Signal
fN = fullfile(projectDir,'computeSyS_craddock/csv/merged_t.csv')
oN = fullfile(outDir,'SyS-WithGlobalSignal.csv');
copyfile(fN,oN);

%% Normalisation
% Use Global Signal (above)

%% Task
%SMT:
fN = fullfile(projectDir_SMT,'computeSyS_craddock/csv/merged_t.csv')
oN = fullfile(outDir,'SyS-SMT.csv');
copyfile(fN,oN);
%Movie:
% TBC!!!


%% Atlas
fN = fullfile(projectDir,'computeSyS/csv/merged_t.csv')
oN = fullfile(outDir,'SyS-Schaefer.csv');
copyfile(fN,oN);
