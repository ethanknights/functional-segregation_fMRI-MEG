%% MEG DOESNT EXIST YET! 
%% Would need to fix file paths, so MEG lS + SyS commented out


clear; close all
mkdir tmp_cc280

list_bandNames = {'delta','theta','alpha','beta','lGamma', ...
  'broadband'};
list_colourNames = {'black','blue','red','green','yellow',...
  'white'};


%% Laterality Scores
%% ========================================================================
t = readtable('lateralityTable_cc280.csv');
yLims = [0,125];
xLims = [-0.1,0.75];

%% fMRI - lS
figure('Position',[0,0,1000,1000]);
subplot(2,1,1); histogram(t.fMRI_lS...
  ,'FaceColor','white','FaceAlpha',0.2,'EdgeColor','black','LineWidth',2)
ylim(yLims); xlim(xLims);  box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
title('lS - fMRI','Interpreter','none')
subplot(2,1,2); histogram(t.fMRI_partialCorr_lS...
  ,'FaceColor','white','FaceAlpha',0.2,'EdgeColor','black','LineWidth',2)
ylim(yLims); xlim(xLims);  box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
title('lS - fMRI Partial Correlation','Interpreter','none')

sgtitle('fMRI Laterality Score')
saveas(gcf,fullfile('tmp_cc280',char(datetime('now'))),'jpeg');

%% fMRI - lSReduced
figure('Position',[0,0,1000,1000]);
subplot(2,1,1); histogram(t.fMRI_lSReduced...
  ,'FaceColor','white','FaceAlpha',0.2,'EdgeColor','black','LineWidth',2)
ylim(yLims); xlim(xLims);  box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
title('lS Reduced - fMRI','Interpreter','none')
subplot(2,1,2); histogram(t.fMRI_partialCorr_lSReduced...
  ,'FaceColor','white','FaceAlpha',0.2,'EdgeColor','black','LineWidth',2)
ylim(yLims); xlim(xLims);  box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
title('lS Reduced - fMRI Partial Correlation','Interpreter','none')

sgtitle('fMRI Laterality Score (Reduced)')
saveas(gcf,fullfile('tmp_cc280',char(datetime('now'))),'jpeg');

% % % %% MEG - lS
% % % close all; figure('Position',[0,0,1000,1000]);
% % % yLims = [0,200];
% % % xLims = [-0.1,0.4];
% % % %noOrthog
% % % subplot(3,1,1);
% % % for b = 1:length(list_bandNames); bandName = list_bandNames{b}; colourName = list_colourNames{b};
% % %   eval(sprintf('tmp_cc280D(:,%d) = t.MEG_%s_noOrthog_lS;',b,bandName))
% % %   eval(sprintf('histogram(tmp_cc280D(:,%d),''FaceColor'',''%s'',''FaceAlpha'',0.3,''EdgeColor'',''black'',''LineWidth'',2); hold on',b,colourName))
% % % end
% % % ylim(yLims); xlim(xLims); legend(list_bandNames,'Location','eastoutside'); box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
% % % title('MEG (no orthog)','Interpreter','none')
% % % %orthog
% % % subplot(3,1,2);
% % % for b = 1:length(list_bandNames); bandName = list_bandNames{b}; colourName = list_colourNames{b};
% % %   eval(sprintf('tmp_cc280D(:,%d) = t.MEG_%s_orthog_lS;',b,bandName))
% % %   eval(sprintf('histogram(tmp_cc280D(:,%d),''FaceColor'',''%s'',''FaceAlpha'',0.3,''EdgeColor'',''black'',''LineWidth'',2); hold on',b,colourName))
% % % end
% % % ylim(yLims); xlim(xLims); legend(list_bandNames,'Location','eastoutside'); box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
% % % title('MEG (orthog)','Interpreter','none')
% % % %orthog + partialCorr
% % % subplot(3,1,3);
% % % for b = 1:length(list_bandNames); bandName = list_bandNames{b}; colourName = list_colourNames{b};
% % %   eval(sprintf('tmp_cc280D(:,%d) = t.MEG_%s_orthog_partialCorr_lS;',b,bandName))
% % %   eval(sprintf('histogram(tmp_cc280D(:,%d),''FaceColor'',''%s'',''FaceAlpha'',0.3,''EdgeColor'',''black'',''LineWidth'',2); hold on',b,colourName))
% % % end
% % % ylim(yLims); xlim(xLims); legend(list_bandNames,'Location','eastoutside'); box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
% % % title('MEG (orthog + partialCorr)','Interpreter','none')
% % % 
% % % sgtitle('MEG Laterality Score')
% % % saveas(gcf,fullfile('tmp_cc280',char(datetime('now'))),'jpeg');
% % % 
% % % 
% % % %% MEG - lSReduced
% % % close all; figure('Position',[0,0,1000,1000]); %for single plot
% % % yLims = [0,200];
% % % xLims = [-0.1,0.4];
% % % %noOrthog
% % % subplot(3,1,1);
% % % for b = 1:length(list_bandNames); bandName = list_bandNames{b}; colourName = list_colourNames{b};
% % %   eval(sprintf('tmp_cc280D(:,%d) = t.MEG_%s_noOrthog_lSReduced;',b,bandName))
% % %   eval(sprintf('histogram(tmp_cc280D(:,%d),''FaceColor'',''%s'',''FaceAlpha'',0.3,''EdgeColor'',''black'',''LineWidth'',2); hold on',b,colourName))
% % % end
% % % ylim(yLims); xlim(xLims); legend(list_bandNames,'Location','eastoutside'); box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
% % % title('MEG (no orthog)','Interpreter','none')
% % % %orthog
% % % subplot(3,1,2);
% % % for b = 1:length(list_bandNames); bandName = list_bandNames{b}; colourName = list_colourNames{b};
% % %   eval(sprintf('tmp_cc280D(:,%d) = t.MEG_%s_orthog_lSReduced;',b,bandName))
% % %   eval(sprintf('histogram(tmp_cc280D(:,%d),''FaceColor'',''%s'',''FaceAlpha'',0.3,''EdgeColor'',''black'',''LineWidth'',2); hold on',b,colourName))
% % % end
% % % ylim(yLims); xlim(xLims); legend(list_bandNames,'Location','eastoutside'); box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
% % % title('MEG (orthog)','Interpreter','none')
% % % %orthog + partialCorr
% % % subplot(3,1,3);
% % % for b = 1:length(list_bandNames); bandName = list_bandNames{b}; colourName = list_colourNames{b};
% % %   eval(sprintf('tmp_cc280D(:,%d) = t.MEG_%s_orthog_partialCorr_lSReduced;',b,bandName))
% % %   eval(sprintf('histogram(tmp_cc280D(:,%d),''FaceColor'',''%s'',''FaceAlpha'',0.3,''EdgeColor'',''black'',''LineWidth'',2); hold on',b,colourName))
% % % end
% % % ylim(yLims); xlim(xLims); legend(list_bandNames,'Location','eastoutside'); box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
% % % title('MEG (orthog + partialCorr)','Interpreter','none')
% % % 
% % % sgtitle('MEG Laterality Score (Reduced)')
% % % saveas(gcf,fullfile('tmp_cc280',char(datetime('now'))),'jpeg');


clear; close all
mkdir tmp_cc280

list_bandNames = {'delta','theta','alpha','beta','lGamma', ...
  'broadband'};
list_colourNames = {'black','blue','red','green','yellow',...
  'white'};





%% SyS
%% ========================================================================
clear; close all
list_bandNames = {'delta','theta','alpha','beta','lGamma', ...
  'broadband'};
list_colourNames = {'black','blue','red','green','yellow',...
  'white'};

%% fMRI (within-network normalisation) %from Chan et al. 
figure('Position',[0,0,1000,1000]);
yLims = [0,150];
xLims = [-0.1,1.5];
%fMRI
t = readtable('/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/fMRI_Schaefer_cc280/data/004_computeSyS/noPartial_schaefer_associationOnly/SySTable.csv');
subplot(2,1,1); histogram(t.SyS...
  ,'FaceColor','white','FaceAlpha',0.2,'EdgeColor','black','LineWidth',2)
title('SyS - fMRI','Interpreter','none')
ylim(yLims); xlim(xLims); box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
%fMRI - PartialCorr
t = readtable('/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/fMRI_Schaefer_cc280/data/004_computeSyS/partialCorr_schaefer_associationOnly/SySTable.csv');
subplot(2,1,2); histogram(t.SyS...
  ,'FaceColor','white','FaceAlpha',0.2,'EdgeColor','black','LineWidth',2)
title('SyS - fMRI (Partial Correlation)','Interpreter','none')
ylim(yLims); xlim(xLims); box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)

sgtitle('fMRI SyS')
saveas(gcf,fullfile('tmp_cc280',char(datetime('now'))),'jpeg');

%% fMRI (no within-network normalisation)
close all; figure('Position',[0,0,1000,1000]);
yLims = [0,150];
xLims = [-0.1,0.5];
%fMRI
t = readtable('/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/fMRI_Schaefer_cc280/data/004_computeSyS/noPartial_schaefer_associationOnly/SySTable_noNormalisation.csv');
subplot(2,1,1); histogram(t.SyS,'BinLimits',[-1,1]...
  ,'FaceColor','white','FaceAlpha',0.2,'EdgeColor','black','LineWidth',2)
ylim(yLims); xlim(xLims); box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
title('SyS - fMRI','Interpreter','none')
%fMRI - PartialCorr
t = readtable('/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/fMRI_Schaefer_cc280/data/004_computeSyS/partialCorr_schaefer_associationOnly/SySTable_noNormalisation.csv');
subplot(2,1,2); histogram(t.SyS,'BinLimits',[-1,1]...
  ,'FaceColor','white','FaceAlpha',0.2,'EdgeColor','black','LineWidth',2)
ylim(yLims); xlim(xLims); box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
title('SyS - fMRI (Partial Correlation)','Interpreter','none')

sgtitle('fMRI SyS (No Within-Network Normalisation)')
saveas(gcf,fullfile('tmp_cc280',char(datetime('now'))),'jpeg');

% % % 
% % % %% MEG
% % % close all; figure('Position',[0,0,1000,1000]); %for single plot
% % % yLims = [0,200];
% % % xLims = [-0.6,0.6];
% % % %noOrthog
% % % t = readtable('/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG/data/computeSyS/ROIs-Schaefer_100parcels_7networks_version-noOrthogDespikeEnvel/SySTable_allBands_doOrthog-0.csv');
% % % subplot(3,1,1);
% % % for b = 1:length(list_bandNames); bandName = list_bandNames{b}; colourName = list_colourNames{b};
% % %   eval(sprintf('tmp_cc280D(:,%d) = t.%s;',b,bandName))
% % %   eval(sprintf('histogram(tmp_cc280D(:,%d),''FaceColor'',''%s'',''FaceAlpha'',0.3,''EdgeColor'',''black'',''LineWidth'',2); hold on',b,colourName))
% % % end
% % % ylim(yLims); xlim(xLims); legend(list_bandNames,'Location','eastoutside'); box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
% % % title('MEG (no orthog)','Interpreter','none')
% % % %orthog
% % % t = readtable('/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG/data/computeSyS/ROIs-Schaefer_100parcels_7networks_version-orthogDespikeEnvel/SySTable_allBands_doOrthog-1.csv');
% % % subplot(3,1,2);
% % % for b = 1:length(list_bandNames); bandName = list_bandNames{b}; colourName = list_colourNames{b};
% % %   eval(sprintf('tmp_cc280D(:,%d) = t.%s;',b,bandName))
% % %   eval(sprintf('histogram(tmp_cc280D(:,%d),''FaceColor'',''%s'',''FaceAlpha'',0.3,''EdgeColor'',''black'',''LineWidth'',2); hold on',b,colourName))
% % % end
% % % ylim(yLims); xlim(xLims); legend(list_bandNames,'Location','eastoutside'); box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
% % % title('MEG (orthog)','Interpreter','none')
% % % %orthog + partialCorr
% % % t = readtable('/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG/data/computeSyS/ROIs-Schaefer_100parcels_7networks_version-orthogDespikeEnvelPartialCorr/SySTable_allBands_doOrthog-1.csv');
% % % subplot(3,1,3);
% % % for b = 1:length(list_bandNames); bandName = list_bandNames{b}; colourName = list_colourNames{b};
% % %   eval(sprintf('tmp_cc280D(:,%d) = t.%s;',b,bandName))
% % %   eval(sprintf('histogram(tmp_cc280D(:,%d),''FaceColor'',''%s'',''FaceAlpha'',0.3,''EdgeColor'',''black'',''LineWidth'',2); hold on',b,colourName))
% % % end
% % % ylim(yLims); xlim(xLims); legend(list_bandNames,'Location','eastoutside'); box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
% % % title('MEG (orthog + partialCorr)','Interpreter','none')
% % % 
% % % sgtitle('MEG SyS')
% % % saveas(gcf,fullfile('tmp_cc280',char(datetime('now'))),'jpeg');
% % % 
% % % 
% % % %% MEG (no normalisation)
% % % close all; figure('Position',[0,0,1000,1000]); %for single plot
% % % yLims = [0,200];
% % % xLims = [-0.03,0.1];
% % % %noOrthog
% % % t = readtable('/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG/data/computeSyS/ROIs-Schaefer_100parcels_7networks_version-noOrthogDespikeEnvel/SySTable_noNormalisation_allBands_doOrthog-0.csv');
% % % subplot(3,1,1);
% % % for b = 1:length(list_bandNames); bandName = list_bandNames{b}; colourName = list_colourNames{b};
% % %   eval(sprintf('tmp_cc280D(:,%d) = t.%s;',b,bandName))
% % %   eval(sprintf('histogram(tmp_cc280D(:,%d),''FaceColor'',''%s'',''FaceAlpha'',0.3,''EdgeColor'',''black'',''LineWidth'',2); hold on',b,colourName))
% % % end
% % % ylim(yLims); xlim(xLims); legend(list_bandNames,'Location','eastoutside'); box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
% % % title('MEG (no orthog)','Interpreter','none')
% % % %orthog
% % % t = readtable('/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG/data/computeSyS/ROIs-Schaefer_100parcels_7networks_version-orthogDespikeEnvel/SySTable_noNormalisation_allBands_doOrthog-1.csv');
% % % subplot(3,1,2);
% % % for b = 1:length(list_bandNames); bandName = list_bandNames{b}; colourName = list_colourNames{b};
% % %   eval(sprintf('tmp_cc280D(:,%d) = t.%s;',b,bandName))
% % %   eval(sprintf('histogram(tmp_cc280D(:,%d),''FaceColor'',''%s'',''FaceAlpha'',0.3,''EdgeColor'',''black'',''LineWidth'',2); hold on',b,colourName))
% % % end
% % % ylim(yLims); xlim(xLims); legend(list_bandNames,'Location','eastoutside'); box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
% % % title('MEG (orthog)','Interpreter','none')
% % % %orthog + partialCorr
% % % t = readtable('/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG/data/computeSyS/ROIs-Schaefer_100parcels_7networks_version-orthogDespikeEnvelPartialCorr/SySTable_noNormalisation_allBands_doOrthog-1.csv');
% % % subplot(3,1,3);
% % % for b = 1:length(list_bandNames); bandName = list_bandNames{b}; colourName = list_colourNames{b};
% % %   eval(sprintf('tmp_cc280D(:,%d) = t.%s;',b,bandName))
% % %   eval(sprintf('histogram(tmp_cc280D(:,%d),''FaceColor'',''%s'',''FaceAlpha'',0.3,''EdgeColor'',''black'',''LineWidth'',2); hold on',b,colourName))
% % % end
% % % ylim(yLims); xlim(xLims); legend(list_bandNames,'Location','eastoutside'); box off; line([0,0],yLims,'color','black','LineStyle','--','LineWidth',1)
% % % title('MEG (orthog + partialCorr)','Interpreter','none')
% % % 
% % % sgtitle('MEG SyS (No Within-Network Normalisation)')
% % % saveas(gcf,fullfile('tmp_cc280',char(datetime('now'))),'jpeg');