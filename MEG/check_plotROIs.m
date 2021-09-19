%% Plot hilbEnv matrix for subjects in orders of
%% - network (net1, net2 etc)
%% ? - L then R ROI, L then R ROI (using pairs of euclidean closest distance)
%% ==========================================================================

%--- data ---%
rootDir = pwd;
load('CCIDList','CCIDList','age');
nSubs = length(CCIDList);
descript_roisName = 'Craddock_LindaFC';  % 'Craddock_LindaFC_4D' 'OSL_noOverlap';
list_bandNames = {'delta','theta','alpha','beta','lGamma', ...
  'broadband'};

switch descript_roisName
  case 'Craddock_LindaFC'
    atlasInfo = load('/imaging/camcan/sandbox/ek03/projects/connectivity/ROIs/craddock_fromLinda/atlas-craddock_nROIs-724_res-6mm.mat'); atlasInfo = atlasInfo.t2;
end

%% - network (net1, net2 etc)
%% ------------------------------
s = 1;  CCID = CCIDList{s};  subDir = fullfile(rootDir,'data','pp',descript_roisName,['sub-',CCID]);

for bandN = 1:length(list_bandNames)
  
  bandName = list_bandNames{bandN}; fprintf(['%s %s\n'],CCID,bandName);
  
  tmpStruct = load(fullfile(subDir,['hilbertEnvCorr_',bandName,'.mat']));
  y = tmpStruct.corrMat;
  
  y_reorder = [];
  
  labels = tmpStruct.roiLabels;
  order = 1:length(y)
  [~,newOrder] = sort(atlasInfo.networkIdx); % 1 1 1 ... 2 2 2 ... : 16 16 16
  newLabels = tmpStruct.roiLabels(newOrder);
  for i = 1:length(labels)
    y_reorder(i,:) = y(newOrder(i),:);
  end
  labels_corrMat = new_labels; %to save
  y = y_reorder;
 
  
end