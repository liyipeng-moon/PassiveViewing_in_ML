if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

editable('onset_frames', 'offset_frames', 'reward_interval', 'reward_duration', 'fixation_window', 'max_break_time')
onset_frames = 10;
offset_frames = 10;
reward_interval = 1000; % in miliseconds.
reward_duration = 100; % in miliseconds, but you need to verify this by testing your hardware
fixation_window = 1; % in degree, how large your fixation window is.
max_break_time = 300; % how long you can accept for fixation break, in miliseconds.

img = ImageChanger(null_);
img.List=makelist(onset_frames, offset_frames);

% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;

% scene 1: fixation
crc = CircleGraphic(null_);
crc.List = { [1 0 0], [1 0 0], 0.1, [0 0] };
crc.Zorder = 2147483647; % put the fixation dot most front

fix1 = SingleTarget(eye_);
fix1.Target = fixation_point;
fix1.Threshold = fixation_window;

rlh = RealTimeLooseHold(fix1);
rlh.HoldTime = reward_interval;
rlh.BreakTime = max_break_time;

rwd = RewardScheduler(rlh);
rwd.Schedule = [0 reward_interval reward_interval reward_duration 90];
% % Once fixation starts, deliver a 100-ms reward every seconds

pm = PropertyMonitor(rwd);  % display the state of Button#1 on the screen
pm.Dashboard = 1;


con = Concurrent(img);
con.add(rwd);
con.add(crc);
con.add(pm);
scene = create_scene(con);

run_scene(scene);

%idle(0);
set_iti(offset_frames*16.7);
