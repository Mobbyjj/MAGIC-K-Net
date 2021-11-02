%% This file is to create the source Niis and coregister them with MPRAGE

rootpath = '/home2/HWGroup/wangfw/DCM2COMPLEX';
spatialpath = '/home3/HWGroup/wangfw/BSTry2/B1000Multi_Coil_Co/';
sourcefile = '/home3/HWGroup/wangfw/BSTry2/bai_jiacheng.mat';
reference_img = '/home2/HWGroup/wangfw/MAGICNET/NetworkData/bai_jiacheng/bai_jiacheng_T1_dcm.nii';

MSDWIfile = '/home2/HWGroup/wangfw/MAGICNET/NetworkData/bai_jiacheng/bai_jiacheng_b0_MSDWI.nii';
info = load_nii(MSDWIfile);
origin = info.hdr.hist.originator;
MSOrigin = origin(1:3);
datatype = 16;
MSpix = [0.95,0.95,5];

%% first create the source rawdata and coregister them to T1 source
load(sourcefile);

MOrg = flip(permute(abs(Org),[2,3,1,4]),1);
MOrgb0 = squeeze(MOrg(:,:,:,1));
b0 = permute(squeeze(MOrgb0),[2,1,3]);
MOrgb0_2 = make_nii(b0, MSpix, MSOrigin, datatype);
save_nii(MOrgb0_2,'bai_Mb0.nii');
source_img = 'bai_Mb0.nii';

ORG = flip(permute(Org,[2,3,1,4]),1);
CSM = flip(permute(Csm,[2,3,1,4]),1);

b1000mag = abs(permute(squeeze(ORG(:,:,:,3)),[2,1,3]));
b1000pha = angle(permute(squeeze(ORG(:,:,:,3)),[2,1,3]));
MOrgb0_1 = make_nii(b1000mag, MSpix, MSOrigin, datatype);
save_nii(MOrgb0_1,'bai_Mb1000.nii');
POrgb0_1 = make_nii(b1000pha, MSpix, MSOrigin, datatype);
save_nii(POrgb0_1,'bai_Pb1000.nii');
sourceNiis = 'bai_Mb1000.nii';
sourceb1000{1} = 'bai_Mb1000.nii';
sourceb1000{2} = 'bai_Pb1000.nii';

for j = 1:8
    Mcoil_1 = permute(abs(squeeze(CSM(:,:,:,j))),[2,1,3]);
    Pcoil_1 = permute(angle(squeeze(CSM(:,:,:,j))),[2,1,3]);
    Mcoil_1_n = make_nii(Mcoil_1,MSpix, MSOrigin, datatype);
    Pcoil_1_n = make_nii(Pcoil_1,MSpix, MSOrigin, datatype);
    save_nii(Mcoil_1_n,['bai_MCoil_',num2str(j),'.nii']);
    save_nii(Pcoil_1_n,['bai_PCoil_',num2str(j),'.nii']);
    sourcecoils_Mag{j} = ['bai_MCoil_',num2str(j),'.nii'];
    sourcecoils_Pha{j} = ['bai_PCoil_',num2str(j),'.nii'];
    clear Mcoil_1  Pcoil_1 Mcoil_1_n Pcoil_1_n;    
end
source_img = 'bai_Mb0.nii';
    
SourceImage = cellstr([sourcecoils_Mag, sourcecoils_Pha, sourceb1000]);
sss = SourceImage(:);

spm_coregister_estimate(reference_img, source_img, sss);
%%

subs = dir(flowpath);

%% first create the source rawdata and coregister them to T1 source
for c = 1:length(subs)
    if strcmp(subs(c).name, 'bai_jiacheng')||strcmp(subFolders(c).name, '.')||strcmp(subFolders(c).name, '..')
           continue;
    end
    tname =  subs(c).name;
    savetarget = [spatialpath,tname];
    
    copyfiles
    
    sourceNii = strcat(sourcename,'_T1_dcm.nii');
    sourceMatName = strcat(sourcename,'.mat');
    sourcepath = fullfile(rootpath,sourcename);
    sourceMat = fullfile(sourcepath,sourceMatName);
    sourceMPRAGE = fullfile(sourcepath,sourceNii);
    sourceMb1 = strcat(sourcepath,'\',sourcename, '_MOrg_b1.nii');
    % first coregister all the coils and bs the same as the sourcemMPRAGE;
    for i = 1:4
        g = num2str(i);
        source_b_Mag{i}= strcat(sourcepath,'\',sourcename, '_MOrg_b',g,'.nii');
        source_b_Pha{i}= strcat(sourcepath,'\',sourcename, '_POrg_b',g,'.nii');
    end
    for j = 1:26
        g = num2str(j);
        sourcecoils_Mag{j} = strcat(sourcepath,'\',sourcename,'_MCoil_',g,'.nii');
        sourcecoils_Pha{j} = strcat(sourcepath,'\',sourcename,'_PCoil_',g,'.nii');
    end
    SourceImage = cellstr([source_b_Mag, source_b_Pha, sourcecoils_Mag, sourcecoils_Pha]);
    sss = SourceImage(:);

    %%
    for k = 1:length(subFolders)
        if strcmp(subFolders(k).name,sourcename)||strcmp(subFolders(k).name, '.')||strcmp(subFolders(k).name, '..')
            continue;
        end
        filepath = fullfile(rootpath,subFolders(k).name);
        cd (filepath);

        targetNii = strcat(subFolders(k).name, '_T1_dcm.nii');
        targetpath = fullfile(rootpath, subFolders(k).name);
        targetMPRAGE = fullfile(targetpath,targetNii);
        otherImage = {''};
        spm_coregister_estimate_reslice(sourceMPRAGE, targetMPRAGE,otherImage);

        % use the coregistered nii for segmentation 
        rtargetNii = strcat('r',targetNii);


        % use the u_rc1rfile for deformation
        % 29 is the number of coils, you can specisfy it according to the
        % reality
        
        flowfield1 = strcat('u_rc1',sourceNii);
        flowfield1full = fullfile(sourcepath,flowfield1);
        flowfield2 = strcat('u_rc1',rtargetNii);
        spm_deformation(flowfield1full, flowfield2, sourceMb1, sss);

    end
    clear sourcecoils_Mag sourcecoils_Pha source_b_Mag source_b_Pha sss SourceImage dsource_b_Mag dsource_b_Pha dsourcecoils_Mag dsourcecoils_Pha DSourceImag ddd;
end



