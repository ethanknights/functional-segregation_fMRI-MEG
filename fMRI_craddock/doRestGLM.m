%Allows parfor loop for rsfMRI_GLM
%substantially faster

function doRestGLM(CCID,outDir,RP,WMCSF,G)

S = [];
S.TR = 1.97; %https://camcan-archive.mrc-cbu.cam.ac.uk/dataaccess/pdfs/CAMCAN700_MR_params.pdf

%% Filter 
%Chan et al. filter loses too many dfs:
% S.HPC = 1/0.009; 
% S.LPC = 1/0.08;
%Revert to rsfMRI_GLM defaults:
S.HPC = 1/0.01; 
S.LPC = 1/0.2;

%% Spike covariates
%Josh's was losing a lot of dfs:
%S.SpikeMovAbsThr = 0.2;         % approx FWD > .2mm
%S.SpikeMovRelThr = 3; 
%More lenient:
%S.SpikeMovAbsThr = 0.5; %this is for absolute millimetre realginment value.
S.SpikeMovRelThr = 5; %this is for relative spikes (i.e. spot outliers)

%% Global signal: Using wholebrain mean signal (see 'G' in S.C below)
% S.G = 1; %to match Josh  %Global signal regression
S.G = 0;

%% Additional Parameters
S.PreWhiten = 0; % Insufficient ROIs to estimate
%S.VolterraLag = 2; %Not using for now
S.svd_thr = 1;

roiExtract_outName = fullfile(outDir,[CCID,'_roi_extract-y_ROISremoved.mat']);
load(roiExtract_outName,'y');
S.Y = [y.svd]; %   figure,plot(S.Y(:,:))
S.M = RP;
S.C = [WMCSF,G];

%S.pflag = 1; %partial correlation
S.pflag = 0; %no partial correlation

%[Zmat, Bmat, pZmat, pBmat, aY, X0r] = rsfMRI_GLM(S);
[Zmat, Bmat, pZmat, pBmat, aY, X0r] = rsfMRI_GLM_p36(S); %additional covariates: derivates of GS, WM, CSF 

if exist('Zmat','var') %if didnt fail, save
  f = find(triu(ones(size(y,1))));
  mB = mean(Bmat(f));


  fN_rsfMRI_GLM = fullfile(outDir,[CCID,'_corrM.mat']);
  save(fN_rsfMRI_GLM,'Zmat','Bmat','pZmat','pBmat','aY','X0r','mB')
end

end
