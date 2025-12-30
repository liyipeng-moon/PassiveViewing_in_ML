function [C,timingfile,userdefined_trialholder] = pv_userloop_OE(MLConfig,TrialRecord)
persistent timing_filename_returned ID ; 
% global DeviceFreeMode;
C=[];
% cd ..\
addpath(genpath(pwd))
% cd PV_OE
timingfile = 'st_test_OE.m';
userdefined_trialholder = '';
if isempty(timing_filename_returned)
    timing_filename_returned = true;
    return
end
%% parameters which should not change if we fix it
% Local_OE_IP = '192.168.3.204';
% OE_IP = Local_OE_IP;
% DeviceFreeMode=0;
TrialRecord.User.image_train = 800;
%% Connecting to OE
root_dirs = {'D:\Img_vault','Z:\Monkey\Stimuli\LYP'};
%% initialize datasets]

img_size_v = floor(TrialRecord.Editable.img_degree_v*MLConfig.Screen.PixelsPerDegree);
img_size_h = floor(TrialRecord.Editable.img_degree_h*MLConfig.Screen.PixelsPerDegree);
if (0==TrialRecord.CurrentTrialNumber) % the first trial

    TrialRecord.User.switch_token=0;
    [TrialRecord.User.img_info]=select_xml_OE(root_dirs);

    % if(~DeviceFreeMode) Send_condition_to_OE(TrialRecord.User, OE_config);end

    ID = [];
    for m=1:length(TrialRecord.User.img_info.img_path)
        temp_img = mglimread(TrialRecord.User.img_info.img_path{m});
        temp_img = mglimresize(temp_img,[img_size_v, img_size_h]);
        ID(m) = mgladdbitmap(temp_img);  % mgladdbitmap returns an MGL object ID that is a double scalar.
        fprintf('%d %d \n', m, length(TrialRecord.User.img_info.img_path))
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

else % if this is not the first trial
    if(TrialRecord.User.switch_token) % if we want to change dataset
        TrialRecord.User.switch_token=0;
        [TrialRecord.User.img_info]=select_xml_OE(root_dirs);
       % if(~DeviceFreeMode) Send_condition_to_OE(TrialRecord.User, OE_config); end
        ID = [];
        for m=1:length(TrialRecord.User.img_info.img_path)
            temp_img = mglimread(TrialRecord.User.img_info.img_path{m});
            temp_img = mglimresize(temp_img,[img_size_v, img_size_h]);
            ID(m) = mgladdbitmap(temp_img);  % mgladdbitmap returns an MGL object ID that is a double scalar.
        end
        mglsetproperty(ID,'active',false);  % Turn off all images.
        % set parameteres about the progress
        TrialRecord.User.played_images = 0;
        TrialRecord.User.played_times=0;
        TrialRecord.User.imageset_size = length(TrialRecord.User.img_info.img_path);
        TrialRecord.User.Trial_Loader=[];
        for ww = 1:60
            TrialRecord.User.Trial_Loader=[TrialRecord.User.Trial_Loader, randperm(TrialRecord.User.imageset_size)];
        end
    else

        % if we don't change dataset, just update the presentation progress
        % check how long last trial lasts
        % only do this when we don't switch dataset.
        if(TrialRecord.CurrentTrialNumber>0)
            
            offset_loc = find(TrialRecord.LastTrialCodes.CodeNumbers==32);
            played_last_trial = length(offset_loc);
            offset_time = TrialRecord.LastTrialCodes.CodeTimes(offset_loc);
            fix_success = ones([1,played_last_trial]);
            for play_idx = 1:played_last_trial
                time_on = offset_time(play_idx)-TrialRecord.Editable.onset_time;
                time_off = offset_time(play_idx);
                
                time_on = floor(time_on/TrialRecord.LastTrialAnalogData.SampleInterval);
                time_off = floor(time_off/TrialRecord.LastTrialAnalogData.SampleInterval);
                
                eye_data = TrialRecord.LastTrialAnalogData.Eye(time_on:time_off,:);
                eye_dist = sqrt(eye_data(:,1).^2+eye_data(:,2).^2);
                if(max(eye_dist)>TrialRecord.Editable.fixation_window)
                    fix_success(play_idx)=0;
                end
            end
            if(any(fix_success))
                TrialRecord.User.played_images = TrialRecord.User.played_images+ sum(fix_success);
                TrialRecord.User.played_times =  TrialRecord.User.played_images/TrialRecord.User.imageset_size;
                TrialRecord.User.Trial_Loader(find(fix_success))=[];
            end
        end
    end
end

C = {'fix(0,0)'};
% Send the IDs to the timing script.
TrialRecord.User.ImageIdx = TrialRecord.User.Trial_Loader(1:TrialRecord.User.image_train);
TrialRecord.User.imageIDs_var = ID;


% example img.
imshow(TrialRecord.User.img_info.example_img);title(TrialRecord.User.img_info.category_info,'Interpreter','none')
% if(~DeviceFreeMode) Send_Dataset_Name_to_OE(TrialRecord.User, zeroMQ_handle); end
end