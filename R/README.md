**Intended Order of RMarkdown Reports**

Global signal:<br>

* runAnalysis_NoGlobalSignal.rmd
* runAnalysis_WithGlobalSignal.rmd


Normalisation: <br> 

* ^^ runAnalysis_WithGlobalSignal.rmd is classic ChanNorm!
* runAnalysis_Normalisation-OrthogonalNorm.rmd
* runAnalysis_Normalisation.OmitNorm.rmd
  
Correlation: <br> 

* ^^ runAnalysis_WithGlobalSignal.rmd is full correlation!
* runAnalysis_Correlation-Partial.rmd

Task: <br> 

* ^^ runAnalysis_WithGlobalSignal.rmd is full correlation!
* runAnalysis_Task-SMT.rmd
* TBC!!! runAnalysis_Task-Movie.rmd

Atlas: Schaefer: <br> 

* ^^ runAnalysis_Partial.rmd is the new reference for craddock vs. schaefer!
* runAnalysis_Atlas-Schaefer.rmd

  
## Results summary notes
1. Global Signal
- Effect of Age for Global + No Global Signal, but Global signal is critical for SyS to predict Cattell (independent of age).

- Use Global Signal hereon.

<br>

2. Normalisation
- SyS effects dont vary (i.e. same sig/nonsig patterns) between Chan et al. Normalisation vs. Orthogonal Normalisation.

- Use Chan Norm hereon.

<br>

3. Correlation
- Partial Correlation is better for cognitive effects (effect on fluid + memory now).

- Use Partial correlation (ridgep) hereon.

<br>

4. Task (SMT currently. Movie is TBC)
- SMT loses effect of SyS on Memory.

- Use resting state hereon.

<br>

4. Atlas
- Schaefer still has effects of age + Cattell. Loses effect on Memory (like with SMT).

- Thus Schaefer is appropriate to use for MEG replication.
 
<br>


  
  
  
  