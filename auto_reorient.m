function auto_reorient(p)
%% Autoreorients images to MNI space
% Call auto_reorient with auto_reorient() --> this brings up GUI, where you
% can select the images you want to reorient to MNI space
% The template used is the SPM canonical single subject template 
% (single_subj_T1.nii) using function (minimally!) adapted from 
% https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=SPM;d1f675f1.0810
% Original function use SPM canonical image avg152T1.nii, current function
% uses single_subj_T1.nii)
% Original author: Carlton Chu

spmDir=which('spm');
spmDir=spmDir(1:end-5);
tmpl=[spmDir 'canonical\single_subj_T1.nii'];
vg=spm_vol(tmpl);
flags.regtype='rigid';
p=spm_select(inf,'image');
for i=1:size(p,1)
    f=strtrim(p(i,:));
    spm_smooth(f,'temp.nii',[12 12 12]);
    vf=spm_vol('temp.nii');
    [M,scal] = spm_affreg(vg,vf,flags);
    M3=M(1:3,1:3);
    [u s v]=svd(M3);
    M3=u*v';
    M(1:3,1:3)=M3;
    N=nifti(f);
    N.mat=M*N.mat;
    create(N);
end