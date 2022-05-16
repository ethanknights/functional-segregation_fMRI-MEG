
%% init nan colums to output t(:,3:7) for W, B, SyS, SyS_chanNorm, SyS_noNorm
idxEndT = width(t);
t( 1:height(t), idxEndT+1 : idxEndT+5) = array2table(nan);


%% ------------------------------------------------------------------------
for s = 1:height(t); CCID = t.CCID{s}; fN = fullfile(dwDir,[CCID,'_corrM.mat']);
  
  W = nan;
  B = nan;
  SyS = nan;
  SyS_chanNorm = nan;
  SyS_noNorm = nan;
  
  if logical(exist(fN,'file'))
    
    %%  Load [tS x ROI]
    tmpD = load(fN);
    tmpD = tmpD.aY; %size(tmpD)
    
    %% Drop non-association network ROIs (to match MEG)
    listNetworkStrToDrop = {'Limbic','Vis','SomMot'};
    idx = contains(roi_str,listNetworkStrToDrop); %find(idx)
    
    %drop those ROIs from tmpD (& roi info)
    tmpD(:,idx) = [];
    
    roi_str2 = roi_str;
    roi_str2(idx) = [];
    
    roi_networkIdx2 = roi_networkIdx;
    roi_networkIdx2(idx) = [];
    
    %all ok..?
    assert( size(tmpD,2) == expected_nROIs, 'Wrong nROIs in tmpD!');
    assert( length(roi_networkIdx2) == expected_nROIs, 'Wrong nROIs in roi_networkIdx!');
    
    %% netmats [ timeXspace matrix input]
    outD = nets_netmats(tmpD,1,method_corr); % imagesc(outD{s}); title(descriptStr,'Interpreter','none'); colorbar; colormap(hot);
    
    %% SyS
    [W,B,SyS,SyS_chanNorm,SyS_noNorm] = computeSyS(outD,roi_networkIdx2);
    
  else
   %% NOOP
  end
  
  t(s,idxEndT + 1) = array2table(W);
  t(s,idxEndT + 2) = array2table(B);
  t(s,idxEndT + 3) = array2table(SyS);
  t(s,idxEndT + 4) = array2table(SyS_chanNorm);
  t(s,idxEndT + 5) = array2table(SyS_noNorm);
  
end

%% Rename columns to W,B,SyS,SyS_chanNorm,SyS_noNorm for simplicty
t.Properties.VariableNames{idxEndT + 1} = sprintf('%s_metric_W',descriptStr);
t.Properties.VariableNames{idxEndT + 2} = sprintf('%s_metric_B',descriptStr);
t.Properties.VariableNames{idxEndT + 3} = sprintf('%s_metric_SyS',descriptStr);
t.Properties.VariableNames{idxEndT + 4} = sprintf('%s_metric_SyS_chanNorm',descriptStr);
t.Properties.VariableNames{idxEndT + 5} = sprintf('%s_metric_SyS_noNorm',descriptStr);

