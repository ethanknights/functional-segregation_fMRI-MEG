
!/usr/bin/cp /imaging/henson/users/ek03/toolbox/atlas/craddock_LindaFC/craddock_ROI_841_Linda_FCpaper.nii ./ -f
!/usr/bin/cp /imaging/henson/users/ek03/toolbox/atlas/craddock_LindaFC/bignetworks_gamma26.nii ./ -f

!mv craddock_ROI_841_Linda_FCpaper.nii craddock_ROI-841_dim-3D.nii -f
!mv bignetworks_gamma26.nii bignetworks_ROI-16_dim-3D.nii -f

resampleROI('craddock_ROI-841_dim-3D.nii')
!mv craddock_ROI-841_dim-3D_resampled-6mm.nii craddock_ROI-835_dim-4D_resampled-6mm.nii -f


%%-------------------------------------------------------------------------
%% Create MEG resampled atlas version
%%-------------------------------------------------------------------------
fN = 'bignetworks_ROI-16_dim-3D.nii';
resampleROI(fN) %Use 3D (unlike fMRI)
!mv bignetworks_ROI-16_dim-3D_resampled-6mm.nii bignetworks_ROI-16_dim-4D_resampled-6mm.nii -f

%%-------------------------------------------------------------------------
%% 4D to 3D (for visualisation)
%%-------------------------------------------------------------------------
spm_convertAtlas_4Dto3D('craddock_ROI-835_dim-4D_resampled-6mm.nii');
!rm -f craddock_ROI-835_dim-4D_resampled-6mm_00*.nii -f
!mv new_craddock_ROI-835_dim-4D_resampled-6mm.nii craddock_ROI-835_dim-3D_resampled-6mm.nii -f

spm_convertAtlas_4Dto3D('bignetworks_ROI-16_dim-4D_resampled-6mm.nii');
!rm -f bignetworks_ROI-16_dim-4D_resampled-6mm_00*.nii -f
!mv new_bignetworks_ROI-16_dim-4D_resampled-6mm.nii bignetworks_ROI-16_dim-3D_resampled-6mm.nii -f

%% BrainNet render
% addpath /imaging/henson/users/ek03/toolbox/BrainNetViewer_20191031 
% BrainNet
	 
%%-------------------------------------------------------------------------
%% Identify which networks each ROI belongs to (i.e. maximally overlaps)
%%-------------------------------------------------------------------------
atlasfN_roi = fullfile('craddock_ROI-835_dim-4D_resampled-6mm.nii')
V_roi = spm_vol(atlasfN_roi);
Y_roi = spm_read_vols(V_roi);

atlasfN_network = fullfile('bignetworks_ROI-16_dim-3D_resampled-6mm.nii')
V_network = spm_vol(atlasfN_network);
Y_network = spm_read_vols(V_network);

network_name{1}='FPCN'; network_name{2}='auditory';network_name{3}='visual';network_name{4}='SMN';
network_name{5}='brainstem';network_name{6}='cerebellum';network_name{7}='DMN'; network_name{8}='basal ganglia';
network_name{9}='FEN'; network_name{10}='precuneus';network_name{11}='AI';network_name{12}='DAN';
network_name{13}='temporal';network_name{14}='cingulate';network_name{15}='thalamus';network_name{16}='VAN';

[idx,netCodes,uu,networkStrings,ll] = getOverlap(V_roi,Y_roi,Y_network,network_name);

%%-------------------------------------------------------------------------
%% write atlasInfo output:
%% atlasInfo-craddock_nROIs-835_res-6mm_descript-includeNoNetworkROIs [.csv]
%%-------------------------------------------------------------------------
t = table(networkStrings',uu',ll',idx'); t.Properties.VariableNames = ...
  {'networkName','networkIdx','nVox','voxelIdx'};
writetable(t,'craddock-ROI-835_resampled-6mm.csv')

%%-------------------------------------------------------------------------
%% extra visualisation - write 3D atlas, with ROIs coloured by network
%%-------------------------------------------------------------------------
modified_spm_convertAtlas_4Dto3D_v2('craddock_ROI-835_dim-4D_resampled-6mm.nii',t) %v1 is for noNetworks (to make them visible), v2 is if they are dropped
%clean up intermediate files:
!rm craddock_ROI-835_dim-4D_resampled-6mm_00*.nii -f
%rename for simplicity: 
!mv new_craddock_ROI-835_dim-4D_resampled-6mm.nii extra-visualise16networks_atlas-craddock_ROI-835_dim-3D_resampled-6mm.nii -f

