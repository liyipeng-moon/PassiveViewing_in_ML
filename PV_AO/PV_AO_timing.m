if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
hotkey('p', 'TrialRecord.User.switch_token=1; escape_screen();assignin(''caller'',''continue_'',false);');

editable('img_degree','fix_dot_size','onset_time', 'offset_time', 'reward_max_interval','reward_min_interval','reward_step', 'reward_duration', 'fixation_window', 'max_break_time')
onset_time=200;
offset_time=200;
reward_max_interval = 4500;
reward_min_interval = 2500;
reward_step = 8;
reward_duration = 100; % in miliseconds, but you need to verify this by testing your hardware
fixation_window = 1; % in degree, how large your fixation window is.
max_break_time = 300; % how long you can accept for fixation break, in miliseconds.
fix_dot_size = 0.5;
img_degree = 5;
ID = TrialRecord.User.imageIDs;
img_idx = TrialRecord.User.ImageIdx;
bhv_variable('DatasetName', TrialRecord.User.img_info.selected_dataset)

%% image system
img = ImageChanger(null_);
    imglist = cell(TrialRecord.User.image_train*2,4);
    for img_trial_idx = 1:TrialRecord.User.image_train
        % set picture
        idx=2*img_trial_idx-1;
        imglist(idx,1)={ID(img_idx(img_trial_idx))};
        imglist(idx,2)={[0,0]};
        imglist(idx,3)={onset_time};
        imglist(idx,4)={img_idx(img_trial_idx)+10000};
        % set blank
        idx=2*img_trial_idx;
        imglist(idx,1)={[]};
        imglist(idx,2)={[]};
        imglist(idx,3)={offset_time};
        imglist(idx,4)={img_idx(img_trial_idx)+20000};
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

oom = OnOffMarker_TTL(fix1);
oom.Port = 1;

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
%% create scene
scene = create_scene(con);
%% pre-fixation system
tc = TimeCounter(crc);
tc.Duration = 30;
pre_scene = create_scene(tc);

%% run scene

for ii = 1:3
    run_scene(pre_scene, 100+TrialRecord.CurrentTrialNumber);
end

run_scene(scene);

idle(0);
set_iti(0);
