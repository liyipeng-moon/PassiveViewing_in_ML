% Exit early when the x key is pressed
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

hotkey('r', 'goodmonkey(100, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');
hotkey('t', 'goodmonkey(200, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');
hotkey('y', 'goodmonkey(300, ''juiceline'', MLConfig.RewardFuncArgsrrrrrrr.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');

hotkey('i', "fix1.WaitForChange = 1; fix1.ChangeVal =1;dashboard(3, ['Press i+ o- Change Thres =' , num2str(fix1.Threshold)]);");
hotkey('o', "fix1.WaitForChange = 1; fix1.ChangeVal =-1;dashboard(3, ['Press i+ o- Change Thres =' , num2str(fix1.Threshold)]);");
hotkey('j',"rlh.BreakTime = rlh.BreakTime + 50; dashboard(4, ['Press j+ k- Change Break Time =' , num2str(rlh.BreakTime)]);")
hotkey('k',"rlh.BreakTime = rlh.BreakTime - 50; dashboard(4, ['Press j+ k- Change Break Time =' , num2str(rlh.BreakTime)]);")

hotkey('b',"run_scene(scene_movie)")
%hotkey('n',"run_scene(scene_movie{2})")
%hotkey('m',"run_scene(scene_movie{3})")
addpath(genpath('E:\BLAB_LYP\PassiveViewing_in_ML-main'))
reward_max_interval = 2000;
reward_min_interval = 2000;
reward_step = 3;
reward_duration = 100; % in miliseconds, but you need to verify this by testing your hardware
fixation_window = 8; % in degree, how large your fixation window is.
max_break_time = 800; % how long you can accept for fixation break, in miliseconds.
fix_dot_size = 1;

editable('reward_max_interval','reward_min_interval','reward_step', 'reward_duration', 'fixation_window', 'max_break_time')

%% fixation system 
% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;

% scene 1: fixation
crc = CircleGraphic(null_);
crc.List = { [1 0 0], [1 0 0], fix_dot_size, [0 0] };
crc.Zorder = 2147483647; % put the fixation dot most front

% fix1 = ChangeableSingleTarget(eye_);
% fix1.Target = fixation_point;
% fix1.Threshold = fixation_window;
% fix1.ChangeStep = 1.05;
% 
% rlh = RealTimeLooseHold(fix1);
% rlh.HoldTime = reward_max_interval;
% rlh.BreakTime = max_break_time;

rwd = RewardScheduler(null_);
rwd.Schedule =generate_rwd_time(reward_max_interval,reward_min_interval,reward_step,reward_duration);
rwd.Schedule;
% pm = PropertyMonitor(fix1);  % display the state of rwd on the screen
% pm.Dashboard = 1;
% pm2 = PropertyMonitor(rlh);  % display the state of rwd on the screen
% pm2.Dashboard = 2;

% fta = ChangeFixTimeAnalyzer(fix1);
rescale_object(2, 2);

% con.add(crc);
% con.add(pm);
% con.add(pm2);
% con.add(fta)

% capture attention
rr_series = [1:1:20].^2;
movie_gif = [];
bg = 2000;
for ff = 1:length(rr_series)
    img = zeros([bg,bg]);
    for xx = 1:bg
        for yy = 1:bg
            if((xx-bg/2)^2+(yy-bg/2)^2<rr_series(ff)^2)
                img(xx,yy)=1;
            end
        end
    end
    for cc = 1:3
        movie_gif(:,:,cc,ff)=img;
    end
end
mov1 = MovieGraphic(null_);
mov1.List = { movie_gif, [0 0],1};  % movie filename
mov1.Zorder=0;
tc = TimeCounter(mov1);
tc.Duration = 1000*180;
scene_movie = create_scene(tc);

%% run scene
% 
% dashboard(3, ['Press i+ o- Change Thres =' , num2str(fix1.Threshold)]);
% dashboard(4, ['Press j+ k- Change Break Time =' , num2str(rlh.BreakTime)]);
idle(0);  % clear the screen
con = Concurrent(tc);
con.add(rwd)
scene = create_scene(con,[1, 2]);
run_scene(scene,11);
idle(0);

%%escape_screen()