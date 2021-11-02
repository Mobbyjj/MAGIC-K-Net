%% Save the deformed NIIs into rawdata; both with intensity change 
%% The orientation is the same as the T1, which means it is the same as the deformed b1000

clear;
clc;

rootdir = '/home3/HWGroup/wangfw/BSTry2/B1000Multi_Coil_Co/';
subs = dir(rootdir);


for k = 4:length(subs)
    subname = subs(k).name;
    subdir = [rootdir,subs(k).name,'/'];
    % under the same folder, all files have the same spatial deformations
    for m = 1:8
        g = num2str(m);
        csmmag = [subname,'bai_MCoil_',g,'.nii'];
        csm1 = load_nii([subdir,'/',csmmag]);
        img1 = csm1.img;
        sourcecsmmag(:,:,:,m) = img1;
        csmpha = [subname,'bai_PCoil_',g,'.nii'];
        csm2 = load_nii([subdir,'/',csmpha]);
        img2 = csm2.img;
        sourcecsmpha(:,:,:,m) = img2;
    end

    for i = 1:16
        for j = 1:8
            Map(:,:,i,j) = complex(squeeze(sourcecsmmag(:,:,i,j)).*cos(squeeze(sourcecsmpha(:,:,i,j))), squeeze(sourcecsmmag(:,:,i,j)).*sin(squeeze(sourcecsmpha(:,:,i,j))));
        end
    end
    
    % mag and phase and the original 
    b1kpha = [subname,'bai_Pb1000.nii'];
    b1kp = load_nii([subdir,'/',b1kpha]);
    b1kphase = b1kp.img;
    
    for f = 4:length(subs)
        sname = subs(f).name;
        if  strcmp(sname, subname)||strcmp(sname, '.')||strcmp(sname, '..')
           continue;
        end
        for g = 1:5
            b1kmag = [subname,sname,'_',num2str(g),'.nii'];
            b1km = load_nii([subdir,'/',b1kmag]);
            b1kmagn = b1km.img;
            for m = 1:16
                b1000(:,:,m) = complex(squeeze(b1kmagn(:,:,m)).*cos(squeeze(b1kphase(:,:,m))), squeeze(b1kmagn(:,:,m)).*sin(squeeze(b1kphase(:,:,m))));
            end
            savename = [subname,sname,'.mat'];
            save([subdir,savename],'Map','b1000');
        end
    end
 end