function [F,fid] = saveFid_DifferenceToDP(subDir,CCID,S)

assert(~isempty(S.mri),'No mri path string provided')

%% First, gather fid info for beamform
%%-----------------------------------------
%% Convert Anatomical Landmark
% Read t1w json (voxels)
F = spm_jsonread(fullfile(subDir,...
  [CCID,'.json']));
fid.BIDS.voxels.Nasion  =   [F.AnatomicalLandmarkCoordinates.Nasion ; 1];
fid.BIDS.voxels.LPA     =   [F.AnatomicalLandmarkCoordinates.LPA    ; 1];
fid.BIDS.voxels.RPA     =   [F.AnatomicalLandmarkCoordinates.RPA    ; 1];
% Convert json voxels to mm
VY = spm_vol(S.mri);    %http://www.restfmri.net/forum/node/1300
fid.BIDS.mm.Nasion      = VY.mat * fid.BIDS.voxels.Nasion;
fid.BIDS.mm.LPA         = VY.mat * fid.BIDS.voxels.LPA;
fid.BIDS.mm.RPA         = VY.mat * fid.BIDS.voxels.RPA;


%% EXTRA - Second, write values to check: 
%% data/pp/OSL_noOverlap/<sub>/check_fid_mm.mat
%%-----------------------------------------
%get the max difference, and euclidean distance of my converted fiducial coordinates 
%(i.e. already in 'fid' by reading from BIDS/<sub>/t1w.json)
% vs. Darrens fiducial files. 
%(i.e. we dont know exactly how he converted)

%% Gather all my json fiducial info nicely (without the voxel size (4th val))
fid.BIDS.mm.all = [...
    fid.BIDS.mm.Nasion(1:3),  ...
    fid.BIDS.mm.LPA(1:3),     ...
    fid.BIDS.mm.RPA(1:3),     ...
    ];

%% Load DP's
try
  F2 = load(...
    ['/imaging/camcan/cc700/mri/pipeline/release004/fiducials/fid-native-',...
    CCID,'.mat']);

  fid.DP.mm.Nasion        = [F2.fid.native.mm.nas' ; 1];
  fid.DP.mm.LPA           = [F2.fid.native.mm.lpa' ; 1];
  fid.DP.mm.RPA           = [F2.fid.native.mm.rpa' ; 1];

  fid.DP.mm.all = [ ...
    fid.DP.mm.Nasion(1:3),  ...
    fid.DP.mm.LPA(1:3),     ...
    fid.DP.mm.RPA(1:3),     ...
    ];

  fid.mm_diff = fid.BIDS.mm.all - fid.DP.mm.all;
  fid.description = ['fid.mm.diff is the millimetre difference (BIDS - DP). ', ...
    'Matrix is voxels (x,y,z) x landmark (nasion,lpa,rpa)'];

  %% What is the max Euclidean difference between landmarks,
  % ie where ed = sqrt(sum((x1-x2)^2, (y1-y2)^2, (z1-z2)^2));
  % then take max(ed) across landmarks and subjects? 
  fid.eDiff.Nasion  = ( fid.BIDS.mm.Nasion(1:3) - fid.DP.mm.Nasion(1:3) ) .^ 2;
  fid.eDiff.LPA     = ( fid.BIDS.mm.LPA(1:3)    - fid.DP.mm.LPA(1:3) ) .^ 2;
  fid.eDiff.RPA     = ( fid.BIDS.mm.RPA(1:3)    - fid.DP.mm.RPA(1:3) ) .^ 2;

  fid.eDiff.maxAll = sqrt(sum(sum([fid.eDiff.Nasion,fid.eDiff.LPA,fid.eDiff.RPA])));

catch
  fprintf('DP''s file didnt exist, nothing to compare the check with')
end



%% Write fid structure
check.fid = fid;
oN = fullfile(subDir,...
  'check_fid_mm.mat');
save(oN,'check');

end