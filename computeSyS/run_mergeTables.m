clear

list_bandNames = {'delta','theta','alpha','beta','lGamma', ...
  'broadband'};

t_main = readtable('csv/t_fMRI_schaefer_corr.csv');



%% Add Cattell
%Cattell
% headers = {'Cattell'};
headers = {'cattell_SS1','cattell_SS2','cattell_SS3','cattell_SS4'};

DAT = [];
DAT.rootdir = '/imaging/camcan/';
DAT.SessionList = {
     'tmpD',  '/cc700-scored/Cattell/release001/data/Cattell_<CCID>_scored.txt'
    };
DAT = CCQuery_CheckFiles(DAT);
DAT = CCQuery_LoadData(DAT);
tmpD = DAT.Data.tmpD.Data;
tmpH = DAT.Data.tmpD.Headers;

for s = 1:length(t_main.CCID); CCID = t_main.CCID{s};
  idx = find(strcmp(CCID,DAT.SubCCIDc));
  val = tmpD{idx,7};
  
  if isstr(val)
    t_main.Cattell_700(s) = str2num(val);
  else
    t_main.Cattell_700(s) = nan;
  end
  
end


%% Memory (PCA of HI tests)
%%Get Interview data
HI = CCQuery_LoadHIData('700', 'homeint');
HIadd = CCQuery_LoadHIData('700', 'additional');

tmpD = [HI.storyrecall_d,HI.storyrecall_i,HIadd.story_recognition]; %tmp = appendD;
tmpD = pca_RH(tmpD);

[t_main.Memory_700] = nan(height(t_main),1);
for s = 1:height(t_main); CCID = t_main.CCID{s};
  idx(s) = find(strcmp(CCID,HI.CCID));
  
  t_main.Memory_700(s) = tmpD(idx(s));
    
end


%% add remaining tables (excluding CCID, age etc)

%fMRI 700
%this one already T_main! %tmpT = readtable('csv/t_fMRI_schaefer_corr.csv'); t_main = [t_main,tmpT(:,3:end)];
tmpT = readtable('csv/t_fMRI_schaefer_ridgep.csv'); t_main = [t_main,tmpT(:,3:end)];
%fMRI 280
tmpT = readtable('csv/t_fMRI_cc280_schaefer_corr.csv'); t_main = [t_main,tmpT(:,3:end)];
tmpT = readtable('csv/t_fMRI_cc280_schaefer_ridgep.csv'); t_main = [t_main,tmpT(:,3:end)];
%fMRI SMT
tmpT = readtable('csv/t_fMRI_SMT_schaefer_corr.csv'); t_main = [t_main,tmpT(:,3:end)];
tmpT = readtable('csv/t_fMRI_SMT_schaefer_ridgep.csv'); t_main = [t_main,tmpT(:,3:end)];

%MEG 700
for band = 1:length(list_bandNames); bandName = list_bandNames{band}
  tmpT = readtable(sprintf('csv/t_MEG_%s_schaefer_corr.csv',bandName)); t_main = [t_main,tmpT(:,3:end)];
end
for band = 1:length(list_bandNames); bandName = list_bandNames{band}
  tmpT = readtable(sprintf('csv/t_MEG_%s_schaefer_ridgep.csv',bandName)); t_main = [t_main,tmpT(:,3:end)];
end
%MEG 280
for band = 1:length(list_bandNames); bandName = list_bandNames{band}
  tmpT = readtable(sprintf('csv/t_MEG_cc280_%s_schaefer_corr.csv',bandName)); t_main = [t_main,tmpT(:,3:end)];
end
for band = 1:length(list_bandNames); bandName = list_bandNames{band}
  tmpT = readtable(sprintf('csv/t_MEG_cc280_%s_schaefer_ridgep.csv',bandName)); t_main = [t_main,tmpT(:,3:end)];
end
%MEG SMT
for band = 1:length(list_bandNames); bandName = list_bandNames{band}
  tmpT = readtable(sprintf('csv/t_MEG_SMT_%s_schaefer_corr.csv',bandName)); t_main = [t_main,tmpT(:,3:end)];
end
for band = 1:length(list_bandNames); bandName = list_bandNames{band}
  tmpT = readtable(sprintf('csv/t_MEG_SMT_%s_schaefer_ridgep.csv',bandName)); t_main = [t_main,tmpT(:,3:end)];
end


writetable(t_main,'csv/merged_t.csv');



