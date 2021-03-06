function [missingVals] = resampleROI(atlasfN)

AAL = nii.load(atlasfN); %input

mask = nii.load(fullfile( osldir, 'std_masks', 'MNI152_T1_6mm_brain.nii.gz' )); %could use others..
mask = logical(mask);

uniqueOrig = unique(AAL); uniqueOrig(uniqueOrig == 0) = [];

%% resample the AAL atlas, using option 'nearest' to ensure integer values
AAL_sub = imresize3( AAL, size(mask), 'nearest' );
uniqueNew = unique(AAL_sub); uniqueNew(uniqueNew == 0) = [];

%% work out if any ROIs have been lost, & if so return the missingVals
idx=[];
for i=1:length(uniqueOrig)
  tmp = find(uniqueOrig(i) == uniqueNew);
  if tmp
    idx(i) = tmp; 
  else
    idx(i) = nan;
  end
end
idx = idx';
missingVals = uniqueOrig(isnan(idx))
% make sure we didn't lose any label - doesnt amtter ehre as we have few
% networks, but many rois, should always have SOME in network
%assert( numel(unique(AAL_sub)) == numel(unique(AAL)), 'Labels were lost during resampling :(' )
% extract atlas voxels within the target brain mask

%% either way continue
atlas = AAL_sub(mask);
% convert label volume to a matrix of logical ROIs
label = nonzeros(unique(atlas));
nvox = nnz(mask);
nroi = numel(label);
rois = false(nvox, nroi);

for i = 1:nroi
    rois(:,i) = atlas == label(i);
end

sum(rois) %for the number of voxels in each region
%some regions end up having only one voxel
%merging regions having low number of voxels
p=parcellation(rois);
%p2 = p.remove_parcels(91:113); % Remove the parcels you do not need

p.savenii(p.weight_mask,[atlasfN(1:end-4),'_resampled-6mm']);
system(sprintf('gunzip %s',[atlasfN(1:end-4),'_resampled-6mm.nii'])); 