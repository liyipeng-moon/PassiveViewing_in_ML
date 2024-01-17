function [C,timingfile,userdefined_trialholder] = pv_userloop_AO(MLConfig,TrialRecord)
persistent timing_filename_returned ID

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

root_dirs = {'Z:\Monkey\Stimuli', 'D:\Img_vault'};

TrialRecord.User.image_train = 500;
online_folder = 'C:\Users\user\Desktop\BAM_Communicate';


room_number = 302;
DeviceFreeMode = 0;
% initialize
% if (0==TrialRecord.CurrentTrialNumber)
%     % Connecting to AO...
%     if(~DeviceFreeMode)
%         Connected = fN_ao_connect(room_number);
%         if(Connected==1 || Connected==10)
%             disp('Connected to AO, sending experiment setup...')
%             AO_SetSaveFileName([MLConfig.FormattedName '_' MLConfig.Investigator])
%             pause(0.1)
%             AO_StartSave;
%             pause(1)
%             AO_SendTextEvent('ML Connected');
%         else
%             warning('AO is connected to ML?, Use Device Free Mode?')
%         end
%     end
% end

%% initialize datasets
img_size = floor(TrialRecord.Editable.img_degree*MLConfig.Screen.PixelsPerDegree);
if (0==TrialRecord.CurrentTrialNumber) % the first trial
    % select data
    TrialRecord.User.switch_token=0;
    [TrialRecord.User.img_info]=select_xml(root_dirs,online_folder);
    ID = [];
    for m=1:length(TrialRecord.User.img_info.img_path)
        temp_img = mglimread(TrialRecord.User.img_info.img_path{m});
        temp_img = mglimresize(temp_img,[img_size,img_size]);
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

    if(TrialRecord.User.switch_token) % if we want to change dataset
        [TrialRecord.User.img_info]=select_xml(root_dirs,online_folder);
        ID = [];
        for m=1:length(TrialRecord.User.img_info.img_path)
            temp_img = mglimread(TrialRecord.User.img_info.img_path{m});
            temp_img = mglimresize(temp_img,[img_size,img_size]);
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
        TrialRecord.User.switch_token=0;
    else 
        % if we don't change dataset, just update the presentation progress
        % check how long last trial lasts
        % only do this when we don't switch dataset.
        if(TrialRecord.CurrentTrialNumber>0)
            tic
            codenumbers = TrialRecord.LastTrialCodes.CodeNumbers;
            onset_location = find(codenumbers>10000&codenumbers<20000);

            % resample code time and eye signal to 100Hz
            eye_dist = sqrt(TrialRecord.LastTrialAnalogData.Eye(:,1).^2+TrialRecord.LastTrialAnalogData.Eye(:,2).^2);
            eye_dist = resample(eye_dist,100,MLConfig.AISampleRate);
            eye_in = eye_dist<TrialRecord.Editable.fixation_window;
            codetimes = floor(TrialRecord.LastTrialCodes.CodeTimes/10);
            
            valid_onset_loc = ones([1,length(onset_location)]);
            img_interval = TrialRecord.Editable.onset_time/10;
            for onset_img = 1:length(onset_location)
                t1 = codetimes(onset_location(onset_img));
                if(onset_img==length(onset_location)) % last img
                    if(any(codenumbers(onset_location(onset_img):end)>20000))
                        t2 = t1+img_interval;
                    else
                        valid_onset_loc(onset_img)=0;
                        continue
                    end
                else
                    t2 = t1+img_interval;
                end
                if(any(~eye_in(t1:t2)))
                    valid_onset_loc(onset_img)=0;
                end
            end
            toc
            TrialRecord.User.onset_times = sum(valid_onset_loc);
            TrialRecord.User.played_images = TrialRecord.User.played_images+ TrialRecord.User.onset_times;
            TrialRecord.User.played_times =  TrialRecord.User.played_images/TrialRecord.User.imageset_size;
            TrialRecord.User.Trial_Loader(find(valid_onset_loc))=[];
            fprintf('last trial img %d, total %d\n', TrialRecord.User.onset_times,TrialRecord.User.played_images);
        end
    end

C = {'fix(0,0)'};
% Send the IDs to the timing script. You can chose only a subset or
% randomize their order for the condition of each trial.
TrialRecord.User.imageIDs = ID;
TrialRecord.User.ImageIdx = TrialRecord.User.Trial_Loader(1:TrialRecord.User.image_train);
imshow(TrialRecord.User.img_info.example_img);title(TrialRecord.User.img_info.category_info,'Interpreter','none')

% if(~DeviceFreeMode)
%     AO_SendTextEvent(['StartTR' num2str(TrialRecord.CurrentTrialNumber)])
%     AO_SendTextEvent(TrialRecord.User.img_info.selected_dataset)
% end

end