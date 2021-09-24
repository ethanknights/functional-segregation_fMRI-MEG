function [y,roiLabels,t] = reorder_craddock_lateralised(orig_y,orig_t)

%% Provide original data & table incl. 2 headers: networkName, networkIdx
%% output is the new y data, new labels and a new table (that holds all info)
%%
%% Lateralised version: Each ROI next to its closest ROI 
%% in terms of xyz in opposite hemisphere (so L,R,L,R).
%% Since odd nROIs, last ROI is just on its own.
%% ========================================================================
clear

load('tmp.mat') %just example orig_y,orig_tfor convenience
parcellation_fN = '/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG/ROIs/craddock_ROI-835_dim-4D_resampled-6mm.nii';
p = parcellation(parcellation_fN);
mni_coords = p.template_coordinates;

%% grab each ROI's centre of gravity
% This is obtained by taking the weighted sum over the MNI coordinates of
% all of the voxels belonging to the parcel
% /imaging/henson/users/ek03/toolbox/OSL/ohba-external/ohba_utils/@parcellation/parcellation.m
roiCentres = p.roi_centers;

%% grab all peak coords and euclidean distances
for roiN = 1:p.n_parcels 
  
  roiA = roiCentres(roiN,:);
  
  for roiN_2 = 1:(p.n_parcels)
    
    roiB = roiCentres(roiN_2,:);
    
    %calc euclidDist
    roiDiff(roiN,roiN_2) = sqrt(...
      ( roiA(1) - roiB(1) )^2 + ...
      ( roiA(2) - roiB(2) )^2 + ...
      ( roiA(3) - roiB(3) )^2 ...
      );
    
  end
  roiDiff(roiN) = roiDiff(roiN)';
end
%imagesc(roiDiff)

%% for each ROI go through and find the smallest distance in opposite hemi
idx_leftHemisphere = logical(roiCentres(:,1) > 0); %some are 0, just treat as right...

newOrder = []; minVal = [];
for roiN = 1:p.n_parcels - 1 %minus 1 as odd nROIs. Last is noNetwork anyway
  
  tmpD = roiDiff(:,roiN); %tmpD = distances for this ROI
  %% set some distances to NaN
  %nan all in this ROIs hemisphere
  if idx_leftHemisphere(roiN)
    tmpD(idx_leftHemisphere) = nan;
  else
    tmpD(~idx_leftHemisphere) = nan;
  end
  %nan ROI itself (theoretically not needed, but some ROIs at midline ...)
  tmpD(roiN) = nan;
  
  if ~all(isnan(tmpD))
    %% append the roi to new order, and remove the ROI from ROIdiff, so
    %% not picked up again
    %roi itself
    newOrder(end+1) = roiN; % append the ROI itself to new order
    roiDiff(:,newOrder(end)) = nan; %remove this ROI, so cant be reused (vert)
    roiDiff(newOrder(end),:) = nan; %remove this ROI, so cant be reused (horz)
    %paired roi
    [minVal(end+1),newOrder(end+1)] = min(tmpD); %append its closest distance pair
    roiDiff(:,newOrder(end)) = nan; %remove this ROI, so cant be reused (vert)
    roiDiff(newOrder(end),:) = nan; %remove this ROI, so cant be reused (horz)
  else
    %Roi already used
    roiDiff(:,roiN) = nan; %remove this ROI, so cant be reused (vert)
    roiDiff(roiN,:) = nan; %remove this ROI, so cant be reused (horz)
  end
end
%%%debug!
% % % newOrder'
% % % u = unique(newOrder)
% % % size(u)
% % % size(newOrder)
%% dropped 47 ROIs (all must be in same hemis)
% could try go through this list and append, but should ahve enough rois
newOrder = newOrder'; minVal = minVal';

idx2 = newOrder; %to match old MEG code below..


%% rebuild table
t = orig_t(idx2,:);
t.roicentres_x = roiCentres(idx2,1);
t.roicentres_y = roiCentres(idx2,2);
t.roicentres_z = roiCentres(idx2,3);

% for roiN = 1:height(t)
%       t.roiEuclidDiDist_diffFromPairedROI(roiN,roiN_2) = sqrt(...
%       ( (1) - roiB(1) )^2 + ...
%       ( roiA(2) - roiB(2) )^2 + ...
%       ( roiA(3) - roiB(3) )^2 ...
%       );
% end


% %% for convenience, key stuff
% y = orig_y(idx2,:);
% roiLabels = t.networkName;
% 
% %% save (so dont need ot rerun function...)
idx = idx2; save('reorderIdx_atlas-craddock_order-lateralised_nRois-788.mat','idx') 