%first drop irrelevant networks
listNetworkStrToDrop = {'_Limbic_','_Vis_','_SomMot_'};
for n = 1:length(listNetworkStrToDrop)
  idx = find(contains(t.Var2,listNetworkStrToDrop{n})); 
  if exist('y','var'); y(idx,:) = []; end
  if exist('t','var'); t(idx,:) = []; end
end
% %2nd drop some form each network (LH/RH)
% idx = find(contains(t.Var2,'7Networks_LH_DorsAttn_Post_1')); y(idx,:) = []; t(idx,:) = [];
% idx = find(contains(t.Var2,'7Networks_RH_DorsAttn_Post_1')); y(idx,:) = []; t(idx,:) = [];
% idx = find(contains(t.Var2,'7Networks_LH_SalVentAttn_ParOper_1')); y(idx,:) = []; t(idx,:) = [];
% idx = find(contains(t.Var2,'7Networks_RH_SalVentAttn_TempOccPar_1')); y(idx,:) = []; t(idx,:) = [];
% idx = find(contains(t.Var2,'7Networks_LH_Cont_Par_1')); y(idx,:) = []; t(idx,:) = [];
% idx = find(contains(t.Var2,'7Networks_RH_Cont_Par_1')); y(idx,:) = []; t(idx,:) = [];
% idx = find(contains(t.Var2,'7Networks_LH_Default_Par_1')); y(idx,:) = []; t(idx,:) = [];
% idx = find(contains(t.Var2,'7Networks_RH_Default_Par_1')); y(idx,:) = []; t(idx,:) = [];
% idx = find(contains(t.Var2,'7Networks_LH_DorsAttn_Post_2')); y(idx,:) = []; t(idx,:) = [];
% idx = find(contains(t.Var2,'7Networks_RH_DorsAttn_Post_2')); y(idx,:) = []; t(idx,:) = [];
% idx = find(contains(t.Var2,'7Networks_LH_DorsAttn_Post_3')); y(idx,:) = []; t(idx,:) = [];
% idx = find(contains(t.Var2,'7Networks_RH_DorsAttn_Post_3')); y(idx,:) = []; t(idx,:) = [];
% idx = find(contains(t.Var2,'7Networks_LH_DorsAttn_Post_4')); y(idx,:) = []; t(idx,:) = [];
% idx = find(contains(t.Var2,'7Networks_RH_DorsAttn_Post_4')); y(idx,:) = []; t(idx,:) = [];
if exist('t','var')
  roiLabels = t.Var2;
end