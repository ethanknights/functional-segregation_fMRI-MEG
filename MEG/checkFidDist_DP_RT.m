function checkfDist_DP_RT(D,subDir)

%% Save value to check (plus the existence of this output file makes it 
%% easy to tell if all subjects finished)

check.fDist = spm_eeg_inv_checkdatareg_3Donly_rt(D);
oN = fullfile(subDir,...
  'check_fDist_DP_RT.mat');
save(oN,'check');
end