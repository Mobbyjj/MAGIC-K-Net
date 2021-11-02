clear;
clc;

%% first you have to use dcm2nii to sort the dicoms by the series
% take the MPRAGE and DWI out, write in the origin and voxel size for further
% experiment 
%% change dicoms into nii 
% see the IMG2NII function
%% coregister
% for the target image
% coregister the MPRAGE and b0 image and apply the affine transformation to
% csms and all the other b-values
% 
% all the files are first sorted into '/<patientname>/<patientfiles>
% patientfiles includes: MPRAGE: '<patientname>_T1_DCM.nii'
%                        b-values: '<patientname>_MOrg_b<X>.nii'
%                                  '<patientname>_POrg_b<X>.nii'
%                                   X stands for the Xth b-value
%                        multicoils:'<patientname>_MCoil_<Y>.nii'
%                                   '<patientname>_PCoil_b<Y>.nii'
%                                   Y stands for the Yth coil

rootpath = '/home2/HWGroup/wangfw/DCM2COMPLEX';
segTpmPath = '/opt/apps/spm/spm12/tpm';
tpmpath = '/home2/HWGroup/wangfw/SPMTools/Template';

files = dir(rootpath);
dirFlags = [files.isdir];
subFolders = files(dirFlags);

%% here loop for every case of raw data to be transformed into the sourceImg
for c = 1:length(subFolders)
    if strcmp(subFolders(c).name, 'zhu_zhenyu')||strcmp(subFolders(c).name, '.')||strcmp(subFolders(c).name, '..')
           continue;
    end
    sourcename =  subFolders(c).name;
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
    spm_coregister_estimate(sourceMPRAGE,sourceMb1,sss)

    % C = load(sourceMat);
    % coilsize = size(C.trnCsm);
    % trnCsm = [nslice nrow ncol ncoil]

    spm_segmentation(sourceMPRAGE,segTpmPath);

    rc1source = strcat('rc1', sourceNii);
    rc2source = strcat('rc2', sourceNii);
    rc3source = strcat('rc3', sourceNii);
    rc4source = strcat('rc4', sourceNii);
    rc5source = strcat('rc5', sourceNii);

    rc1path = fullfile(sourcepath, rc1source);
    rc2path = fullfile(sourcepath, rc2source);
    rc3path = fullfile(sourcepath, rc3source);
    rc4path = fullfile(sourcepath, rc4source);
    rc5path = fullfile(sourcepath, rc5source);

    % use the rc files to matching the exisiting templates fo warpping    
    segedpath = cellstr([[rc1path,',1'];[rc2path,',1'];[rc3path,',1'];[rc4path,',1'];[rc5path,',1']]);
    spm_existing_template(segedpath, tpmpath);
    clear rc1path rc2path rc3path rc4path rc5path segedpath;
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
        seg_file = fullfile(targetpath,rtargetNii);
        spm_segmentation(seg_file, segTpmPath);

        rc1target = strcat('rc1', rtargetNii);
        rc2target = strcat('rc2', rtargetNii);
        rc3target = strcat('rc3', rtargetNii);
        rc4target = strcat('rc4', rtargetNii);
        rc5target = strcat('rc5', rtargetNii);

        rc1path = fullfile(targetpath, rc1target);
        rc2path = fullfile(targetpath, rc2target);
        rc3path = fullfile(targetpath, rc3target);
        rc4path = fullfile(targetpath, rc4target);
        rc5path = fullfile(targetpath, rc5target);

        % use the rc files to matching the exisiting templates fo warpping    
        segedpath = cellstr([[rc1path,',1'];[rc2path,',1'];[rc3path,',1'];[rc4path,',1'];[rc5path,',1']]);
        spm_existing_template(segedpath, tpmpath);

        % use the u_rc1rfile for deformation
        % 29 is the number of coils, you can specisfy it according to the
        % reality
        flowfield1 = strcat('u_rc1',sourceNii);
        flowfield1full = fullfile(sourcepath,flowfield1);
        flowfield2 = strcat('u_rc1',rtargetNii);
        spm_deformation(flowfield1full, flowfield2, sourceMb1, sss);

        % coregister the deformed one to match the target csms and phase 
        % unnessesary if you only have the target dicoms
        %
        for i = 1:4
            g = num2str(i);
            dsource_b_Mag{i}= strcat(targetpath,'\d',sourcename, '_MOrg_b',g,'.nii,1');
            dsource_b_Pha{i}= strcat(targetpath,'\d',sourcename, '_POrg_b',g,'.nii,1');
        end
        for j = 1:26
            g = num2str(j);
            dsourcecoils_Mag{j} = strcat(targetpath,'\d',sourcename,'_MCoil_',g,'.nii,1');
            dsourcecoils_Pha{j} = strcat(targetpath,'\d',sourcename,'_PCoil_',g,'.nii,1');
        end
        DSourceImage = cellstr([dsource_b_Mag, dsource_b_Pha, dsourcecoils_Mag, dsourcecoils_Pha]);
        ddd =DSourceImage(:);

        targetb0 = strcat(targetpath,'\',subFolders(k).name, '_MOrg_b1.nii,1');
        sourceb0 = strcat(targetpath,'\d',sourcename, '_MOrg_b1.nii,1');
        spm_coregister_estimate_reslice(targetb0,sourceb0,ddd);
    end
    clear sourcecoils_Mag sourcecoils_Pha source_b_Mag source_b_Pha sss SourceImage dsource_b_Mag dsource_b_Pha dsourcecoils_Mag dsourcecoils_Pha DSourceImag ddd;
end



