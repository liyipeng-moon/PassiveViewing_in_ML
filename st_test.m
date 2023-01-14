if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

editable('onset_time', 'offset_time', 'reward_max_interval','reward_min_interval','reward_step', 'reward_duration', 'fixation_window', 'max_break_time','switch_token','electrode_token')
onset_time=200;
offset_time=200;
if(TrialRecord.User.first_trial)
    onset_time = TrialRecord.User.default_onset;
    offset_time = TrialRecord.User.default_offset;
end

reward_max_interval = 4500;
reward_min_interval = 2500;
reward_step = 8;
reward_duration = 100; % in miliseconds, but you need to verify this by testing your hardware

fixation_window = 1; % in degree, how large your fixation window is.
max_break_time = 300; % how long you can accept for fixation break, in miliseconds.
switch_token = 1;
electrode_token  = 1;
fix_dot_size = 0.2;
ID = TrialRecord.User.imageIDs;
bhv_variable('Current_ID', TrialRecord.User.ImageIdx, 'DatasetName', TrialRecord.User.current_set)

%% image system

img = ImageChanger(null_);

    imglist = cell(TrialRecord.User.image_train*2,4);
    for img_trial_idx = 1:TrialRecord.User.image_train
        % set picture
        idx=2*img_trial_idx-1;
        imglist(idx,1)={ID(img_trial_idx)};
        imglist(idx,2)={[0,0]};
        imglist(idx,3)={onset_time};
        imglist(idx,4)={img_trial_idx+10000};
        % set blank
        idx=2*img_trial_idx;
        imglist(idx,1)={[]};
        imglist(idx,2)={[]};
        imglist(idx,3)={offset_time};
        imglist(idx,4)={img_trial_idx+20000};
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


pm = PropertyMonitor(rwd);  % display the state of rwd on the screen
pm.Dashboard = 1;

con = Concurrent(img);
con.add(rwd);
con.add(crc);
con.add(pm);

%% Timing System
dashboard(2, sprintf(['dataset - ' TrialRecord.User.current_set(1:end-4), '(n=' ,num2str(TrialRecord.User.imageset_size), ')']))
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
tc.Duration = 17;

%% create scene
scene = create_scene(con);
pre_scene = create_scene(tc);

%% run scene
run_scene(pre_scene, 100+switch_token*10+electrode_token);
run_scene(pre_scene, 200+switch_token*10+electrode_token);
run_scene(pre_scene, 300+switch_token*10+electrode_token);
run_scene(scene);
idle(0);
set_iti(0);
