function [y,roiLabels,t] = reorder_craddock_byNetwork(orig_y,orig_t)

%% Provide original data & table incl. 2 headers: networkName, networkIdx
%% output is the new y data, new labels and a new table (that holds all info)
%% ========================================================================

%% specify new order
% alphabetical is messy:
% uniqueNetworks = unique(labels); 

%Predetermined:
uniqueNetworks = ...
  {'AI';'DAN';'DMN';'FEN';'FPCN';'VAN';'cingulate';'precuneus';'temporal';... %association
  'basal ganglia';'brainstem';'cerebellum';'thalamus';... %subcortical
  'auditory';'SMN';'visual';... %sensory
  'noNetwork'}; %other
  
%% gather new order
idx = [];
for i = 1:length(uniqueNetworks);  currNetStr = uniqueNetworks{i};
  idx{i} = find(strcmp(currNetStr,orig_t.networkName));
end
idx2 = vertcat(idx{:});

%% rebuild table
t = orig_t(idx2,:);

%% for convenience, key stuff
y = orig_y(idx2,:);
roiLabels = t.networkName;

%% save (so dont need ot rerun function...)
% idx = idx2; save('reorderIdx_atlas-craddock_order-byNetwork_nRois-835.mat','idx')