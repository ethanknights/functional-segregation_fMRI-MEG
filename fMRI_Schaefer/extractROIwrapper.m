%Purpose:
%Extract atlas ROI timeseries from wavelet despiked rest volumes

function extractROIwrapper(outDir,d,atlasInfo)

mkdir(outDir)

%% Setup Subjects
CCIDList = d.CCID;
nSubs = length(CCIDList); %1

%% Setup structure 'S' for roiExtract.m
S = [];
S.output_raw = 0;
S.zero_abs_tol = 10; % Do we want to include 2 ROIs in dorsal DMN that <20 voxels?
S.mask_space = 0;
S.zero_rel_tol = .95; % subject 463 missing >50% of parietal voxels
S.uROIvals = '>0'; %roi mask vals are voxel likelihood weights (i.e. positive weight or excluded 0)

[roiDir,fN,ext] = fileparts(atlasInfo.atlasfN_4D);
S.ROIfiles = cellstr(spm_select('ExtFPList',roiDir,[fN,ext]));
%S.ROIfiles = atlasInfo.atlasfN_4D; %only work for 1 sub
%ugly repmat(cell)
% for s = 2:3
%   for r = 1:length(roiList)
%   S.ROIfiles{r,s} = S.ROIfiles{r,1};
%   end
% end

Datafiles = cell(nSubs,1);
RP = cell(nSubs,6);
WMCSF = cell(nSubs,2);
G = cell(nSubs,1);
parfor s = 1:nSubs
  CCID = CCIDList{s};
  fprintf('Listing files %s\n',CCID);
  
  %% get datafiles
  [source_subDir,~,~] = fileparts(d.fN_fMRI_Rest{s});
  Datafiles{s} = spm_select('ExtFPList',source_subDir,'^swauf.*\.nii$'); %no wds version
  %S.Datafiles{s} = spm_select('ExtFPList',source_subDir,'\w+_wds.nii'); %waveletdespike version
  
  %% get global signal from all brain voxels (nuisance variable)
  tmpY = spm_read_vols(spm_vol(Datafiles{s}));
  tmpY_mask = spm_read_vols(spm_vol(...
    'rmask_ICV.nii')); %from reslice_SPMmask.m %size(tmpY); size(tmpY_mask)
  for v = 1:size(tmpY,4);  tmpYv = tmpY(:,:,:,v);
    G{s}(:,v) = tmpYv(logical(tmpY_mask)); %vox x volume
  end
  G{s} = mean(G{s},1)'; %volume x global mean signal
  
  %% get movement parameters (nuisance variable)
  [source_subDir,~,~] = fileparts(d.fN_fMRI_Rest_rp{s});
  RP{s} = load(spm_select('FPList',source_subDir,'^rp_'));
  
  %% get CSF and WM data (nuisance variable)
  tmp = load(d.fN_fMRI_Rest_compSignal{s}); %GM WM CSF
  WMCSF{s} = tmp.compTC(:,2:3);
end
S.Datafiles = Datafiles;

%% Extract Timeseries per Sub / ROI with roiExtract.m
% roiExtract_outName = fullfile(outDir,'roi_extract-y.mat');
idx = []; %init

parfor s = 1:nSubs
  CCID = CCIDList{s}
  
  roiExtract_outName = fullfile(outDir,[CCID,'_roi_extract-y.mat']);
  
  SS = S;
  
  %just this sub, as file too big to save with all subs
  SS.Datafiles = [];
  SS.Datafiles{1} = S.Datafiles{s};
  
  try
    parLoad(roiExtract_outName);
    %load(roiExtract_outName,'y');
    
  catch
    y = roi_extract(SS);
    
    parsave(roiExtract_outName,y);
    %save(roiExtract_outName,'y');
    
  end
end

%% Discard NaN ROIs in y
% %% This is because in roiExtract.m:
% % fprintf('(%d nonzero) voxels -- FAILED (%d percent)!\n',Nvox-zero_count,100*zero_rel_tol);

% %NaN in any roi / Sub?
if ~exist(fullfile(outDir,'RoisWhichWereRemovedDuringROIExtract.mat'),'file')
  for s = 1:nSubs
      CCID = CCIDList{s};
      roiExtract_outName = fullfile(outDir,[CCID,'_roi_extract-y.mat']);
      load(roiExtract_outName,'y');
    for r = 1:length(S.ROIfiles)

      
      idx(r,s) = any(isnan(y(r).mean));
    end
  end
  idx2 = any(idx,2); %Collapse subs (i.e. any roi with nan ever)
  fprintf('%d ROis being removed from y and atlas which were these indices: \n',size(find(idx2),1));
  disp(find(idx2));
  
  
  for s = 1:nSubs
    CCID = CCIDList{s}
    
    roiExtract_outName2 = fullfile(outDir,[CCID,'_roi_extract-y_ROISremoved.mat']);
    if ~exist(roiExtract_outName2,'file')
      
      roiExtract_outName = fullfile(outDir,[CCID,'_roi_extract-y.mat']);
      load(roiExtract_outName,'y');
      y(idx2,:) = [];
      
      save(roiExtract_outName2,'y');
    end
    
  end
  
  %% save which rois to drop later in corrM
  RoisWhichWereRemovedDuringROIExtract = find(idx2);
  save(fullfile(outDir,'RoisWhichWereRemovedDuringROIExtract.mat'),'RoisWhichWereRemovedDuringROIExtract');
end

%% Estimate linear regression between roi pairs: rsfMRI_GLM.m
parfor s = 1:nSubs
  CCID = CCIDList{s};
  try doRestGLM(CCID,outDir,RP{s},WMCSF{s},G{s}); %calls rsfMRI_GLM() in parallel
  catch
  end
end


%% store all data in corrM
i = 1;
for s = 1:nSubs
  CCID = CCIDList{s};
  
  fN_rsfMRI_GLM = fullfile(outDir,[CCID,'_corrM.mat']);
  try

    load(fN_rsfMRI_GLM)
    corrM.Bmat(:,:,i) = Bmat;
    corrM.Zmat(:,:,i) = Zmat;
    corrM.pBmat(:,:,i) = pBmat; %partial correlation
    corrM.pZmat(:,:,i) = pZmat; %partial correlation
    corrM.meanB(i) = mB;
    corrM.CCIDList{i} = CCID;
    
    i = i+1;
    
  catch
  end
  corrM.CCIDList = corrM.CCIDList';
  
  assert(~any(any(any(isnan(corrM.Bmat)))),'nans in corrM, something went wrong!')
  
end

%% add info for future reference to corrM
corrM.atlasInfo.atlasName = atlasInfo.atlasName;
corrM.atlasInfo.networkLabel_num =  atlasInfo.networkLabel_num;
corrM.atlasInfo.networkLabel_str =  atlasInfo.networkLabel_str;
% corrM.atlasInfo.numVox           = atlasInfo.numVox;
corrM.atlasInfo.roiOrder         = atlasInfo.roiOrder;
%remember to drop NaN ROIs
load(fullfile(outDir,'RoisWhichWereRemovedDuringROIExtract.mat'),'RoisWhichWereRemovedDuringROIExtract');
corrM.atlasInfo.RoisWhichWereRemovedDuringROIExtract = RoisWhichWereRemovedDuringROIExtract;
corrM.atlasInfo.networkLabel_num(RoisWhichWereRemovedDuringROIExtract) = [];
corrM.atlasInfo.networkLabel_str(RoisWhichWereRemovedDuringROIExtract) = [];
% corrM.atlasInfo.numVox(RoisWhichWereRemovedDuringROIExtract)           = [];


%% save
outName = fullfile(outDir,'connectivity-betaMatrix.mat');
save(outName,'corrM','-v7.3');

%% plots
%% ========================================================================
%% with NoNetworks
tmpD = mean(corrM.Bmat,3); %could do Zmat too
tmpD( logical( eye( size(tmpD) ) ) ) = nan; %diagonal
figure('Position',[0,0,1000,1000]),imagesc(tmpD)
%axis labels
t = table(corrM.atlasInfo.networkLabel_str);
roiLabels = t.Var1;
roiLabels2 = cell(1, height(t)); roiLabels2(:) = {''};
[tmp,idx] = unique(roiLabels);
for r=1:length(tmp); roiLabels2{idx(r)}=tmp{r}; end
yticks(1:length(roiLabels2)); set(gca, 'YTicklabel',roiLabels2);
xticks(1:length(roiLabels2)); set(gca, 'xTicklabel',roiLabels2); xtickangle(90);
h = gca; h.XAxis.TickLength = [0 0]; h.YAxis.TickLength = [0 0]; colormap(hot); colorbar
title(sprintf('BMat - Correlation Matrix N=%d roiOrder %s',size(corrM.Bmat,3),corrM.atlasInfo.roiOrder));
%print
saveas(gcf,...
  sprintf('%s/groupCorrMat_BMat_N=%d_roiOrder-%s',outDir,size(corrM.Bmat,3),corrM.atlasInfo.roiOrder),...
  'jpeg');

% %% dropped NoNetworks
% tmpD = mean(corrM.Bmat(1:723,1:723,:),3); %could do Zmat too
% tmpD( logical( eye( size(tmpD) ) ) ) = nan; %diagonal
% figure('Position',[0,0,1000,1000]),imagesc(tmpD)
% %axis labels
% t = table(corrM.atlasInfo.networkLabel_str);
% roiLabels = t.Var1;
% roiLabels2 = cell(1, height(t)); roiLabels2(:) = {''};
% [tmp,idx] = unique(roiLabels);
% for r=1:length(tmp); roiLabels2{idx(r)}=tmp{r}; end
% yticks(1:length(roiLabels2)); set(gca, 'YTicklabel',roiLabels2);
% xticks(1:length(roiLabels2)); set(gca, 'xTicklabel',roiLabels2); xtickangle(90);
% h = gca; h.XAxis.TickLength = [0 0]; h.YAxis.TickLength = [0 0]; colormap(hot);
% title(sprintf('BMat - Correlation Matrix N=%d roiOrder %s',size(corrM.Bmat,3),corrM.atlasInfo.roiOrder));
% %print
% saveas(gcf,...
%   sprintf('%s/groupCorrMat_BMat_N=%d_roiOrder-%s',outDir,size(corrM.Bmat,3),corrM.atlasInfo.roiOrder),...
%   'jpeg');

try; plotRegression(corrM.meanB',d.Age); catch; end %wont work if subs failed!


end