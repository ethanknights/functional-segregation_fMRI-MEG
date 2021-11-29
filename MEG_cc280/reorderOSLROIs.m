function [y,labels_corrMat] = reorderOSLROIs(y)

y_reorder = [];
[labels,order,new_labels,new_order] = fmri_d100reduced_labels;
for i = 1:length(labels)
  y_reorder(i,:) = y(new_order(i),:);
end
labels_corrMat = new_labels; %to save
y = y_reorder;