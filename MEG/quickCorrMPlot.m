close all
list_bandNames = {'delta','theta','alpha','beta','lGamma', ...
  'broadband'};

load /imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG/data/group_corrMat/ROIs-craddock/group_corrMat_roiOrder-lateralised.mat


for b=1:length(list_bandNames); bandName = list_bandNames{b};
  
  group_corrM = [];
  eval(sprintf('group_corrM = corrMat.%s;',bandName));
  
  %% OPTIONAL - UNCOMMENT TO STOP within Hemisphere NaNs
  group_corrM(1:391,1:391) = nan; %left
  group_corrM(392:end,392:end) = nan;
  
  figure('Position',[10 10 1250 750]),imagesc(group_corrM); colorbar; %axis square; ca = [min(cm(:)) max(cm(:))];
% %   %manage labels
% %   switch descript_roiOrder
% %     case 'byNetwork'
% %       roiLabels2 = cell(1, height(t)); roiLabels2(:) = {''};
% %       [tmp,idx] = unique(roiLabels);
% %       for r=1:length(tmp); roiLabels2{idx(r)}=tmp{r}; end
% %       yticks(1:length(roiLabels2)); set(gca, 'YTicklabel',roiLabels2);
% %       xticks(1:length(roiLabels2)); set(gca, 'xTicklabel',roiLabels2); xtickangle(90);
% %     otherwise
% %       yticks(1:length(roiLabels)); set(gca, 'YTicklabel',roiLabels);
% %       xticks(1:length(roiLabels)); set(gca, 'xTicklabel',roiLabels); xtickangle(90);
% %   end
  h = gca; h.XAxis.TickLength = [0 0]; h.YAxis.TickLength = [0 0]; colormap(hot);
  title(sprintf('%s Envelope Correlation',bandName));

end

%% ========================================================================
%% OPTIONAL can also replot when retaining top 25% thresholds (like Joffs wlts!)
percent = 80; %10 25 50 75 100     etc.

for b=1:length(list_bandNames); bandName = list_bandNames{b};
  
  group_corrM = [];
  eval(sprintf('group_corrM = corrMat.%s;',bandName));
  
  %% OPTIONAL - UNCOMMENT TO STOP within Hemisphere NaNs
  group_corrM(1:391,1:391) = nan; %left
  group_corrM(392:end,392:end) = nan;
  
  %% OPTIONAL - UNCOMMENT TO STOP NaN of mirror (lwoer quadrant)
  group_corrM(logical(tril(ones(length(group_corrM)),-1))) = nan;
  
  %% Threshold
  [vals,idx] = sort(group_corrM(:));
  idx(isnan(vals)) = [];
  total = length(idx);
  percentToIdx = round(total / 100 * percent);
  idx = idx(1:percentToIdx);
  
  group_corrM2 = nan(length(group_corrM),length(group_corrM));
  group_corrM2(idx) = group_corrM(idx); %refill in with only the thresholded vals
  group_corrM = group_corrM2;
  
  figure('Position',[10 10 1250 750]),imagesc(group_corrM); colorbar; %axis square; ca = [min(cm(:)) max(cm(:))];

  h = gca; h.XAxis.TickLength = [0 0]; h.YAxis.TickLength = [0 0]; colormap(hot);
  title(sprintf('%s Envelope Correlation',bandName));

end


