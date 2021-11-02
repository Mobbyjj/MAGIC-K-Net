function spm_coregister_estimate(reference_img, source_img, other_img)
    clear matlabbatch;
    matlabbatch{1}.spm.spatial.coreg.estimate.ref = {reference_img};
    matlabbatch{1}.spm.spatial.coreg.estimate.source = {source_img};
    matlabbatch{1}.spm.spatial.coreg.estimate.other = other_img;
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
    % run the job wizout it would not work
    spm_jobman('run',matlabbatch);
end
    
    