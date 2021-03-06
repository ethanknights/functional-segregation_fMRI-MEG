function checkFidError(D,fid,subDir)

megfid = D.fiducials;
%% Not quite working - D.fiducials.fid.pnt ^^ arent set properly?
%% D2 = D;
%% D2 = fiducials(D2,fid)  %just overwrites
%% No - Find fidcuals from rhino output?
%
%% Alternative (?):
%% same fid pnts as from: 
%% a = D.inv;
%% mriPnt = a{1}.datareg.fid_mri.fid.pnt
%% eegPnt = a{1}.datareg.fid_eeg.fid.pnt
%% Error = mriPnt - eegPnt;
%% Error = mean(sqrt(sum(Error.^2,2)));

mrifid = [];
mrifid.fid.label = {'Nasion';'LPA';'RPA'};
mrifid.fid.pnt = [...
  fid.BIDS.mm.Nasion(1:3); ...
  fid.BIDS.mm.LPA(1:3);    ...
  fid.BIDS.mm.RPA(1:3)     ...
  ];

Error = [];
for f = 1:length(megfid.fid.label)
  
  idx = contain(mrifid.fid.label{f},megfid.fid.label);
  
  Error(f,:) = megfid.fid.pnt(f,:) - mrifid.fid.pnt(idx,:);
  
end
Error = mean(sqrt(sum(Error.^2,2)));

%% write
check.fidError = Error;
oN = fullfile(subDir,...
  'check_fDist_Error.mat');
save(oN,'check');

end
 