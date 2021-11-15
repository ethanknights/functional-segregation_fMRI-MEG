%% lazy - arugments from workspace

function [lateralityScore,keepIdx] = doLaterality(corrMat,roiLabels_raw)

%% generate index for LH,RH ROIs (based on Schaefer ROI name strings)
lateralityIdx = [];
roiCounter = 0;
for r = 1:length(roiLabels_raw)/2
  currROI = roiLabels_raw{r};
  homoROI = strrep(currROI,'_LH_','_RH_');
  
  idx = find(strcmp(roiLabels_raw,homoROI));
  
  if idx %if RH ROI exists, then add to lateralityIdx
    roiCounter = roiCounter + 1;
    
    lateralityIdx(roiCounter,1) = r;    %LH
    lateralityIdx(roiCounter,2) = idx;  %RH
  end
end
tmp(:,1) = roiLabels_raw(lateralityIdx(:,1));
tmp(:,2) = roiLabels_raw(lateralityIdx(:,2));
%disp(tmp);


%% Per sub
a = []; %between-hemi connections
b = []; %remaining connections
for s = 1:size(corrMat,3); currCorrMat = corrMat(:,:,s);
  %% A - average between hemi connections (LH,RH)
  for r = 1:size(lateralityIdx,1)
    a.subjBYconnection(s,r) = currCorrMat( lateralityIdx(r,1),...
      lateralityIdx(r,2));
  end
  
  keepIdx.homoROIs = lateralityIdx;
  
  %% B - average remaining connections (excluding diagonal!)
  idx = triu(ones(size(currCorrMat,1)),1); %get entire upper triangle
  % and drop indices belonging to lateralityIdx
  for r = 1:size(lateralityIdx,1)
    idx(lateralityIdx(r,1),...
      lateralityIdx(r,2)) = 0;
  end
  %figure,imagesc(idx),title('between hemi-connections removed')
  idx = find(idx);
  b.subjBYconnection(s,:) = currCorrMat(idx);
  
  keepIdx.nonhomoROIs = idx;
end
a.mean = mean(a.subjBYconnection,2); %between-hemi connection mean
b.mean = mean(b.subjBYconnection,2); %other remaining connections mean


lateralityScore = a.mean - b.mean; %Between-hemi connections (controlling for remaining connections)
