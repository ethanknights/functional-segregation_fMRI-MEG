%% Compute System Segregation (adapted from Chan et al. 2014)
%%
%% Inputs:
%% corrM            = [ROI x ROI] correlations
%% roi_networkIdx   = Vector assigning network labels per ROI [1 1 1 2 2 3 3 3]
%%
%% Outputs (all are mean metrics):
%% W          = Within System connectivity
%% B          = Between System connectivity
%% SyS        = Segregation. Adapted *orthogonal* normalisation (W-B / W+B)
%% SyS_noNorm = Segregation. No normalisation


function [W,B,SyS,SyS_chanNorm,SyS_noNorm] = computeSyS(corrM,roi_networkIdx)

  M = corrM;
  Ci = roi_networkIdx;
  
  nCi = unique(Ci);
  
  Wv = [];
  Bv = [];
  
  for i = 1:length(nCi) % loop through communities
    Wi = Ci == nCi(i); % find index for this system (i.e. within  communitiy)
    Bi = Ci ~= nCi(i); % find index for diff system (i.e. between communitiy)
    
    Wv_temp = M(Wi,Wi); % extract this system
    Bv_temp = M(Wi,Bi); % extract diff system
    
    Wv = [Wv, Wv_temp(logical(triu(ones(sum(Wi)),1)))'];
    Bv = [Bv, Bv_temp(:)'];
  end
  
  W = mean(Wv);                   % mean this system
  B = mean(Bv);                   % mean diff system
  SyS = ( W - B ) / ( W + B );    % SyS
  SyS_chanNorm = ( W - B ) / W;   % SyS (with Chan et al. 2014 normalisation)
  SyS_noNorm = W - B;             % SyS (without within-network normalisation)
  
end