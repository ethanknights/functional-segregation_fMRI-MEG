# Functional Segregation (fMRI & MEG)

<h3> Prerequisites <h3>
- Matlab (with SPM & OSL toolboxes) </br>
- ROI Community atlas: atlas-bignetworks_gamma26_dim-3D </br>
- ROI craddock atlas:  atlas-craddock_ROI-840_dim-4D.nii </br></br>

<h1> 1. Generate ROIs to test for an age-related decrease in functional connectivity system segregation </h1>
For Atlas descriptions, see ROIs/README, then generate available ROI atlases:

```c
cd ROIs
wrapper
```
</br>

<h1> 2. fMRI Resting State FC </h1>

```
cd fMRI
edit runAnalysis_volumeSpace.m
```

- Next set the atlasName variable to the required atlas case e.g.:
```c
atlasName = 'atlas-craddock_ROIs-724';
```

- (These should correspond to a case with pre-defined paths, like:)
```c
switch atlasName
  case 'atlas-craddock_ROIs-724'
    atlasInfo.fN = fullfile(repoDir,'ROIs','craddock','atlas-craddock_ROI-724_dim-4D.nii');
    atlasInfo.t = readtable(fullfile(repoDir,'ROIs','craddock','atlas-craddock_ROI-724.csv'));
end
```

- Ready for generating System Segregatiion (SyS):
```c
runAnalysis_volumeSpace
 /* Key output includes: fMRI/data/atlas-craddock_ROIs-724/systemSegregationTable/SyS_associationOnly.csv
```
 
 - R scripts also available for more advanced analysis (e.g. robust linear modelling)
 ```R
setwd('fMRI/R/)'
run_ageModel.R 
#...
rlm()
#...
#Key output includes: images/rlm_age~Sys.png
 ```
 </br>


<h1> 3. MEG Resting State FC </h1>
