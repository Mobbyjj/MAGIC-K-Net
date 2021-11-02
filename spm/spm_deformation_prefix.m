function spm_deformation(Flowfield1, Flowfield2,ReferenceID,SourceImage,prefix)
    % flowfield1 is the source wrapped field
    % flowfield2 is the target wrapped field
    clear matlabbatch;
    matlabbatch{1}.spm.util.defs.comp{1}.dartel.flowfield = {Flowfield1};
    matlabbatch{1}.spm.util.defs.comp{1}.dartel.times = [1 0];
    matlabbatch{1}.spm.util.defs.comp{1}.dartel.K = 6;
    matlabbatch{1}.spm.util.defs.comp{1}.dartel.template = {''};
    matlabbatch{1}.spm.util.defs.comp{2}.dartel.flowfield = {Flowfield2};
    matlabbatch{1}.spm.util.defs.comp{2}.dartel.times = [0 1];
    matlabbatch{1}.spm.util.defs.comp{2}.dartel.K = 6;
    matlabbatch{1}.spm.util.defs.comp{2}.dartel.template = {''};
    matlabbatch{1}.spm.util.defs.comp{3}.id.space = {ReferenceID};
    matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = SourceImage;
    matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savepwd = 1;
    matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 4;
    matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 1;
    matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
    matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = prefix;
    %run matlabbatch
    spm_jobman('run',matlabbatch);
end