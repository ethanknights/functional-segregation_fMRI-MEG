
!/usr/bin/cp /imaging/camcan/templates/Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm.nii ./
!/usr/bin/cp /imaging/camcan/templates/Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm_labels.txt ./

!mv Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm.nii Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm-dim-3D.nii -f


resampleROI('Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm-dim-3D.nii')
!mv Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm-dim-3D_resampled-6mm.nii Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm-dim-4D_resampled-6mm.nii -f

% check nLabels
fN = 'Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm-dim-4D_resampled-6mm.nii';
v = spm_vol(fN); y = spm_read_vols(v);
tLabels = readtable('Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm_labels.txt');
assert(length(v) == height(tLabels))

% create number idx for networks (for SyS later)
t = tLabels; finalCol = width(t) + 1;
idx=find(contains(t.Var2,'_Vis_'));         t(idx,finalCol) = array2table(ones * 1);
idx=find(contains(t.Var2,'_SomMot_'));      t(idx,finalCol) = array2table(ones * 2);
idx=find(contains(t.Var2,'_DorsAttn_'));    t(idx,finalCol) = array2table(ones * 3);
idx=find(contains(t.Var2,'_SalVentAttn_')); t(idx,finalCol) = array2table(ones * 4);
idx=find(contains(t.Var2,'_Limbic_'));      t(idx,finalCol) = array2table(ones * 5);
idx=find(contains(t.Var2,'_Cont'));         t(idx,finalCol) = array2table(ones * 6);
idx=find(contains(t.Var2,'_Default'));      t(idx,finalCol) = array2table(ones * 7);
writetable(t,'Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm_labels.txt')
%not going to drop them here!
% listNetworkStrToDrop = {'Limbic','Vis','SomMot'};
% for n = 1:length(listNetworkStrToDrop)
%     idx = contains(corrM.atlasInfo.networkLabel_str,listNetworkStrToDrop{n});
%     corrM.Bmat(:,idx,:) = []; corrM.Bmat(idx,:,:) = [];
%     corrM.Zmat(:,idx,:) = []; corrM.Zmat(idx,:,:) = [];
%     corrM.atlasInfo.networkLabel_num(idx) = [];
%     corrM.atlasInfo.networkLabel_str(idx) = [];
% %     corrM.atlasInfo.numVox(idx) = [];
% end


%% %visualise
spm_convertAtlas_4Dto3D('Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm-dim-4D_resampled-6mm.nii');
% !rm -f Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm-dim-4D_resampled-6mm_00*.nii -f
% !mv new_bignetworks_ROI-16_dim-4D_resampled-6mm.nii visualise_haefer2018_100Parcels_7Networks_order_FSLMNI152_2mm-dim-4D_resampled-6mm_00*.nii -f  -f
% 
% %% BrainNet render
% % addpath /imaging/henson/users/ek03/toolbox/BrainNetViewer_20191031 
% % BrainNet
% 	 
% %%-------------------------------------------------------------------------
% %% Identify which networks each ROI belongs to (i.e. maximally overlaps)
% %%-------------------------------------------------------------------------
% atlasfN_roi = fullfile('craddock_ROI-835_dim-4D_resampled-6mm.nii')
% V_roi = spm_vol(atlasfN_roi);
% Y_roi = spm_read_vols(V_roi);
% 
% atlasfN_network = fullfile('bignetworks_ROI-16_dim-3D_resampled-6mm.nii')
% V_network = spm_vol(atlasfN_network);
% Y_network = spm_read_vols(V_network);
% 
% network_name{1}='FPCN'; network_name{2}='auditory';network_name{3}='visual';network_name{4}='SMN';
% network_name{5}='brainstem';network_name{6}='cerebellum';network_name{7}='DMN'; network_name{8}='basal ganglia';
% network_name{9}='FEN'; network_name{10}='precuneus';network_name{11}='AI';network_name{12}='DAN';
% network_name{13}='temporal';network_name{14}='cingulate';network_name{15}='thalamus';network_name{16}='VAN';
% 
% [idx,netCodes,uu,networkStrings,ll] = getOverlap(V_roi,Y_roi,Y_network,network_name);
% 
% %%-------------------------------------------------------------------------
% %% write atlasInfo output:
% %% atlasInfo-craddock_nROIs-835_res-6mm_descript-includeNoNetworkROIs [.csv]
% %%-------------------------------------------------------------------------
% t = table(networkStrings',uu',ll',idx'); t.Properties.VariableNames = ...
%   {'networkName','networkIdx','nVox','voxelIdx'};
% writetable(t,'craddock-ROI-835_resampled-6mm.csv')
% 
% %%-------------------------------------------------------------------------
% %% extra visualisation - write 3D atlas, with ROIs coloured by network
% %%-------------------------------------------------------------------------
t.Properties.VariableNames{7} = 'networkIdx';
modified_spm_convertAtlas_4Dto3D_v2('Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm-dim-4D_resampled-6mm.nii',t) %v1 is for noNetworks (to make them visible), v2 is if they are dropped
% %clean up intermediate files:
% !rm Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm-dim-4D_resampled-6mm_00*.nii -f
% %rename for simplicity: 
% !mv new_Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm-dim-4D_resampled-6mm.nii extra-visualise7networks.nii -f

