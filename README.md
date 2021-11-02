# MAGIC-K-Net
Data Augmentation of Multi-coil MRI Data

This is the implementation code for the paper 'MAGnitude-Image-to-Complex K-space (MAGIC-K) Net: A Data Augmentation Network for Image Reconstruction'. If you used the code here, please use the citation: Wang F, Zhang H, Dai F, Chen W, Wang C, Wang H. MAGnitude-Image-to-Complex K-space (MAGIC-K) Net: A Data Augmentation Network for Image Reconstruction. Diagnostics (Basel). 2021 Oct 19;11(10):1935. doi: 10.3390/diagnostics11101935. PMID: 34679632; PMCID: PMC8534839.

Dataset:
Source: 1 subject with DWI of multi-coil k-space data + T1 Dicom
Target: N T1 Dicoms

Pre-requisite:
python3: tensorflow 2.0, tensorflow-keras 
matlab: spm12（co-registeration and dartel), NIFTI package

Deformation and Intensity Flow Field Learning:
Thanks to brainstrom: https://github.com/xamyzhao/brainstorm, use the T1 source as atlas and N T1 as the targets. Remember to co-register them first！

Field Applying:
1) Data Preprocess
Seperate the DWI multi-coil data into sensitivity maps(csm) and coil-combined image, seperate them into magnitude and phase
2) Intensity Flow Field Applying
Apply the intensity flow-field on the magintude of DWI,get N targets with the same deformation but different intensities from N targets.
3) Deformation Flow Field Applying
Apply the deformation flow field onto different intensities, hence you got NxN subjects with different local intensities and deformations.
4) Data Combine
Combine the magnitude and phase into multi-coil k-space data.

The implementation of the pipeline is quite complicated. Please follow the procedures below:
1) ColocMulti.py: Create the source with different intensities but the same deformation
2) MakeColorMS2NII.m: Make the Mcolor.mat into NIIs for the spatial deformation using DARTEL.
3) CoMS2NII3DARTEL.m: Change orientation of the T1 the same as DWI. (unnecessary if you have the same orientations) 
4) MSRawData2NII.m: Create the phase, csm-mag and csm-phase into NII as the DWI. 
5) MainOnline.m: Here we use DARTEL for the spatial deformation. Of cource you can use the one in the brainstorm, but we found this a better performance.
6) SpatialDeformOnline.m: For the phase of the DWI, csm-mag and csm-phase, first apply the deformation field on them.
7) IntensityCrossDeformation.m: For the magnitude of DWI, apply the deformation flow fields on the source with N different intensities to do the cross augmentation.
9) CrossNII2Complex.m: Combine the NXN data to create the multi-coil k-space data.
