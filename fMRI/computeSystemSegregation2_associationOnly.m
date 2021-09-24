%Purpose:
%Compute RSFC system segregation (Chan et al. 2014)

%% Notes - Association networks
% All available networks from Linda's 16 atlas (Geerlings, Rubinov, Cam-CAN
% & Henson 2015):
%     {'AI'           } %ant. insula = Salience/cingulo-opercular network (Power et al. 2011; Seeley et al. 2007)
%     {'DAN'          } %dorsal attention network
%     {'DMN'          } %default mode network
%     {'FEN'          } %frontal executive network
%     {'FPCN'         } %fronto-parietal control network
%     {'SMN'          } %%sensory/motor
%     {'VAN'          } %ventral attention network
%     {'auditory'     } %sensory/motor
%     {'basal ganglia'} %subcortical
%     {'brainstem'    } %subcortical
%     {'cerebellum'   } %subcortical
%     {'cingulate'    } %cingulo-opercular network 
%     {'precuneus'    } %DMN (see Fig 1C Chan et al. 2014)
%     {'temporal'     } %inferior temporal network (Geerligs et al. 2015)
%     {'thalamus'     } %subcortical (Geerligs et al. 2015) cf. Power/Seeley et al. but they conflict if SMN or not. We dont have specificity to decide (e.g. anterior vs. poster)
%     {'visual'       } %sensory/motor
% 
% To match Chan et al. 2014 association systems definition 
% (from Power et al. 2011; Cingulo-opercular control, dorsal attention, 
% frontal-parietal control, salience, ventral attention & default systems):
% 
% 	  {'AI'           } %ant. insula = Salience/cingulo-opercular network (Power et al. 2011; Seeley et al. 2007)
%     {'DAN'          } %dorsal attention network
%     {'DMN'          } %default mode network
%     {'FPCN'         } %fronto-parietal control network
%     {'VAN'          } %ventral attention network
%     {'cingulate'    } %cingulo-opercular network
% 	
% I also retained 3 remaining 'higher order processing networks' from 
% Geerligs et al. (2015) (FEN; temporal; precunues).
% Final Association networks:
% 
% 	  {'AI'           } %ant. insula = Salience/cingulo-opercular network (Power et al. 2011; Seeley et al. 2007)
%     {'DAN'          } %dorsal attention network
%     {'DMN'          } %default mode network
%     {'FEN'          } %frontal executive network (Geerligs et al. 2015)
%     {'FPCN'         } %fronto-parietal control network
%     {'VAN'          } %ventral attention network
%     {'cingulate'    } %cingulo-opercular network 
%     {'precuneus'    } %precunues network (Geerligs et al. 2015), though probably in Chan et al. 2014 as DMN (see Fig 1C).
%     {'temporal'     } %inferior temporal network (Geerligs et al. 2015)

function [W,B,S] = computeSystemSegregation2_associationOnly(outDir,corrM)

outDir = [outDir,'_associationOnly'];
mkdir(outDir)

%% Setup Subjects
CCIDList = corrM.CCIDList;
nSubs = length(CCIDList);

%% grab subjects ages (as might have dropped some so d.age useless)
I = LoadSubIDs;
for s = 1:nSubs
  idx = contain(CCIDList{s},I.SubCCIDc);
  age(s) = I.Age(s);
end
age = age';

%% drop networks
%listNetworkStrToDrop = {'noNetwork'};
listNetworkStrToDrop = {'noNetwork','SMN','auditory','basal ganglia', ...
                        'brainstem','cerebellum','thalamus','visual'};
for n = 1:length(listNetworkStrToDrop)
    idx = contains(corrM.atlasInfo.networkLabel_str,listNetworkStrToDrop{n});
    corrM.Bmat(:,idx,:) = []; corrM.Bmat(idx,:,:) = [];
    corrM.Zmat(:,idx,:) = []; corrM.Zmat(idx,:,:) = [];
    corrM.atlasInfo.networkLabel_num(idx) = [];
    corrM.atlasInfo.networkLabel_str(idx) = [];
    corrM.atlasInfo.numVox(idx) = [];
end


%% print number of ROis per network left
u = unique(corrM.atlasInfo.networkLabel_num);
for uu= 1:length(u)
  
  corrM.atlasInfo.nRoisPerNetwork(uu) = sum(corrM.atlasInfo.networkLabel_num == u(uu));
  
  fprintf('nROis for Network: %s %s\n',corrM.atlasInfo.networkLabel_str{uu},num2str(corrM.atlasInfo.nRoisPerNetwork(uu)));
end
% FPCN 65
% auditory 49
% FPCN 80
% visual 70
% SMN 68
% brainstem 36
% SMN 81
% brainstem 33
% VAN 24
% AI 21
% visual 23
% auditory 52
% FEN 26
% DAN 11
% visual 20
% cingulate 39


%% quick plot Group Mean connectivity
figure,
imagesc(squeeze(mean(corrM.Bmat,1))); 
colorbar; colormap('jet'),set(gca,'XTick',[1:length(corrM.atlasInfo.networkLabel_str)],'XTickLabels',corrM.atlasInfo.networkLabel_str,'XTickLabelRotation',90), axis square; set(gca,'YTick',[1:length(corrM.atlasInfo.networkLabel_str)],'YTickLabels',corrM.atlasInfo.networkLabel_str)

%% RIK VERSION: CALCULATE BETWEEN SYSTEM SEG
% for s = 1:length(CCIDList)
%   
% %   %Get main data (i.e. subs connectivity matrix & roi labels)
%   M = squeeze(corrM.Bmat(:,:,s));
% 
% %   figure
% %   imagesc(M); 
% %   colorbar; colormap('jet'),set(gca,'XTick',[1:length(corrM.atlasInfo.networkLabel_str)],'XTickLabels',corrM.atlasInfo.networkLabel_str,'XTickLabelRotation',90), axis square; set(gca,'YTick',[1:length(corrM.atlasInfo.networkLabel_str)],'YTickLabels',corrM.atlasInfo.networkLabel_str)
% 
%   out(s) = mean(M(find(triu(M,1))));
% end
% plotRegression(out',d.Age)


%% WIGG'S VERSION: calculate system segregation
for s = 1:length(CCIDList)
  
  %Get main data (i.e. subs connectivity matrix & roi labels)
  M = squeeze(corrM.Bmat(:,:,s));
  Ci = corrM.atlasInfo.networkLabel_num;
  
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
  
  W(s) = mean(Wv); % mean this system
  B(s) = mean(Bv); % mean diff system
  S(s) = (W(s)-B(s))/W(s); % system segregation
  
end
%% plots
plotRegression(S',age)
title('System segregation - rest FC'); 
xlabel('age'); ylabel('mean within - between system')
outName = fullfile(outDir,'SystemSegregation');
cmdStr = sprintf('export_fig %s.png',outName)
eval(cmdStr);
h = gcf; savefig(gcf,[outName,'.fig']);

plotRegression(B',age)
title('Between System mean - rest FC');
xlabel('age'); ylabel('mean between system')
outName = fullfile(outDir,'BetweenSystemMean');
cmdStr = sprintf('export_fig %s.png',outName)
eval(cmdStr);
h = gcf; savefig(gcf,[outName,'.fig']);

plotRegression(W',age)
title('Within System mean - rest FC');
xlabel('age'); ylabel('mean within system')
outName = fullfile(outDir,'WithinSystemMean');
cmdStr = sprintf('export_fig %s.png',outName)
eval(cmdStr);
h = gcf; savefig(gcf,[outName,'.fig']);

toWrite = table(CCIDList,S',age);
toWrite.Properties.VariableNames = {'CCID','SyS','Age'};
writetable(toWrite,fullfile(outDir,'SySTable.csv'))

% %% ZMAT VERSION
% figure,imagesc(squeeze(mean(corrM.Zmat,1)))
% %% calculate system segregation
% for s = 1:length(CCIDList)
%   
%   %Get main data (i.e. subs connectivity matrix & roi labels)
%   M = squeeze(corrM.Zmat(s,:,:));
%   Ci = corrM.atlasInfo.networkLabel_num;
%   
%   nCi = unique(Ci);
%   
%   Wv = [];
%   Bv = [];
%   
%   for i = 1:length(nCi) % loop through communities
%     Wi = Ci == nCi(i); % find index for this system (i.e. within  communitiy)
%     Bi = Ci ~= nCi(i); % find index for diff system (i.e. between communitiy)
%     
%     Wv_temp = M(Wi,Wi); % extract this system
%     Bv_temp = M(Wi,Bi); % extract diff system
%     
%     Wv = [Wv, Wv_temp(logical(triu(ones(sum(Wi)),1)))'];
%     Bv = [Bv, Bv_temp(:)'];
%   end
%   
%   W(s) = mean(Wv); % mean this system
%   B(s) = mean(Bv); % mean diff system
%   d.S(s) = (W(s)-B(s))/W(s); % system segregation
%   
% end
% plotRegression(d.S,d.Age)
% title('System segregation - rest FC'); 
% xlabel('age'); ylabel('mean within - between system')
% 
% plotRegression(B',d.Age)
% title('Between System mean - rest FC');
% xlabel('age'); ylabel('mean between system')
% 
% % plotRegression(W',d.Age)
% % title('Within System mean - rest FC');
% % xlabel('age'); ylabel('mean within system')
% 
% % cmdStr = sprintf('export_fig %s',fullfile(outDir,'tmp.pdf'))
% % eval(cmdStr)





%% Save

% outName = fullfile(outDir,'data.mat');
% save(outName,'d');







end