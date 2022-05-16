# Functional System Segregation (SyS) for fMRI & MEG in the Cam-CAN Cohort.

## Prerequisites
* Matlab
  * SPM
  * OSL
* Atlases
  * ROI Community atlas: atlas-bignetworks_gamma26_dim-3D
  * ROI Craddock atlas:  atlas-craddock_ROI-840_dim-4D.nii
  * ROI Schaefer atlas:  Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm.nii 

<br>

# 1. Pipeline: fMRI Resting State Preprocessing

There are multipel variations of the same pipeline with minor changes that are contained within independent directories. Variations include using different atlases (craddock vs. schaefer) or preprocessing parameters (e.g. including global signal as a confound regressor vs. not). 
<br>
Generally, the gist is to use Matlab to perform preprocessing and then use the R to perform regression models on the output SyS metrics. 

For example, to extract ROI data and calculcate SyS for the Schaefer atlas:

```c
cd fMRI_Schaefer
runAnalysis
/* Key output includes: 
./data/002_getRestingStateFC/schaefer/CC110033_corrM.mat
This contains the timeseries adjusted for confounds in variable 'aY' (i.e. a [time x ROI]
```

A list of the variations of these pipeline are below:

- fMRI_craddock | Use the Craddock et al. (2012) ROI atlas.
- fMRI_craddock_noGlobalSignal | As above, but without using global signal as a confound regressor during GLMs.
- fMRI_Schaefer | Use the Schaefer et al. (2018) ROI atlas.
- fMRI_craddock_cc280 | Using the Cam-CAN 3 cohort dataset with the Craddock atlas.
- fMRI_Schaefer_cc280 | Using the Cam-CAN 3 cohort dataset with the Schaefer atlas.

# 2. Pipeline: MEG Resting State Preprocessing
For MEG there are fewer variations of the pipeline (only a variation for using either the CC700 or CC280 cohort).

```c
cd MEG
runAnalysis
```

# 3. Pipline: Calculating SyS for fMRI & MEG
Once all variations of the pipelines are ran, return to the root directory and run the pipeline that will calculate SyS from each of these fMRI + MEG timeseries, before merging all subject's SyS data into a .csv table (including age and cognitive performance variables):

```c
cd ../
cd computeSyS 
run_master /* Performs ROI x ROI correlations using nets_netmats.m */
/* Key output for modelling in R includes: merged_t.csv
```

A list of the variations of these pipeline are below:

- computeSyS | For the Schaefer Atlas
- computeSyS_craddock | For the Craddock Atlas.
- computeSyS_craddock_noGlobalSignal | For the initial pipeline version without including global signal as a confound regressor. 
  - Note that every pipeline writes a table that includes data for
    - Within network correlation [W]
    - Between network correlation [B]
    - System Segregation [SyS]
      - And these SyS metrics are calculated with:
        - Partial correlation [ridgep] vs. full correlation [corr]
        - Different normalisation formulae including from Chan et al. (2014) [ChanNorm], an orthogonal Within + Between value [just called SyS] and no normalisation [noNorm].


# 4. Regression modelling in R
Finally, use .Rmd files wite .html files that report the results from multiple regression modelling (e.g. to test if age predicts SyS, or if SyS predicts cogntiive performance independet of age).
 

```R
setwd('R')
runAnalysis_Atlas-Schaefer.Rmd
#Key output includes: runAnalysis_Atlas-Schaefer.html
```

Refer to ```R/README.md```for the order in which these files were designed to be ran.


# Next Steps
Normalise age effects with mean of timeseries.
<br>
Multivariate distance correlation.
<br>
Calculcate SyS with movie data (rather than SMT task)