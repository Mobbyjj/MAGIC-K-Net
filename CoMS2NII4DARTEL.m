% This file is to coregister colored MSDWI to T1 for DARTEL deformation
clear;
clc;

addpath('/home2/HWGroup/wangfw/SPMTools');

load('/home3/HWGroup/wangfw/BSTry2/atlas.mat');
load('/home3/HWGroup/wangfw/BSTry2/bai_jiacheng.mat');
referenceT1NII = '/home2/HWGroup/wangfw/MAGICNET/NetworkData/bai_jiacheng/bai_jiacheng_T1_dcm.nii';

colordir = '/home3/HWGroup/wangfw/BSTry2/B1000Multi_Coil_Co/';

niiflowdir = '/home3/HWGroup/wangfw/BSTry2/FLOW_CO/';

MSpix = [0.95,0.95,5];

% use the b0 to coregister
MOrg = flip(permute(abs(Org),[2,3,1,4]),1);
MOrgb0 = squeeze(MOrg(:,:,:,1));
b0 = permute(squeeze(MOrgb0),[2,1,3]);

MSDWIfile = '/home2/HWGroup/wangfw/MAGICNET/NetworkData/bai_jiacheng/bai_jiacheng_b0_MSDWI.nii';
info = load_nii(MSDWIfile);
origin = info.hdr.hist.originator;
MSOrigin = origin(1:3);
datatype = 16;

MOrgb0_1 = make_nii(b0, MSpix, MSOrigin, datatype);
save_nii(MOrgb0_1,'/home3/HWGroup/wangfw/BSTry2/bai_MSOrg2T1.nii');
%%
source_img = '/home3/HWGroup/wangfw/BSTry2/bai_MSOrg2T1.nii';

filelist = dir(fullfile(colordir, '\*.*')); 
filelist = filelist(~[filelist.isdir]); 

otherimg = cellstr(filelist);
other_img = otherimg(:);

%spm_coregister_estimate_reslice(reference_img, source_img, other_img);


