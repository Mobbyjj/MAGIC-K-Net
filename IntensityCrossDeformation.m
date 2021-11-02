%% This file is to do the cross spatial transformation for with differnet intensity
clear;
clc;

sourcedir = '/home3/HWGroup/wangfw/BSTry2/B1000Multi_Coil_Co/';
subs = dir(sourcedir);
sourceMb1 = '/home3/HWGroup/wangfw/BSTry2/bai_Mb0.nii';
flowpath = '/home2/HWGroup/wangfw/MAGICNET/Processed/';
sourceflowfield = '/home2/HWGroup/wangfw/MAGICNET/Processed/bai_jiacheng/u_rc1bai_jiacheng_T1_dcm.nii';

for s = 4:length(subs)
    subname = subs(s).name;
    for k = 1:length(subs)
        if strcmp(subs(c).name, 'bai_jiacheng')||strcmp(subs(c).name, '.')||strcmp(subs(c).name, '..')
           continue;
        end
        tname = subs(k).name;
        flowfield2 = [flowpath,tname, '/u_rc1',tname,'_T1_dcm.nii'];
        filelist  = dir([sourcedir,subname,'/',subname,'_*.nii']);
    
    for j = 1:length(filelist)
        file{j} = [filelist(j).folder,'/',filelist(j).name];
    end
    files = cellstr(file);
    sss = files(:);
    prefix = tname;
    cd([sourcedir,tname]);
    spm_deformation_prefix(sourceflowfield, flowfield2, sourceMb1, sss,prefix);   
end
