function [idx,netCodes,uu,networkStrings,ll] = getOverlap(V_roi,Y_roi,Y_network,network_name)

for r = 1:length(V_roi)
  %get indices of roi (ensure not empty)
  idx{r} = find(Y_roi(:,:,:,r));   assert(~isempty(idx{r}));
  %get the network codes for indices (ensure matrices match)
  netCodes{r} = Y_network(idx{r}); assert(all( size(Y_roi(:,:,:,r)) == size(Y_network)),'voxel sizes dont match for roi Y and network Y' )
  
  uu(r) = unique(netCodes{r}); %thankfully all rois have 1 unique label only, 
  %so no logic needed to choose maximal overlap here... 
  %There will be error otherwise:
  %(uu is 840 x 1, but a roi will with >1 unique val will exceed as 840x2or3 etc.)
  if uu(r)
    networkStrings{r} = network_name{uu(r)};
    if length(netCodes{r}) / sum(netCodes{r} == uu(r)) * 100 > 50 %and if >50% of voxels in ROI overlap this network
      networkStrings{r} = network_name{uu(r)}; %assign this ROI to that network
    end
  else
    networkStrings{r} = 'noNetwork';
  end

  %also store how many voxels in roi
  ll(r) = length(netCodes{r});  
end 