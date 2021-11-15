%% ROILabels functions
%% ========================================================================
function [roiLabels, t] = makeROILabels(networkLabels_str)
  t = table(networkLabels_str); finalCol = width(t) + 1; t.Properties.VariableNames = {'Var1'};
  idx=find(contains(t.Var1,'_Vis_'));         t(idx,finalCol) = array2table(ones * 1); t(idx,finalCol+1) = cell2table({'Vis'});
  idx=find(contains(t.Var1,'_SomMot_'));      t(idx,finalCol) = array2table(ones * 2); t(idx,finalCol+1) = cell2table({'SomMot'});
  idx=find(contains(t.Var1,'_DorsAttn_'));    t(idx,finalCol) = array2table(ones * 3); t(idx,finalCol+1) = cell2table({'DorsAttn'});
  idx=find(contains(t.Var1,'_SalVentAttn_')); t(idx,finalCol) = array2table(ones * 4); t(idx,finalCol+1) = cell2table({'SalVentAttn'});
  idx=find(contains(t.Var1,'_Limbic_'));      t(idx,finalCol) = array2table(ones * 5); t(idx,finalCol+1) = cell2table({'Limbic'});
  idx=find(contains(t.Var1,'_Cont'));         t(idx,finalCol) = array2table(ones * 6); t(idx,finalCol+1) = cell2table({'Cont'});
  idx=find(contains(t.Var1,'_Default'));      t(idx,finalCol) = array2table(ones * 7); t(idx,finalCol+1) = cell2table({'Default'});
  roiLabels = t.Var3;
end
