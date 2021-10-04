
%% extra script. Grab the globalSignal (i.e. line from rsfMRI_GLM_p36.m):
%% C = [C mean(Y,2)];


clear
load data/rawData/rawData.mat
ROIDir = 'data/002_getRestingStateFC/craddock';
outDir = 'data/globalSignal'; mkdir(outDir)

for s = 1:height(d); CCID = d.CCID{s};
  
  S = [];
  
  roiExtract_outName = fullfile(ROIDir,[CCID,'_roi_extract-y_ROISremoved.mat']);
  tmp = parLoad(roiExtract_outName); y = tmp.y;
  S.Y = [y.svd]; %   figure,plot(S.Y(:,:))
  
  
  C = [mean(S.Y,2)];
  
  
  fN_rsfMRI_GLM = fullfile(outDir,[CCID,'_globalSignalConfound.mat']);
  parsave(fN_rsfMRI_GLM,C)
  
end