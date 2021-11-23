



mkdir tmp
%% Laterality Scores
clear; close all
t = readtable('lateralityTable_cc280.csv');
%fMRI
figure('Position',[0,0,1000,1000]);
histogram(t.fMRI_lateralityScore...
  ,'FaceColor','white','FaceAlpha',0.2,'EdgeColor','black','LineWidth',2)
title('Laterality Score - fMRIcc280','Interpreter','none')
saveas(gcf,fullfile('tmp',char(datetime('now'))),'jpeg');
%fMRI - PartialCorr
figure('Position',[0,0,1000,1000]);
histogram(t.fMRI_partialCorr_lateralityScore...
  ,'FaceColor','white','FaceAlpha',0.2,'EdgeColor','black','LineWidth',2)
title('Laterality Score - fMRIcc280 (partialCorr)','Interpreter','none')
saveas(gcf,fullfile('tmp',char(datetime('now'))),'jpeg');

%% SyS
clear; close all
list_bandNames = {'delta','theta','alpha','beta','lGamma', ...
  'broadband'};
list_colourNames = {'black','blue','red','green','yellow',...
  'white'};
%fMRI
t = readtable('/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/fMRI_Schaefer_cc280/data/004_computeSyS/noPartial_schaefer_associationOnly/SySTable.csv');
figure('Position',[0,0,1000,1000]);
histogram(t.SyS...
  ,'FaceColor','white','FaceAlpha',0.2,'EdgeColor','black','LineWidth',2)
title('SyS - fMRIcc280','Interpreter','none')
saveas(gcf,fullfile('tmp',char(datetime('now'))),'jpeg');
%fMRI - PartialCorr
t = readtable('/imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/fMRI_Schaefer_cc280/data/004_computeSyS/partialCorr_schaefer_associationOnly/SySTable.csv');
figure('Position',[0,0,1000,1000]);
histogram(t.SyS,'BinLimits',[-1,1]... %huge outlier so setting bin width toe exclude: drange(t.SyS) %-64?!
  ,'FaceColor','white','FaceAlpha',0.2,'EdgeColor','black','LineWidth',2)
title('SyS - fMRIcc280 (partialCorr)','Interpreter','none')
saveas(gcf,fullfile('tmp',char(datetime('now'))),'jpeg');
