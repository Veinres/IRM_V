# Ionization Region Model (IRM) - How-To Guide

**ver. 0.14**

![](img/IRM-Illustration.png "Pulse length IRM")

## Table Of Contents

[[_TOC_]]

## 0. Change log

|2020-05-27|Martin Rudolph|Initial draft |v 0.1|
| :- | :- | :- | :- |
|2020-07-07|Martin Rudolph|Added chapter on initial conditions|v 0.11|
|2020-10-10|Martin Rudolph|Removed inconsistency in gas temperature|V 0.12|
|2020-11-14|Martin Rudolph|Corrected calculation of beta\_av|V 0.13|
|2022-02-09|Joel Fischer|Converted to markdown, added Cu and W as well as new options|V 0.14|

## 1. Introduction

Introductory papers: \[[^Raadu2011]\], \[[^Huo2017]\]

## 2. Initial discharge conditions

Before the discharge ignities the code requires the presence of some minimum density of charge carriers. These values have changed over the time, so they are documented here for the latest version:

*Table 1: Initial discharge conditions*
|parameter|value|comment|
| :- | :- | :- |
|Cold electron temperature $`T_{ec}`$ |0.5|This value is set in *create\_Input\_fct.m* in line with the following command `T_e0 = 0.5;`|
|Cold electron density $`T_{ec}`$|1e+16|Is defined in *create\_species\_new.m*|
|Hot electron temperature $`T_{eh}`$|Typical values 70 to 300 eV|</p>This value is always deduced from the discharge potential in *ODEfile.m* with the following command `T\_eh = 2/3*F_Teh*Ud;`<p> </p>`F_Teh` is assumed to be ½. See also Huo et al. for details \[[^Huo2017]\].<p>|
|Hot electron density $`n_{eh}`$|1e+3|Is defined in *create\_species\_new.m*|

## 3. Adapt the IRM model

**Note:** It is still possible to adapt the model as described here. But when using already implemented materials, it is now also possible to specify certain parameters or properties without modifying the source code. In particular, the discharge type (gas/target combination), the fitting parameter grid, the process pressure, the pulse length and the solver time can be passed as arguments to *panel_Pfit_fct.m*.

### 3.1 Target material

#### 3.1.1 Switch between already implemented materials

Ar/Ti, Ar/C, Ar/Cu and Ar/W[^ArW] are three material systems that are already implemented. In order to swap from one to another do the following:

[^ArW]: This repository doesn't include the most recent version of Ar/W. It working correctly is not guaranteed.

1. In *create\_Input\_fct.m* change the matrices to Ar/Ti, Ar/C, Ar/Cu or Ar/W according to Table 2.

*Table 2: Selection of precalculated matrices depending on the material system.*
||Ar/Ti|Ar/C|Ar/Cu|Ar/W|
| :- | :- | :- | :- | :- |
|`fn_species =` |`'Spe_ArTi'`|`'Spe_ArC'`|`'Spe_ArC'`|`'Spe_ArC'`|
|`fn_reactions =`|`'Rea_ArTi'`|`'Rea_ArC'`|`'Rea_ArCu'`|`'Rea_ArW'`|
|`fn_precal =`|`'Precal_ArTi'`|`'Precal_ArC'`|`'Precal_ArCu'`|`'Precal_ArW'`|

2. Adapt the pressure according to section 3.3.
3. Select appropriate ranges for the right material system according to Table 3.

*Table 3: Selection of species type denpending on the material system.*
||Ar/Ti|Ar/C|Ar/Cu|Ar/W|
| :- | :- | :- | :- | :- |
|`Range.ion=`|`[s.Ari s.Tii s.Tiii]`|`[s.Ari s.Ci]`|`[s.Ari s.Arii s.Cui s.Cuii]`|`[s.Ari s.Wi s.Wii]`|
|`Range.refill=`|`[s.Ar]*`|`[s.Ar]`|`[s.Ar]`|`[s.Ar]`|
|`Range.meta=`|`[s.Arm]`|`[s.Arm]`|`[s.Arm3P0:s.Arm3P2]`|`[s.Arm3P0:s.Arm3P2]`|
|`Range.sput_metal=`|`[s.Ti]*`|`[s.C s.Cm1 s.Cm2 s.Cm3]`|`[s.Cu s.Cum1 s.Cum2 s.Cum3]`|`[s.W]`|
|`Range.sput_gas=`|`[s.ArW s.ArH]`|`[s.ArW s.ArH]`|`[s.ArW s.ArH]`|`[s.ArW s.ArH]`|

4. In *panel\_mode\_single\_run\_Pfit\_modified\_fct.m* activate the right analysis function, *analysis\_fct.m* for Ar/Ti or Ar/W, *analysis\_fct\_ArC.m* for Ar/C and *analysis\_fct\_ArCu.m* for Ar/Cu[^analysis-fct]. 
5. Change the discharge geometry as described in 3.2.
6. Change *plot\_densities\_fct.m* and some other plots depending on what you want to plot.

[^analysis-fct]: Each material system has its own analysis function. This may change at in a later version. 

#### 3.1.2 Implement new target material

Most data is stored in large look-up tables and matrices in order to avoid calculating similar properties more than once (see Table 4). 

*Table 4: Necessary input for the IRM model in order to implement a new target material.* 
||Explanations  	|ref. |
| :- | :- | :- |
|species|*Spe\_ArTi.mat*[^mat-name] in folder *species\_reactions*||
|reactions|*Rea\_ArTi.mat*[^mat-name] in folder *species\_reactions*||
|Cost of ionization as a function of cold and hot electron temperature |<p>This cost takes into account the energy loss by excitations that are not explicitly modelled. </p> <p>Data is stored in *pre-cal/Ec* and after running *create\_Precal.m* in *pre-cal/Precal\_ArTi.mat*[^mat-name] </p>|\[[^Gudmundsson2016]\]|
|Secondary electron emission coefficient as a function of ion species (Ar+, Metal+, Metall2+) and energy |Data is stored in *pre-cal/Secondary\_e\_yield* and after running *create\_Precal.m* in *pre-cal/Precal\_ArTi.mat*[^mat-name]||
|Sputter yield as a function of of ion species (Ar+, Metal+, Metall2+) and energy|Data is stored in *pre-cal/Sputter\_yield* and after running *create\_Precal.m* in *pre-cal/Precal\_ArTi.mat*[^mat-name]||

[^mat-name]: The .mat file may be called differently depending on the material system.

In order to implement new target material, the following scripts need to be touched in order to generate the new matrices:

1. **New species:** In the folder *species\_reaction*, add species properties to the list in *create\_species\_new.m*. Then run *create\_Spe\_Arc.m*.  For an Ar/C discharge, the command would be `create_species_new({'Ar'}, {'C'})`. Before you do that, you need to change the name of the output matrix, which is hidden in yet another function, *create\_Spe\_new.m* at the very end. This needs to change at some point but for now we have to live with it.

2. **New reactions:** Enter the required reactions in *create\_reactions\_new.m*. This is a generic function for all materials system. Add an `if` to select which reactions are needed for your materials system. At the end of the script type the name of the Rea matrix in `save('Rea_ArC', 'Rea')`. 

### 3.2 Discharge geometries

The toroidal IRM discharge geometriy is described in \[[^Huo2017]\] and defined by the height of the cylinder $`L = z_2 – z_1`$ and the inner and outer radius $`r_1`$ and $`r_2`$.

The discharge geometry is saved in the matrix *Para.mat* in the folder *parameters*. Values can be changed by changing the corresponding lines in the script *create\_Para.m* followed by running the script. *Para.mat* will then be overwritten with the new values. It is therefore good practice to only comment out the corresponding lines of code in *create\_Para.m*.

**Note:** If only the IR geometry needs to be change, the function *create\_Para\_new.m* also located in the *parameters* folder can be called: `create_para_new(r1, r2, z1, z2)`

### 3.3 Process gas pressure

In *create\_Input\_fct.m* change the line `Pressure = 0.5 ; % in Pa` to the new value. The Ar process gas density is adapted automatically.

**Note:** The process pressure can now also be adapted by passing the *IP* argument to the *panel_Pfit_fct* function. To use this mechanism, create a structure with a field called pressure, e.g. `IP.pressure = 0.5;` and pass it to the function in the appropriate position.

### 3.4 Process gas temperature

In *species\_reactions/create\_species\_new.m*, look for variable `Tg  = 0.0431; % in eV`. 0.0431eV correspond to 500K.

## 4. References and Footnotes

[^Raadu2011]: M. A. Raadu, I. Axnäs, J. T. Gudmundsson, C. Huo, and N. Brenning, “An ionization region model for high-power impulse magnetron sputtering discharges,” *Plasma Sources Sci. Technol.*, vol. 20, no. 6, 065007, p. 065007, 2011.

[^Huo2017]: C. Huo, D. Lundin, J. T. Gudmundsson, M. A. Raadu, J. W. Bradley, and N. Brenning, “Particle-balance models for pulsed sputtering magnetrons,” *J. Phys. D. Appl. Phys.*, vol. 50, no. 35, p. 354003, 2017.

[^Gudmundsson2016]: J. T. Gudmundsson, D. Lundin, N. Brenning, M. A. Raadu, C. Huo, and T. M. Minea, “An ionization region model of the reactive Ar/O2 high power impulse magnetron sputtering discharge,” *Plasma Sources Sci. Technol.*, vol. 25, no. 6, 2016.
