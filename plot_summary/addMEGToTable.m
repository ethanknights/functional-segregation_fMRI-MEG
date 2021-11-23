%% Important - remember this only works if all MEG subjects also have fMRI
%% Checked this earlier and ok.
%% (otherwise fiddle with idnexing to enure no MEG-only subject is missed)

% function [t] = addMEGToTable(t,lateralityScore,homoScore,nonHomoScore,...
%   descriptStr,bandName,CCIDList)

function [t] = addMEGToTable(t,lateralityScore,lateralityScoreReduced,...
  descriptStr,bandName,CCIDList)


%% for fMRI CCIDS, grab MEG data in same order 
for s = 1:length(t.CCID)
  idx = find(strcmp(t.CCID{s},CCIDList));
  if ~isempty(idx)
    newLateralityScore(s) = lateralityScore(idx);
    newLateralityScoreReduced(s) = lateralityScoreReduced(idx);
%     newHomoScore(s) = homoScore(idx);
%     newNonHomoScore(s) = nonHomoScore(idx);
  else
    newLateralityScore(s) = nan;
    newLateralityScore_reduced(s) = nan;
%     newHomoScore(s) = nan;
%     newNonHomoScore(s) = nan;
  end
end

%% append new column (tmpD) in t (remember to transpose ''')
eval( sprintf( 't.MEG_%s_%s_lS = newLateralityScore'';',bandName,descriptStr));
eval( sprintf( 't.MEG_%s_%s_lSReduced = newLateralityScoreReduced'';',bandName,descriptStr));
% eval( sprintf( 't.MEG_%s_%s_homoScore = newHomoScore'';',bandName,descriptStr));
% eval( sprintf( 't.MEG_%s_%s_nonHomoScore = newNonHomoScore'';',bandName,descriptStr));

