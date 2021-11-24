clear; close all

list_bandNames = {'delta','theta','alpha','beta','lGamma', ...
  'broadband'};

figure('Position',[0,0,2000,2000]);
for b = 1:length(list_bandNames); band = list_bandNames{b};
  tmpD = imread(sprintf('images/corrM-MEG_Measure-%s_Atlas-Schaefer_N-619_noOrthog.jpg',band));
  subplot(2,3,b); imshow(tmpD,'InitialMagnification',100); hold on
end
sgtitle('noOrthog')
saveas(gcf,'images/corrM-MEG_allBands_noOrthog.jpg');

figure('Position',[0,0,2000,2000]);
for b = 1:length(list_bandNames); band = list_bandNames{b};
  tmpD = imread(sprintf('images/corrM-MEG_Measure-%s_Atlas-Schaefer_N-619_orthog.jpg',band));
  subplot(2,3,b); imshow(tmpD,'InitialMagnification',100); hold on
end
sgtitle('orthog')
saveas(gcf,'images/corrM-MEG_allBands_orthog.jpg');

figure('Position',[0,0,2000,2000]);
for b = 1:length(list_bandNames); band = list_bandNames{b};
  tmpD = imread(sprintf('images/corrM-MEG_Measure-%s_Atlas-Schaefer_N-619_orthog_partialCorr.jpg',band));
  subplot(2,3,b); imshow(tmpD,'InitialMagnification',100); hold on
end
sgtitle('orthog_partialCorr')
saveas(gcf,'images/corrM-MEG_allBands_orthog_partialCorr.jpg');
