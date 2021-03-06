%% Reslice: SPM/tpm/ICV_mask.nii to Cam-CAN dartelnorm images

%% Doing this once - assuming all subjects/volumes are aligned
matlabbatch = [];
matlabbatch{1}.spm.spatial.coreg.write.ref = {'/imaging/camcan/cc700/mri/pipeline/release004/data_fMRI/aamod_norm_write_dartel_00001/CC110033/Rest/swaufMR10033_CC110033-0005.nii,1'};
matlabbatch{1}.spm.spatial.coreg.write.source = {'/imaging/henson/users/ek03/toolbox/SPM12_v7219/tpm/mask_ICV.nii,1'};
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
spm_jobman('run',matlabbatch); 

!mv /imaging/henson/users/ek03/toolbox/SPM12_v7219/tpm/rmask_ICV.nii ./