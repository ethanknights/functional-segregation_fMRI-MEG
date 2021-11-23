%% lazy - workspace inheritance
for b=1:length(list_bandNames); bandName = list_bandNames{b};
  %% data
  eval( sprintf( 'tmpD = tmp.corrMat.%s;',bandName) ); %tmpD = delta etc.
  %% ROILabels
  [roiLabels] = makeROILabels(tmp.roiLabels);
  %% titleStr
  atlasName = 'Schaefer';
  nSubs = size(tmpD,3);
  titleStr = sprintf('Correlation Matrix-MEG Measure-%s Atlas-%s N-%d (%s)',bandName,atlasName,nSubs,descriptStr);
  %% outName
  oN = sprintf('%s/corrM-MEG_Measure-%s_Atlas-%s_N-%d_%s',outDir,bandName,atlasName,nSubs,descriptStr); %.jpg
  %% doPlot
  %% ------------------------------------------------------------------------
  doPlot(nanmean(tmpD,3),roiLabels,titleStr,oN);
  %% doLaterality
  %% ------------------------------------------------------------------------
  [lS,lSReduced] = doLaterality(tmpD,tmp.roiLabels);
  t = addMEGToTable(t,lS,lSReduced,descriptStr,bandName,tmp.CCIDList);
end