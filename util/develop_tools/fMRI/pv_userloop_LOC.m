function [C,timingfile,userdefined_trialholder] = pv_userloop_LOC(MLConfig,TrialRecord)
persistent timing_filename_returned ID; global   DeviceFreeMode;

C=[];

localizer_folder = pwd;
cd ..\..\..\
addpath(genpath(pwd))
cd(localizer_folder)
timingfile = 'localizer.m';
userdefined_trialholder = '';
if isempty(timing_filename_returned)
    timing_filename_returned = true;
    return
end

%% parameters which should not change if we fix it
imginfo_valut='C:\Users\PC\Desktop\Img_vault';
DeviceFreeMode=1;

%% Data
Localizer_set = 'FOB';
TrialRecord.User.img_info = select_dataset(imginfo_valut, Localizer_set);
ID = [];
for m=1:length(TrialRecord.User.img_info.img_path)
    temp_img = mglimread(TrialRecord.User.img_info.img_path{m});
    temp_img = mglimresize(temp_img,[TrialRecord.User.img_info.default_params.img_size,TrialRecord.User.img_info.default_params.img_size]);
    ID(m) = mgladdbitmap(temp_img);  % mgladdbitmap returns an MGL object ID that is a double scalar.
end
mglsetproperty(ID,'active',false);  % Turn off all images.
TrialRecord.User.imageIDs = ID;

C = {'fix(0,0)'};
% Send the IDs to the timing script.

%% Generating Design
% example_design
DM = [];
category_order = randperm(6)-1;
for cc = 1:length(category_order)
    DM = [DM,randperm(4)+16*category_order(cc)];
end
plot(DM)
DisplayOnset = ones(size(DM))*500;
DisplayOffset = ones(size(DM))*500;
for cc = 1:length(category_order)
    ibi = cc*4;
    DisplayOffset(ibi) = DisplayOffset(ibi) + randi(3)*1000;
end

total_time = 0;
imglist = cell(0,3);

for img_trial_idx = 1:length(DM)
        imglist(end+1,1)={ID(DM(img_trial_idx))};
        imglist(end,2)={[0,0]};
        imglist(end,3)={DisplayOnset(img_trial_idx)}; total_time = total_time+ imglist{end,3};
        imglist(end+1,1)={[]};
        imglist(end,2)={[]};
        imglist(end,3)={DisplayOffset(img_trial_idx)}; total_time = total_time+ imglist{end,3};
end

TrialRecord.User.imglist = imglist;
TrialRecord.User.Totaltime = total_time;
% example img
imshow(TrialRecord.User.img_info.example_img);title(TrialRecord.User.img_info.category_info,'Interpreter','none')
end