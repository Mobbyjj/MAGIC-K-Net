%% Try Deformation; use the existing flow-field of the source and 26 targets 
%% to do the deformation
clear;
clc;
% This file just do the spatial transformation to the phase and mag of 
% the b1000, csm phase and mag

flowpath = '/home2/HWGroup/wangfw/MAGICNET/Processed/';
sourceflowfield = '/home2/HWGroup/wangfw/MAGICNET/Processed/bai_jiacheng/u_rc1bai_jiacheng_T1_dcm.nii';
subs = dir(flowpath);
sourceMb1 = '/home3/HWGroup/wangfw/BSTry2/bai_Mb0.nii';
sourcedir = '/home3/HWGroup/wangfw/BSTry2/B1000Multi_Coil_Co/';

for c =1:length(subs)
    if strcmp(subs(c).name, 'bai_jiacheng')||strcmp(subs(c).name, '.')||strcmp(subs(c).name, '..')
           continue;
    end
    tname = subs(c).name;
    flowfield2 = [flowpath,tname, '/u_rc1',tname,'_T1_dcm.nii'];
    filelist  = dir([sourcedir,tname,'/bai*']);
    
    for j = 1:length(filelist)
        file{j} = [filelist(j).folder,'/',filelist(j).name];
    end
    files = cellstr(file);
    sss = files(:);
    prefix = tname;
    cd([sourcedir,tname]);
    spm_deformation_prefix(sourceflowfield, flowfield2, sourceMb1, sss,prefix);   
end