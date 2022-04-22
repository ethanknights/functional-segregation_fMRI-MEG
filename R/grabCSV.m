%% Copy .csv files from SyS matlab pipeline to this R analysis directory
%% ========================================================================

outDir = 'csv'; mkdir csv
projectDir = '/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/';

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

%% NOT DONE YET