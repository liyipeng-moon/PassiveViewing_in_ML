if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

editable('onset_time', 'offset_time', 'reward_max_interval','reward_min_interval','reward_step', 'reward_duration', 'fixation_window', 'max_break_time','switch_token','electrode_token')
onset_time=200;
offset_time=200;


reward_max_interval = 4500;
reward_min_interval = 2500;
reward_step = 8;
reward_duration = 100; % in miliseconds, but you need to verify this by testing your hardware
FIX_CODE=1001;
BREAK_CODE=1002;
fixation_window = 1; % in degree, how large your fixation window is.
max_break_time = 300; % how long you can accept for fixation break, in miliseconds.
switch_token = 1;
electrode_token  = 1;
fix_dot_size = 0.2;
ID = TrialRecord.User.imageIDs;
bhv_variable('DatasetName', TrialRecord.User.img_info.selected_dataset)

%% image system

img = ImageChanger(null_);

    imglist = cell(TrialRecord.User.image_train*2,4);
    for img_trial_idx = 1:TrialRecord.User.image_train
        % set picture
        idx=2*img_trial_idx-1;
        imglist(idx,1)={ID(TrialRecord.User.Trial_Loader(img_trial_idx))};
        imglist(idx,2)={[0,0]};
        imglist(idx,3)={onset_time};
        imglist(idx,4)={TrialRecord.User.Trial_Loader(img_trial_idx)+10000};
        % set blank
        idx=2*img_trial_idx;
        imglist(idx,1)={[]};
        imglist(idx,2)={[]};
        imglist(idx,3)={offset_time};
        imglist(idx,4)={TrialRecord.User.Trial_Loader(img_trial_idx)+20000};
    end
    img.List=imglist;
    img.DurationUnit='mesc';


%% fixation system 
% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;

% scene 1: fixation
crc = CircleGraphic(null_);
crc.List = { [1 0 0], [1 0 0], fix_dot_size, [0 0] };
crc.Zorder = 2147483647; % put the fixation dot most front

fix1 = SingleTarget(eye_);
fix1.Target = fixation_point;
fix1.Threshold = fixation_window;

rlh = RealTimeLooseHold(fix1);
rlh.HoldTime = reward_max_interval;
rlh.BreakTime = max_break_time;

rwd = RewardScheduler(rlh);
rwd.Schedule =generate_rwd_time(reward_max_interval,reward_min_interval,reward_step,reward_duration);
rwd.Schedule;
pm = PropertyMonitor(fix1);  % display the state of rwd on the screen
pm.Dashboard = 1;
pm2 = PropertyMonitor(rlh);  % display the state of rwd on the screen
pm2.Dashboard = 2;

bhv_code(FIX_CODE, 'Fix', BREAK_CODE, 'Break');
oom = OnOffMarker(fix1);
oom.OnMarker = FIX_CODE;
oom.OffMarker = BREAK_CODE;

con = Concurrent(img);
con.add(rwd);
con.add(crc);
con.add(pm);
con.add(pm2);
con.add(oom)

%% Timing System
dashboard(6, sprintf(['dataset - ' TrialRecord.User.img_info.selected_dataset(1:end-4), '(n=' ,num2str(TrialRecord.User.imageset_size), ')']))
dashboard(3, sprintf(['has been played for ' num2str(TrialRecord.User.played_times,3), ' cycles before,']))
dashboard(5, sprintf(['onset = ' num2str(imglist{1,3}), ', offset = ' num2str(imglist{2,3})]))
counter_num = floor((10*TrialRecord.User.image_train)/(TrialRecord.User.imageset_size));
time_cycle = TrialRecord.User.imageset_size * (onset_time+offset_time) /10;
for ii = 1:counter_num
    tc(ii) = TimeCounter(null_);
    tc(ii).Duration = ii*time_cycle;
    ood(ii) = OnOffDisplay(tc(ii));
    ood(ii).Dashboard = 4;
    ood(ii).OnMessage = ['new ', num2str(floor(ii/10)), '.' ,num2str(mod(ii,10)) ,' cycle displayed'];
    ood(ii).OffMessage = 'new cycle waiting';
    con.add(ood(ii))
end

%% pre-fixation system
crc = CircleGraphic(null_);
crc.List = { [1 0 0], [1 0 0], fix_dot_size, [0 0] };
crc.Zorder = 2147483647; % put the fixation dot most front
tc = TimeCounter(crc);
tc.Duration = 30;


%% create scene
scene = create_scene(con);
pre_scene = create_scene(tc);
%% run scene

for ii = 1:3
    run_scene(pre_scene, 100+TrialRecord.User.img_info.dataset_idx);
end
if(~fix1.Success)
    %BFB
    run_scene(pre_scene,BREAK_CODE);run_scene(pre_scene,FIX_CODE);run_scene(pre_scene,BREAK_CODE);
    eye_code = 1;
else
    %FBF
    eye_code = 2;
    run_scene(pre_scene,FIX_CODE);run_scene(pre_scene,BREAK_CODE);run_scene(pre_scene,FIX_CODE);
end

run_scene(scene);

for ii = 1:3
    if(~fix1.Success)
        %BFB
        run_scene(pre_scene,FIX_CODE);
    else
        %FBF
        run_scene(pre_scene,BREAK_CODE);
    end
end


idle(0);
set_iti(0);