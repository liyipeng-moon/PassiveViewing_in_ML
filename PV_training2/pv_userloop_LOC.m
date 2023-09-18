function [C,timingfile,userdefined_trialholder] = pv_userloop_LOC(MLConfig,TrialRecord)
persistent timing_filename_returned ID;

C=[];
addpath(genpath(pwd))
localizer_folder = pwd;
cd ..\
addpath(genpath(pwd))
cd(localizer_folder)
timingfile = 'training.m';
userdefined_trialholder = '';
if isempty(timing_filename_returned)
    timing_filename_returned = true;
    return
end

%% parameters which should not change if we fix it
imginfo_valut='./Img_vault';

%% Data
Localizer_set = 'FOB';
TrialRecord.User.img_info = select_dataset(imginfo_valut, Localizer_set);
ID = [];
for m=1:length(TrialRecord.User.img_info.img_path)
    temp_img = mglimread(TrialRecord.User.img_info.img_path{m});
    temp_img = mglimresize(temp_img,[TrialRecord.Editable.img_size,TrialRecord.Editable.img_size]);
    ID(m) = mgladdbitmap(temp_img);  % mgladdbitmap returns an MGL object ID that is a double scalar.
end
mglsetproperty(ID,'active',false);  % Turn off all images.
TrialRecord.User.imageIDs = ID;

C = {'fix(0,0)'};
% Send the IDs to the timing script.

%% Generating Design
% example_design

leadin_time = 0; leadout_time = 0;
DM = [ randperm(96), randperm(96), randperm(96), randperm(96), randperm(96), randperm(96)];
category_order = randperm(6)-1;

DisplayOnset = ones(size(DM))*250;
DisplayOffset = ones(size(DM))*150;

total_time = leadin_time + leadout_time + sum(DisplayOnset) + sum(DisplayOffset);
% leadin
imglist = cell(1,3);imglist(1,1)={[]};imglist(1,2)={[]};imglist(1,3)={leadin_time}; 
total_time = total_time+ imglist{end,3};

for img_trial_idx = 1:length(DM)
        imglist(end+1,1)={ID(DM(img_trial_idx))};
        imglist(end,2)={[0,0]};
        imglist(end,3)={DisplayOnset(img_trial_idx)};
        imglist(end+1,1)={[]};
        imglist(end,2)={[]};
        imglist(end,3)={DisplayOffset(img_trial_idx)};
end
% lead out
imglist(end+1,1)={[]};imglist(end,2)={[]};imglist(end,3)={leadout_time}; 
TrialRecord.User.imglist = imglist;
TrialRecord.User.Totaltime = total_time;
% example img


if(TrialRecord.CurrentTrialNumber~=0)

end
end