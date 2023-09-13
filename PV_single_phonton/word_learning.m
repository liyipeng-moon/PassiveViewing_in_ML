function [C,timingfile,userdefined_trialholder] = pv_userloop(MLConfig,TrialRecord)
persistent timing_filename_returned ID; 

C=[];
timingfile = 'word_water.m';
userdefined_trialholder = '';
if isempty(timing_filename_returned)
    timing_filename_returned = true;
    return
end

%% initialize datasets
if (0==TrialRecord.CurrentTrialNumber) % the first trial, initialize and draw
    % select data
    [TrialRecord.User.img_info]=load('word_info.mat').all_img;
    ID = [];
    for m=1:length(TrialRecord.User.img_info)
        temp_img = mglimread(TrialRecord.User.img_info(m).path);
        
        for cc = 1:3
            temp_img(1:5,:,cc)=255;
            temp_img(end-5:end,:,cc)=255;
            temp_img(:,1:5,cc)=255;
            temp_img(:,end-5:end,cc)=255;
        end
        %temp_img = mglimresize(temp_img,[330,330]);
        ID(m) = mgladdbitmap(temp_img);  % mgladdbitmap returns an MGL object ID that is a double scalar.
    end
    mglsetproperty(ID,'active',false);  

    TrialRecord.User.played_images = 0;

    TrialRecord.User.Trial_Loader=load(uigetfile).orders;
    TrialRecord.User.Trial_Idx =1;

else
    if(TrialRecord.TrialErrors(end)==0)
        %  success
        TrialRecord.User.Trial_Idx = TrialRecord.User.Trial_Idx+1;
    end
end
next_trial_img = TrialRecord.User.Trial_Loader(TrialRecord.User.Trial_Idx);
TrialRecord.User.wordID=next_trial_img;
TrialRecord.User.word_info = TrialRecord.User.img_info(next_trial_img);

C = {'fix(0,0)'};
TrialRecord.User.imageIDs = ID;
end