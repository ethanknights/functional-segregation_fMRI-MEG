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

atlasfN_3D = fullfile(outDir,'craddock_ROI_841_Linda_FCpaper.nii');
atlasfN_4D = fullfile(outDir,'craddock_ROI_841_Linda_FCpaper_4D.nii');

nROISExpected = 840; %(roi '0' not network so not 841)

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

%% 2. %Assign each ROI a network (and remove those that dont belong to any)
%% specify network
networkfN_3D = fullfile(outDir,'bignetworks_gamma26.nii');
% spm_check_registration(atlasfN_3D,'/imaging/ek03/toolbox/SPM12_v7219/canonical/single_subj_T1.nii')
netV = spm_vol(networkfN_3D); %ensure size(netY) size(Y)!
netY = spm_read_vols(netV);
netU = unique(netY);
netL = length(netU); %16 Networks (+ 0 for no network)

netU(netU == 0) = [];

network_name{1}='FPCN'; network_name{2}='auditory';network_name{3}='visual';network_name{4}='SMN';
network_name{5}='brainstem';network_name{6}='cerebellum';network_name{7}='DMN'; network_name{8}='basal ganglia';
network_name{9}='FEN'; network_name{10}='precuneus';network_name{11}='AI';network_name{12}='DAN';
network_name{13}='temporal';network_name{14}='cingulate';network_name{15}='thalamus';network_name{16}='VAN';

%% now check, for every roi 3D.nii, whiich network label it maximally overlaps
for r = 1:length(u) %'0' definitely isnt a network in 841 atlas, i checked
  
  %read the single 3D roi
  tmp_fN = fullfile(outDir,sprintf('atlas_roiLabel-%s.nii',num2str(u(r))));
  tmp_Y = spm_read_vols(spm_vol(tmp_fN));
  %get indices of roi (ensure not empty)
  idx = find(tmp_Y);
  assert(~isempty(idx));
  %get the network codes for indices
  netCodes{r} = netY(idx);
  
  uu(r) = unique(netCodes{r}); %thankfully all rois have 1 uniqle label only, 
  %so no logic needed to choose maximal overlap here... 
  %There will be error otherwise:
  %(uu is 840 x 1, but a roi will with >1 unique val will exceed as 840x2or3 etc.)
  if uu(r)
    netStrs{r} = network_name{uu(r)};
  else
    netStrs{r} = 'noNetwork';
  end
  
  %also store how many voxels in roi
  ll(r) = length(netCodes{r});
    
end

%% now convert these into a single 4D atlas
tmpN = [];
for r = 1:length(u)
  tmpN{r} = fullfile(outDir,sprintf('atlas_roiLabel-%s.nii',num2str(u(r))));
end
tmpN = cellstr(tmpN');

%% IMPORTANT - Reordering here by network
uniqueNetworks = ...
  {'AI';'DAN';'DMN';'FEN';'FPCN';'VAN';'cingulate';'precuneus';'temporal';... %association
  'basal ganglia';'brainstem';'cerebellum';'thalamus';... %subcortical
  'auditory';'SMN';'visual';... %sensory
  'noNetwork'}; %other
  
%gather new order
idx = [];
for i = 1:length(uniqueNetworks);  currNetStr = uniqueNetworks{i};
  idx{i} = find(strcmp(currNetStr,netStrs))';
end
idx2 = vertcat(idx{:});

%rebuild table
tmpN = tmpN(idx2,:);

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

%% Save
atlasInfo = [];
atlasInfo.atlasfN_3D            = atlasfN_3D;
atlasInfo.atlasfN_4D            = atlasfN_4D;
% atlasInfo.xyzMNI_coords         = xyz_coords;
atlasInfo.networkLabel_num      = uu(idx2)';
atlasInfo.networkLabel_str      = netStrs(idx2)';
atlasInfo.numVox                = ll(idx2)';
atlasInfo.atlasName             = atlasName;
atlasInfo.roiOrder              = 'byNetwork';
  
save(fullfile(outDir,'atlasInfo.mat'),'atlasInfo')

end