function [C,timingfile,userdefined_trialholder] = pv_userloop(MLConfig,TrialRecord)
C=[];
timingfile = 'st_test.m';
userdefined_trialholder = '';
persistent timing_filename_returned
if isempty(timing_filename_returned)
    timing_filename_returned = true;
    return
end

%% parameters which should not change if we fix it
image_valut='E:\pickstimuli(xuanwu)\pickstimuli\stimuli_withmask_resized';
interested_imageset='smalldata';

TrialRecord.User.image_train = 1000;

persistent ID
if 0==TrialRecord.CurrentTrialNumber  % to load image only once
    all_img = dir([image_valut '/' interested_imageset '/*.tif*']);
    all_img([1,2])=[];
    image_list=cell(1,length(all_img));
    for ii = 1:length(all_img)
        image_list{ii} = [image_valut '\' interested_imageset '\' all_img(ii).name];
    end
    ID = [];
    for m=1:length(image_list)

        temp_img = mglimread(image_list{m});
        temp_img = mglimresize(temp_img,[224,224]);
        ID(m) = mgladdbitmap(temp_img);  % mgladdbitmap returns an MGL object ID that is a double scalar.
    end
    mglsetproperty(ID,'active',false);  % Turn off all images.

    % set parameteres about the progress
    TrialRecord.User.played_images = 0;
    TrialRecord.User.imageset_size = length(image_list);
    TrialRecord.User.current_set = interested_imageset;
    TrialRecord.User.cycle_per_trial=TrialRecord.User.image_train/TrialRecord.User.imageset_size;
    
    TrialRecord.User.Trial_Loader=[];
    for ww = 1:1000
        TrialRecord.User.Trial_Loader=[TrialRecord.User.Trial_Loader, randperm(TrialRecord.User.imageset_size)];
    end
end


C = {'fix(0,0)'};
% Send the IDs to the timing script. You can chose only a subset or
% randomize their order for the condition of each trial.
TrialRecord.User.imageIDs = ID(TrialRecord.User.Trial_Loader(1:TrialRecord.User.image_train));
TrialRecord.User.ImageIdx = TrialRecord.User.Trial_Loader(1:TrialRecord.User.image_train);
TrialRecord.User.Trial_Loader(1:TrialRecord.User.image_train)=[];

end