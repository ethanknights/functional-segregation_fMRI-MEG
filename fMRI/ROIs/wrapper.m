% 
% !cp /imaging/henson/users/ek03/toolbox/atlas/craddock_LindaFC/craddock_ROI_841_Linda_FCpaper.nii ./
% !cp /imaging/henson/users/ek03/toolbox/atlas/craddock_LindaFC/bignetworks_gamma26.nii ./
% 
% !mv craddock_ROI_841_Linda_FCpaper.nii craddock_ROI-841_dim-3D.nii
% !mv bignetworks_gamma26.nii bignetworks_ROI-16_dim-3D.nii

%point is jsut to create visusalsiation of all ROIs coloured by network
%% the getAtlas function int he main fMRI wrapper deals with 3D-4D.

%% 1. Copy atlases from data/0001_getAtlas/*.nii


%%-------------------------------------------------------------------------
%% Identify which networks each ROI belongs to (i.e. maximally overlaps)
%%-------------------------------------------------------------------------
atlasfN_roi = fullfile('craddock_ROI_841_Linda_FCpaper_4D.nii')
V_roi = spm_vol(atlasfN_roi);
Y_roi = spm_read_vols(V_roi);

atlasfN_network = fullfile('bignetworks_gamma26.nii')
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

%%-------------------------------------------------------------------------
%% extra visualisation - write 3D atlas, with ROIs coloured by network
%%-------------------------------------------------------------------------
modified_spm_convertAtlas_4Dto3D_v2('craddock_ROI_841_Linda_FCpaper_4D.nii',t) %v1 is for noNetworks (to make them visible), v2 is if they are dropped
%clean up intermediate files:
!rm craddock_ROI_841_Linda_FCpaper_4D_00*.nii -f
%rename for simplicity: 
!mv new_craddock_ROI_841_Linda_FCpaper_4D.nii extra-visualise16networks_atlas-craddock_ROI-841_dim-3D.nii -f 


%% BrainNet render
% addpath /imaging/henson/users/ek03/toolbox/BrainNetViewer_20191031 
% BrainNet
	 

