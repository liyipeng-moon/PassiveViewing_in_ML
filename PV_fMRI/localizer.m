if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

hotkey('i', "fix1.WaitForChange = 1; fix1.ChangeVal =1;dashboard(3, ['Press i+ o- Change Thres =' , num2str(fix1.Threshold)]);");
hotkey('o', "fix1.WaitForChange = 1; fix1.ChangeVal =-1;dashboard(3, ['Press i+ o- Change Thres =' , num2str(fix1.Threshold)]);");

hotkey('j',"rlh.BreakTime = rlh.BreakTime + 50; dashboard(4, ['Press j+ k- Change Break Time =' , num2str(rlh.BreakTime)]);")
hotkey('k',"rlh.BreakTime = rlh.BreakTime - 50; dashboard(4, ['Press j+ k- Change Break Time =' , num2str(rlh.BreakTime)]);")

editable('reward_max_interval','reward_min_interval','reward_step', 'reward_duration', 'fixation_window', 'max_break_time')
onset_time=200;
offset_time=200;

reward_max_interval = 4500;
reward_min_interval = 2500;
reward_step = 3;
reward_duration = 100; % in miliseconds, but you need to verify this by testing your hardware
fixation_window = 1; % in degree, how large your fixation window is.
max_break_time = 300; % how long you can accept for fixation break, in miliseconds.
fix_dot_size = 0.2;
Totaltime = TrialRecord.User.Totaltime;
%% image system

img = ImageChanger(null_);
img.List=TrialRecord.User.imglist;
img.DurationUnit='mesc';

%% fixation system 
% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;

% scene 1: fixation
crc = CircleGraphic(null_);
crc.List = { [1 0 0], [1 0 0], fix_dot_size, [0 0] };
crc.Zorder = 2147483647; % put the fixation dot most front

fix1 = ChangeableSingleTarget(eye_);
fix1.Target = fixation_point;
fix1.Threshold = fixation_window;
fix1.ChangeStep = 1.05;

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

fta = ChangeFixTimeAnalyzer(fix1);

con = Concurrent(img);
con.add(rwd);
con.add(crc);
con.add(pm);
con.add(pm2);
con.add(fta)
kc = KeyChecker(mouse_);
kc.KeyNum = 1;  % 1st keycode
%% create scene

scene = create_scene(con);
keyscene = create_scene(kc);
%% run scene

dashboard(3, ['Press i+ o- Change Thres =' , num2str(fix1.Threshold)]);
dashboard(4, ['Press j+ k- Change Break Time =' , num2str(rlh.BreakTime)]);
run_scene(keyscene,9); % wait trigger
cc = clock;
bhv_variable('TriggerTime', cc);
tic
run_scene(scene,11);
idle(0);

user_text(['Finished session in ', num2str(toc), 's']);
user_text(['Monkey fix for ', num2str((fta.FixTime)./60), 's']);
user_text(['Next Session Index: ' num2str(TrialRecord.CurrentTrialNumber+1)])
%user_warning('warn_Finished one session');

escape_screen()