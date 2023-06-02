function [C,timingfile,userdefined_trialholder] = pv_userloop(MLConfig,TrialRecord)
persistent timing_filename_returned ID dataset_memory; global zeroMQ_handle;

C=[];
addpath(genpath(pwd))
timingfile = 'st_test_OE.m';
timingfile = 'st_test.m';
userdefined_trialholder = '';
if isempty(timing_filename_returned)
    timing_filename_returned = true;
    return
end

%% parameters which should not change if we fix it
Local_OE_IP = '222.29.33.102';
WKS_OE_IP = '192.1168.3.41';
OE_IP = Local_OE_IP;
imginfo_valut='D:\Img_vault';
TrialRecord.User.image_train = 200;
switch_token=0;

%% Connecting to OE
if(strcmp(timingfile,'st_test_OE.m'))
    OE_config = connect_OE(OE_IP);
    if(OE_config.success)
        TrialRecord.User.O = 1;
    else
        warning('Fail to Connect OE, see message above');return;
    end
end
%% initialize datasets
if (0==TrialRecord.CurrentTrialNumber) % the first trial
    % select data
    [TrialRecord.User.current_set,TrialRecord.User.current_idx, TrialRecord.User.CategoryIdx, img_path,default_params, TrialRecord.User.category_info, TrialRecord.User.example_img,TrialRecord.User.condition_nm]=select_dataset(imginfo_valut);
    if(strcmp(timingfile,'st_test_OE.m')) Send_condition_to_OE(TrialRecord.User, OE_config); end
    dataset_memory=TrialRecord.Editable.switch_token;
    ID = [];
    for m=1:length(img_path)
        temp_img = mglimread(img_path{m});
        temp_img = mglimresize(temp_img,[default_params.img_size,default_params.img_size]);
        ID(m) = mgladdbitmap(temp_img);  % mgladdbitmap returns an MGL object ID that is a double scalar.
    end
    mglsetproperty(ID,'active',false);  % Turn off all images.
    % set parameteres about the progress
    TrialRecord.User.played_images = 0;
    TrialRecord.User.played_times=0;
    TrialRecord.User.imageset_size = length(img_path);
    TrialRecord.User.Trial_Loader=[];
    for ww = 1:1000
        TrialRecord.User.Trial_Loader=[TrialRecord.User.Trial_Loader, randperm(TrialRecord.User.imageset_size)];
    end
%     TrialRecord.User.first_trial = 1;
%     TrialRecord.User.default_onset = default_params.onset_time;
%     TrialRecord.User.default_offset = default_params.offset_time;
else % if this is not the first trial
    if(TrialRecord.Editable.switch_token~=dataset_memory) % if we want to change dataset
        dataset_memory = TrialRecord.Editable.switch_token;
        [TrialRecord.User.current_set,TrialRecord.User.current_idx, TrialRecord.User.CategoryIdx, img_path,default_params, TrialRecord.User.category_info, TrialRecord.User.example_img,TrialRecord.User.condition_nm]=select_dataset(imginfo_valut);
        if(strcmp(timingfile,'st_test_OE.m')) Send_condition_to_OE(TrialRecord.User, OE_config); end
        dataset_memory=TrialRecord.Editable.switch_token;
        ID = [];
        for m=1:length(img_path)
            temp_img = mglimread(img_path{m});
            temp_img = mglimresize(temp_img,[default_params.img_size,default_params.img_size]);
            ID(m) = mgladdbitmap(temp_img);  % mgladdbitmap returns an MGL object ID that is a double scalar.
        end
        mglsetproperty(ID,'active',false);  % Turn off all images.
        % set parameteres about the progress
        TrialRecord.User.played_images = 0;
        TrialRecord.User.played_times=0;
        TrialRecord.User.imageset_size = length(img_path);
        TrialRecord.User.Trial_Loader=[];
        for ww = 1:1000
            TrialRecord.User.Trial_Loader=[TrialRecord.User.Trial_Loader, randperm(TrialRecord.User.imageset_size)];
        end
%         TrialRecord.User.first_trial = 1;
%         TrialRecord.User.default_onset = default_params.onset_time;
%         TrialRecord.User.default_offset = default_params.offset_time;
    else 
        % if we don't change dataset, just update the presentation progress
        % check how long last trial lasts
        % only do this when we don't switch dataset.
        if(TrialRecord.CurrentTrialNumber>0)
            last_ev_code = TrialRecord.LastTrialCodes.CodeTimes(end);
            if(strcmp(timingfile,'st_test_OE.m'))
                idx = find(TrialRecord.LastTrialCodes.CodeNumbers==11);
                first_ev_code = TrialRecord.LastTrialCodes.CodeTimes(idx);
            else
                first_ev_code = 0;
            end
            if(~isempty(first_ev_code))
                TrialRecord.User.played_images = TrialRecord.User.played_images+ (last_ev_code-first_ev_code) / (TrialRecord.Editable.onset_time+TrialRecord.Editable.offset_time);
                TrialRecord.User.played_times =  TrialRecord.User.played_images/TrialRecord.User.imageset_size;
            end
        end
%         TrialRecord.User.first_trial = 0;
    end
end


C = {'fix(0,0)'};
% Send the IDs to the timing script. You can chose only a subset or
% randomize their order for the condition of each trial.
TrialRecord.User.imageIDs = ID;
TrialRecord.User.ImageIdx = TrialRecord.User.Trial_Loader(1:TrialRecord.User.image_train);
TrialRecord.User.Trial_Loader(1:TrialRecord.User.image_train)=[];
imshow(TrialRecord.User.example_img);title(TrialRecord.User.category_info,'Interpreter','none')
if(strcmp(timingfile,'st_test_OE.m')) Send_Dataset_Name_to_OE(TrialRecord.User, zeroMQ_handle); end
end