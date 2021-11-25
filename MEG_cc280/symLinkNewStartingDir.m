%% Specify Analysis Branch (e.g. which ROIs for directory name)
% descript_roisName = 'craddock'; %'craddock' | 'OSL_noOverlap';
% switch descript_roisName
%   case 'OSL_noOverlap'
%   case 'craddock'
% end

%% ========================================================================
%% Symlink above directory, to a new pp/<roiName> directory
%% ========================================================================
% mkdir(sprintf('data/pp/%s',descript_roisName))
% cd(sprintf('data/pp/%s',descript_roisName))
% !lndir.sh ../../AA_movecomp/ ./
% cd ../../../

mkdir('data/pp/')
cd('data/pp/')
!lndir.sh ../AA_movecomp/ ./
cd ../../