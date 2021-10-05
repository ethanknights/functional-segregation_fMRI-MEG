function [y,roiLabels,t] = reorder_craddock_lateralised(orig_y,orig_t)

%% Provide original data & table incl. 2 headers: networkName, networkIdx
%% output is the new y data, new labels and a new table (that holds all info)
%%
%% Lateralised version: Each ROI is paired with its closest ROI in terms of 
%% xyz in opposite hemisphere (So first pass does [L(a),R(a),L(b),R(b)]
%%
%% Next put them in a mirrored grid (using even/odd) for order:
%% [ L(a),L(b),L(c) ... L(z), R(a),R(b),R(c) ]
%%
%% This is far from perfect, but there is no perfect solution -
%% Some ROIs will be left out! As wont exactly match between left and right
%% particularly because ROIs with x=0 are assigned as left (only solution!)
%% And pairs would change if original order was shuffled (because each ROI 
%% is removed once found its pair)
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

%% First pass: make a grid of L(a),R(a), L(b), R(b)
%% for each ROI go through and find the smallest distance in opposite hemi
idx_leftHemisphere = logical(roiCentres(:,1) < 0); %some are 0, just treat as right...

newOrder = []; minVal = []; x = [];
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
    
    if ~idx_leftHemisphere(roiN) %if not LH 1st, swap pair (so always L,R)
      tmpL = newOrder(end);
      tmpR = newOrder(end-1);
      newOrder(end-1:end) = [tmpL,tmpR];
    end
      
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

%% store this idx (as need both idx's later if only have raw table!)
idx_a_ROIPairs = idx2;

%% Second Pass - reorder so [ L(a),L(b) ... L(z), R(a),R(b) ... R(z) ]
%% use odd/even
e=1:height(t);
e(mod(e,2)~=0)=[];
o = e-1;
idx_b_LR = [o,e]';%examine: oe = [o;e]';

%% check (apply second idx)
check = t(idx_b_LR,:);

%% save (so dont need to rerun function...)
save('reorderIdx_atlas-craddock_order-lateralised_nRois-782.mat',...
  'idx_a_ROIPairs','idx_b_LR')
