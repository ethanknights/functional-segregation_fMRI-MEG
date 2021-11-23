%Purpose:
%Create a 3D and 4D atlas for:
%
%
%3D Atlas:
%Load 3D.nii From Rik(Linda)
%
%4D Atlas:
%Combines the rois into independent volumes of a 4D.nii for roiExtract.m
%
%
%Output info written to atasInfo.mat including path: 
%data/<atlas>_3D.nii
%data/<atlas>_4D.nii **Want this 1 for analysis**

function setupAtlas(outDir,atlasName)

mkdir(outDir)

copyfile('/imaging/camcan/templates/Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm.nii',outDir);
copyfile('/imaging/camcan/templates/Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm_labels.txt',outDir);

atlasfN_3D = fullfile(outDir,'Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm.nii');
atlasfN_4D = fullfile(outDir,'Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm_4D.nii'); %to be created

nROISExpected = 100; %(roi '0' not network so not 841)

%% Inspect atlas
% spm_check_registration(atlasfN_3D,'/imaging/ek03/toolbox/SPM12_v7219/canonical/single_subj_T1.nii')
V = spm_vol(atlasfN_3D);
y = spm_read_vols(V);
u = unique(y);

%% Create 4D atlas for roiExtract (as needs cellararay of vols with different rois):
%% 1. write each roi value to a separate binary 3D vol.nii
for r = 1:length(u) %'0' definitely isnt a network in 841 atlas
  
  tmp_fN = sprintf('atlas_roiLabel-%s.nii',num2str(u(r)));
  tmp_V = V;
  tmp_V.fname = fullfile(outDir,tmp_fN);
  tmpD = y;
  
  %drop all values except for thsi label:
  idx = find(tmpD ~= u(r));
  tmpD(idx) = 0;
  %Binarise this volume i.e. convert values to 1s (e.g. if they were 2s,3s)
  idx = find(tmpD);
  tmpD(idx) = 1;
  
  spm_write_vol(tmp_V,tmpD);
  
end
%remove confusion later: '0' is not a roi
delete(fullfile(outDir,'atlas_roiLabel-0.nii'));
u(u == 0) = [];
assert(length(u) == nROISExpected,'check number of 3D roi files')

%% now convert these into a single 4D atlas
tmpN = [];
for r = 1:length(u)
  tmpN{r} = fullfile(outDir,sprintf('atlas_roiLabel-%s.nii',num2str(u(r))));
end
tmpN = cellstr(tmpN');

%% now write the new image
matlabbatch{1}.spm.util.cat.vols = tmpN;
matlabbatch{1}.spm.util.cat.name = atlasfN_4D;
matlabbatch{1}.spm.util.cat.dtype = 4;
matlabbatch{1}.spm.util.cat.RT = NaN;
spm_jobman('run',matlabbatch);

%% remove the single 3D .nii's 
for r = 1:length(tmpN)
  delete(tmpN{r})
end


%% 2. get labels 
tmpT = readtable(fullfile(outDir,'Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm_labels.txt'));

idx = contain('Vis',tmpT.Var2);
tmpT.networkLabel_num(idx) = 1;
idx = contain('SomMot',tmpT.Var2);
tmpT.networkLabel_num(idx) = 2;
idx = contain('DorsAttn',tmpT.Var2);
tmpT.networkLabel_num(idx) = 3;
idx = contain('SalVentAttn',tmpT.Var2);
tmpT.networkLabel_num(idx) = 4;
idx = contain('Limbic',tmpT.Var2);
tmpT.networkLabel_num(idx) = 5;
idx = contain('Cont',tmpT.Var2);
tmpT.networkLabel_num(idx) = 6;
idx = contain('Default',tmpT.Var2);
tmpT.networkLabel_num(idx) = 7;

%% Save
atlasInfo = [];
atlasInfo.atlasfN_3D            = atlasfN_3D;
atlasInfo.atlasfN_4D            = atlasfN_4D;
% atlasInfo.xyzMNI_coords         = xyz_coords;
atlasInfo.networkLabel_num      = tmpT.networkLabel_num;
atlasInfo.networkLabel_str      = tmpT.Var2;
atlasInfo.numVox                = nan(length(u),1);
atlasInfo.atlasName             = atlasName;
atlasInfo.roiOrder              = 'lateralised';
  
save(fullfile(outDir,'atlasInfo.mat'),'atlasInfo')

%% write a 'network' image to visualise
cd(outDir)
addpath('/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/fMRI')
spm_convertAtlas_4Dto3D('Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm_4D.nii',atlasInfo.networkLabel_num)
delete('Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm_4D_00*.nii')
movefile('new_Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm_4D.nii','visualise-Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm_3D.nii')
rmpath('/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/fMRI')
cd('../../../')

end