function spm_convertAtlas_4Dto3D(fN)
%% Provide a 4D atlas to be converted to 3D atlas (i.e. values per volume 
%% (vol1=1,vol2=2 etc.)
%%
%% ARGUMENTS:
%% fN = string with '.nii' suffix
%%
%% MODIFIED VERSION:
%% paints voxels by network label value (rather than just volume order)
%% t = table with info about network label atlas

spm_file_split(fN)

fnames = spm_select('FPList',pwd,sprintf('%s_\\w+.nii',fN(1:end-4))); %fnames = spm_select('FPList',pwd,sprintf('%s\w+.nii',fN);

str = [];
%str = 'max([i1.*0 '; max doesn't work on 2D matrices (planes in spm_imcalc)
for n = 1:size(fnames,1)
  thisLabel(n) = n;
  %%%% NOT HERE thisLabel(n) = t.networkIdx(n); %% IMPROTANT: Paint voxel by network value from table t
  %%%% NOT HERE: thisLabel(n) = thisLabel(n) + 1; %% IMPORTANT: Shifting idx +1, so that 'noNetwork' is visible!
  
  str = [str sprintf('(i%d>0)*%d',n,thisLabel(n))];
  if n<size(fnames,1)
    str = [str '+'];
  end
end

inputs = {};
inputs{1} = cellstr(strvcat(fnames));
inputs{2} = sprintf('new_%s',fN);
inputs{3} = {pwd};
inputs{4} = str;

matlabbatch{1}.spm.util.imcalc.input = '<UNDEFINED>';
matlabbatch{1}.spm.util.imcalc.output = '<UNDEFINED>';
matlabbatch{1}.spm.util.imcalc.outdir = '<UNDEFINED>';
matlabbatch{1}.spm.util.imcalc.expression = '<UNDEFINED>';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = -1;
matlabbatch{1}.spm.util.imcalc.options.interp = 0;
matlabbatch{1}.spm.util.imcalc.options.dtype = 16;
matlabbatch{2}.spm.util.disp.data(1) = cfg_dep('Image Calculator: Imcalc Computed Image', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
% jobs = {'spm12_create_labelled_job.m'};
% spm_jobman('run', jobs, inputs{:});

spm_jobman('run', matlabbatch, inputs{:});