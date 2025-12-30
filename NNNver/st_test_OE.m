if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'idle(400);escape_screen(); idle(100);idle(100);assignin(''caller'',''continue_'',false);');
hotkey('p', 'TrialRecord.User.switch_token=1; escape_screen();idle(100);idle(100);assignin(''caller'',''continue_'',false);');

% global DeviceFreeMode;
editable('onset_time', 'offset_time', 'reward_max_interval','reward_min_interval','reward_step', 'reward_duration','img_degree_v','img_degree_h', 'fixation_window', 'max_break_time','switch_token')

onset_time=200;
offset_time=200;
reward_max_interval = 4500;
reward_min_interval = 2500;
reward_step = 8;
reward_duration = 100; % in miliseconds, but you need to verify this by testing your hardware
% 40ms duration for reward machine from LXY is necessary for a drop of water
fixation_window = 1; % in degree, how large your fixation window is.
max_break_time = 300; % how long you can accept for fixation break, in miliseconds.
max_waiting_time = 20000; % how long we got into the next trial
hold_time_to_start = 300; % how long the monkey fix to start image presentation
switch_token = 1;
fix_dot_size = 0.3;

ID = TrialRecord.User.imageIDs_var;
Current_Image_Train = TrialRecord.User.ImageIdx;
Image_number = TrialRecord.User.image_train;
Category_idx = TrialRecord.User.img_info.category_idx;
Category_name = TrialRecord.User.img_info.condition_nm;
time_of_holding = (onset_time+offset_time)*length(Current_Image_Train)+200;
img_degree_v = 8;
img_degree_h = 8;
bhv_variable('Current_Image_Train', TrialRecord.User.ImageIdx, 'DatasetName', TrialRecord.User.img_info.selected_dataset)
%% this script is mainly for open ephys categorical test.
% image system
img = ImageChanger(null_);
imglist = cell(Image_number*2,4);
for img_trial_idx = 1:Image_number
    % set picture
    idx=2*img_trial_idx-1;
    imglist(idx,1)={ID(Current_Image_Train(img_trial_idx))};
    imglist(idx,2)={[0,0]};
    imglist(idx,3)={onset_time};
    imglist(idx,4)={64};

    % set blank
    idx=2*img_trial_idx;
    imglist(idx,1)={[]};
    imglist(idx,2)={[]};
    imglist(idx,3)={offset_time};
    imglist(idx,4)={32};

end
img.List=imglist;
img.DurationUnit='mesc';
%% fixation system
% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;
% adapter 0: fixation dot
crc = CircleGraphic(null_);
crc.List = { [1 0 0], [1 0 0], fix_dot_size, [0 0] };
crc.Zorder = 2147483647; % put the fixation dot most front
% scene 1: pre_fixation
%% pre-fixation system
fix0 = SingleTarget(eye_);
fix0.Target = fixation_point;
fix0.Threshold = fixation_window;
wth0 = WaitThenHold(fix0);
wth0.WaitTime = max_waiting_time;
wth0.HoldTime = hold_time_to_start;
con0 = Concurrent(wth0);
con0.add(crc);
% scene 2: fixation
fix1 = SingleTarget(eye_);
fix1.Target = fixation_point;
fix1.Threshold = fixation_window;
lh = LooseHold(fix1);
lh.HoldTime = time_of_holding;
lh.BreakTime = max_break_time;
rwd = RewardScheduler(null_);
rwd.Schedule =generate_rwd_time(reward_max_interval,reward_min_interval,reward_step,reward_duration);
pm = PropertyMonitor(fix1);  % display the state of rwd on the screen
pm.Dashboard = 1;
pd = PhotoDiode(img);
pd.Mode = 'Event';       % toggle the trigger when an eventcode is sent out ('Event' mode)
con1 = Concurrent(lh);
con1.add(rwd);
con1.add(pd);
con1.add(crc);
con1.add(pm);
%% Timing System
dashboard(2, sprintf(['has been played for ' num2str(TrialRecord.User.played_images), ' imgs before,']))
dashboard(3, sprintf('%s, n=%d' ,TrialRecord.User.img_info.selected_dataset,TrialRecord.User.imageset_size))
dashboard(4, sprintf(['onset = ' num2str(imglist{1,3}), ', offset = ' num2str(imglist{2,3})]))
%% create scene
scene = create_scene(con1);
pre_scene = create_scene(con0);
%% run scene
ttl = TTLOutput(null_);
ttl.Port = 1;         % TTL #1 must be assigned in the I/O menu.
tc2 = TimeCounter(ttl);
tc2.Duration = 50;   % TTL duration is determined by TimeCounter.
TTL_scene = create_scene(tc2);
run_scene(TTL_scene,0);  % on
mouse_.showcursor(false);     
run_scene(pre_scene, 0)
error_type=0;
if(wth0.Success)
    run_scene(scene)
elseif(wth0.Waiting)
    error_type=4;
else
    error_type=3;
end
if(~lh.Success)
    error_type=3;
end
trialerror(error_type)
idle(600);