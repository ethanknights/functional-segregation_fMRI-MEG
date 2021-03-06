%% plot function
%% ========================================================================
function doPlot(tmpD,roiLabels,titleStr,oN)
  tmpD( logical( eye( size(tmpD) ) ) ) = nan; %diagonal
  figure('Position',[0,0,1000,1000]), imagesc(tmpD); axis square; 
  title(titleStr,'Interpreter','none');
  %axis labels
  roiLabels2 = cell(1, length(roiLabels)); roiLabels2(:) = {''};
  [tmp,idx] = unique(roiLabels);
  for r=1:length(tmp); roiLabels2{idx(r)}=tmp{r}; end 
  halfOfLabels = roiLabels2(1:length(roiLabels2)/2);
  roiLabels2(length(roiLabels2)/2+1:end) = halfOfLabels;
  yticks(1:length(roiLabels2)); set(gca, 'YTicklabel',roiLabels2);
  xticks(1:length(roiLabels2)); set(gca, 'xTicklabel',roiLabels2); xtickangle(90);
  h = gca; h.XAxis.TickLength = [0 0]; h.YAxis.TickLength = [0 0]; colormap(hot); colorbar;
  %% write
  saveas(gcf,...
     oN,'jpeg');
   
  close all
end