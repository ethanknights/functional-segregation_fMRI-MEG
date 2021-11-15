%% Compute SyS
%%
%% Available:
%% plot_groupCorrMat('craddock','byNetwork')

%% ==========================================================================
function [W,B,S] = computeSystemSegregation(descript_roisName,descript_roiOrder,doOrthog)

%--- data ---%
rootDir = pwd;
load('CCIDList','CCIDList','age');
nSubs = length(CCIDList);
list_bandNames = {'delta','theta','alpha','beta','lGamma', ...
  'broadband'};


rootOutDir = 'data/computeSyS'; mkdir(rootOutDir)
outDir = fullfile(rootOutDir,['ROIs-',descript_roisName]); mkdir(outDir)

%% Get ROI Labels & Reorder
switch descript_roisName
%--------------------------------------------------------------------------
  %========
  case 'Schaefer_100parcels_7networks'
  %========
    [t] = readtable('ROIs/Schaefer/Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm_labels.txt');
    %--------
    switch descript_roiOrder
    %--------
      case 'dropSchaefer'
        reorder_dropSchaefer
    end
    
  %=======
  case 'craddock'
  %=======
    [t] = readtable('ROIs/craddock-ROI-835_resampled-6mm.csv');
    %--------
    switch descript_roiOrder
    %--------
      case 'byNetwork'
        load('reorderIdx_atlas-craddock_order-byNetwork_nRois-835.mat','idx')
        t = t(idx,:);      roiLabels = t.networkName;   roiNetwork = t.networkIdx; %reorder
    end
end


%% loop
%% ------------------------------
%% store mean of all subjects in corrMat.delta, corrMat.theta etc
for b=1:length(list_bandNames); bandName = list_bandNames{b};
  
  fileStr = sprintf('data/pp/sub-CC*/ROIs-%s/hilbertEnvCorr_band-%s_roiOrder-%s_doOrthog-%s.mat',...
    descript_roisName,bandName,descript_roiOrder,num2str(doOrthog));
  dirContents = dir(fileStr);
  nSubs = length(dirContents);
  fprintf('%d subs found for query:\n%s\n',nSubs,fileStr)
  
  corrM = [];
  parfor s = 1:nSubs
    tmpD = parLoad(fullfile(dirContents(s).folder,dirContents(s).name));
    corrM(:,:,s) = tmpD.corrMat;
  end
  
  %% Get networkIdx for calculating SyS
  switch descript_roisName
    
    %=============
    case 'craddock'
    %=============
      %% drop networks (if craddock atlas)
      newLabels = roiLabels;
      newNetworkIdx = roiNetwork;
      %listNetworkStrToDrop = {'noNetwork'};
      listNetworkStrToDrop = {'noNetwork','SMN','auditory','basal ganglia', ...
        'brainstem','cerebellum','thalamus','visual'};
      for n = 1:length(listNetworkStrToDrop)
        idx = contains(newLabels,listNetworkStrToDrop{n});
        corrM(:,idx,:) = []; corrM(idx,:,:) = [];
        newLabels(idx) = [];
        newNetworkIdx(idx) = [];
      end
      %% print number of ROis per network left
      u = unique(newLabels);
      for uu = 1:length(u)
        nRoisPerNetwork(uu) = sum(strcmp(u(uu),newLabels));
        fprintf('nROis for Network: %s %d\n',u{uu},nRoisPerNetwork(uu));
      end
      %% networkIdx
      networkIdx = newNetworkIdx;
      
    %=============
    case 'Schaefer_100parcels_7networks'
    %=============
      networkIdx = t.Var6;
  end

  
  %% WIGG'S VERSION: calculate system segregation
  for s = 1:length(CCIDList)
    
    %Get main data (i.e. subs connectivity matrix & roi labels)
    M = squeeze(corrM(:,:,s));
    Ci = networkIdx;
    nCi = unique(Ci);
    
    Wv = [];
    Bv = [];
    
    for i = 1:length(nCi) % loop through communities
      Wi = Ci == nCi(i); % find index for this system (i.e. within  communitiy)
      Bi = Ci ~= nCi(i); % find index for diff system (i.e. between communitiy)
      
      Wv_temp = M(Wi,Wi); % extract this system
      Bv_temp = M(Wi,Bi); % extract diff system
      
      Wv = [Wv, Wv_temp(logical(triu(ones(sum(Wi)),1)))'];
      Bv = [Bv, Bv_temp(:)'];
    end
    
    W(s) = mean(Wv); % mean this system
    B(s) = mean(Bv); % mean diff system
    S(s) = (W(s)-B(s))/W(s); % system segregation
  end
  
  clear corrM %memory
  
  %% Plots
  plotRegression(S',age)
  title('System segregation - rest FC');
  xlabel('age'); ylabel('mean within - between system')
  outName = fullfile(outDir,sprintf('SystemSegregation_%s_associationOnly_doOrthog-%s',...
    bandName,num2str(doOrthog)));
  cmdStr = sprintf('export_fig %s.png',outName)
  eval(cmdStr);
  h = gcf; savefig(gcf,[outName,'.fig']);
  
  plotRegression(B',age)
  title('Between System mean - rest FC');
  xlabel('age'); ylabel('mean between system')
  outName = fullfile(outDir,sprintf('BetweenSystemMean_%s_associationOnly_doOrthog-%s',...
    bandName,num2str(doOrthog)));
  cmdStr = sprintf('export_fig %s.png',outName)
  eval(cmdStr);
  h = gcf; savefig(gcf,[outName,'.fig']);
  
  plotRegression(W',age)
  title('Within System mean - rest FC');
  xlabel('age'); ylabel('mean within system')
  outName = fullfile(outDir,sprintf('WithinSystemMean_%s_associationOnly_doOrthog-%s',...
    bandName,num2str(doOrthog)));
  cmdStr = sprintf('export_fig %s.png',outName)
  eval(cmdStr);
  h = gcf; savefig(gcf,[outName,'.fig']);
  
  toWrite = table(CCIDList,S',age);
  toWrite.Properties.VariableNames = {'CCID','SyS','Age'};
  writetable(toWrite,fullfile(outDir,sprintf('SySTable_%s_doOrthog-%s.csv',...
    bandName,num2str(doOrthog))))

end

close all

%% gather all bands in 1 table
for b=1:length(list_bandNames); bandName = list_bandNames{b};
  tmpT = readtable(fullfile(outDir,sprintf('SySTable_%s_doOrthog-%s.csv',...
    bandName,num2str(doOrthog))));
  tmpD(:,b) = table2array(tmpT(:,2));
end
newTable = tmpT;
newTable.SyS = [];
[newTable] = appendToTable(tmpD,list_bandNames,newTable);
writetable(newTable,fullfile(outDir,sprintf('SySTable_allBands_doOrthog-%s.csv',...
  num2str(doOrthog))));
