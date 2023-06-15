function [C,timingfile,userdefined_trialholder] = pv_userloop(MLConfig,TrialRecord)
persistent timing_filename_returned ID dataset_memory; 

C=[];
cd ..\
addpath(genpath(pwd))
cd PV_AO
timingfile = 'PV_AO_timing.m';
userdefined_trialholder = '';
if isempty(timing_filename_returned)
    timing_filename_returned = true;
    return
end

%% parameters which should not change if we fix it

imginfo_valut='D:\Img_vault';
TrialRecord.User.image_train = 200;
room_number = 305;
online_ip = '10.129.168.158';
url = ['http://', online_ip,':8000/receive'];


DeviceFreeMode = 1;
OnlineMode = 1;
%% initialize
if (0==TrialRecord.CurrentTrialNumber)
    % Connecting to AO...
    if(~DeviceFreeMode)
        Connected = fN_ao_connect(room_number);
        if(Connected==1 || Connected==10)
            disp('Connected to AO, sending experiment setup...')
            AO_SetSaveFileName([MLConfig.FormattedName '_' MLConfig.Investigator])
            AO_StartSave;
            pause(0.5)
            AO_SendTextEvent(['ML Connected']);
        else
            warning('AO is connected to ML, Use Device Free Mode?')
        end
    end
    % Connecting to Online
    if(OnlineMode)
        if(exist('ML_TCP','var') && isa(ML_TCP,'tcpclient'));delete(ML_TCP);end
        ML_TCP = tcpclient(online_ip, 1234);
    end
end

switch_token=0;

%% initialize datasets
if (0==TrialRecord.CurrentTrialNumber) % the first trial
    % select data
    [TrialRecord.User.img_info]=select_dataset(imginfo_valut,0);
    
    dataset_memory=TrialRecord.Editable.switch_token;
    ID = [];
    for m=1:length(TrialRecord.User.img_info.img_path)
        temp_img = mglimread(TrialRecord.User.img_info.img_path{m});
        temp_img = mglimresize(temp_img,[TrialRecord.User.img_info.default_params.img_size,TrialRecord.User.img_info.default_params.img_size]);
        ID(m) = mgladdbitmap(temp_img);  % mgladdbitmap returns an MGL object ID that is a double scalar.
    end
    mglsetproperty(ID,'active',false);  % Turn off all images.
    % set parameteres about the progress
    TrialRecord.User.played_images = 0;
    TrialRecord.User.played_times=0;
    TrialRecord.User.imageset_size = length(TrialRecord.User.img_info.img_path);
    TrialRecord.User.Trial_Loader=[];
    for ww = 1:1000
        TrialRecord.User.Trial_Loader=[TrialRecord.User.Trial_Loader, randperm(TrialRecord.User.imageset_size)];
    end
end

    if(TrialRecord.Editable.switch_token~=dataset_memory) % if we want to change dataset
        dataset_memory = TrialRecord.Editable.switch_token;
        [TrialRecord.User.img_info]=select_dataset(imginfo_valut,Localizer_set);
        dataset_memory=TrialRecord.Editable.switch_token;
        ID = [];
        for m=1:length(TrialRecord.User.img_info.img_path)
            temp_img = mglimread(TrialRecord.User.img_info.img_path{m});
            temp_img = mglimresize(temp_img,[TrialRecord.User.img_info.default_params.img_size,TrialRecord.User.img_info.default_params.img_size]);
            ID(m) = mgladdbitmap(temp_img);  % mgladdbitmap returns an MGL object ID that is a double scalar.
        end
        mglsetproperty(ID,'active',false);  % Turn off all images.
        % set parameteres about the progress
        TrialRecord.User.played_images = 0;
        TrialRecord.User.played_times=0;
        TrialRecord.User.imageset_size = length(TrialRecord.User.img_info.img_path);
        TrialRecord.User.Trial_Loader=[];
        for ww = 1:1000
            TrialRecord.User.Trial_Loader=[TrialRecord.User.Trial_Loader, randperm(TrialRecord.User.imageset_size)];
        end

    else 
        % if we don't change dataset, just update the presentation progress
        % check how long last trial lasts
        % only do this when we don't switch dataset.
        if(TrialRecord.CurrentTrialNumber>0)
            last_ev_code = TrialRecord.LastTrialCodes.CodeTimes(end);
            first_ev_code = 0;
            if(~isempty(first_ev_code))
                TrialRecord.User.played_images = TrialRecord.User.played_images+ (last_ev_code-first_ev_code) / (TrialRecord.Editable.onset_time+TrialRecord.Editable.offset_time);
                TrialRecord.User.played_times =  TrialRecord.User.played_images/TrialRecord.User.imageset_size;
            end
        end
    end

C = {'fix(0,0)'};
% Send the IDs to the timing script. You can chose only a subset or
% randomize their order for the condition of each trial.
TrialRecord.User.imageIDs = ID;
TrialRecord.User.ImageIdx = TrialRecord.User.Trial_Loader(1:TrialRecord.User.image_train);
TrialRecord.User.Trial_Loader(1:TrialRecord.User.image_train)=[];
imshow(TrialRecord.User.img_info.example_img);title(TrialRecord.User.img_info.category_info,'Interpreter','none')

if(~DeviceFreeMode)
    AO_SendTextEvent(['StartTR' num2str(TrialRecord.CurrentTrialNumber)])
    AO_SendTextEvent(TrialRecord.User.img_info.selected_dataset)
end

if(OnlineMode)
    try
        write(ML_TCP,uint8(savejson('',TrialRecord.User.img_info)))
    catch
        ML_TCP = tcpclient(online_ip, 1234);
        write(ML_TCP,uint8(savejson('',TrialRecord.User.img_info))); 
    end
end

end