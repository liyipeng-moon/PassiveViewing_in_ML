if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
hotkey('i', "fix2.WaitForChange = 1; fix2.ChangeVal =1;dashboard(3, ['Press i+ o- Change Thres =' , num2str(fix2.Threshold)]);");
hotkey('o', "fix2.WaitForChange = 1; fix2.ChangeVal =-1;dashboard(3, ['Press i+ o- Change Thres =' , num2str(fix2.Threshold)]);");

%% variable specification
editable('wait_for_fix', 'pre_onset_time', 'fixation_time', 'fix_radius', 'hold_radius', 'reward_max_interval','reward_min_interval','reward_step')
wait_for_fix = 15000; % we wait []s at most
pre_onset_time = 700;
fixation_time = 2000;
fix_radius = 3;
hold_radius = 3;
reward_max_interval = 4500;
reward_min_interval = 2500;
reward_step = 8;
reward_duration = 100; % in miliseconds, but you need to verify this by testing your hardware
max_break_time = 300; % how long you can accept for fixation break, in miliseconds.


% movie time + leadinout + 1s
if(TrialRecord.CurrentCondition==3)
    movie_duration = 605;
elseif(TrialRecord.CurrentCondition==1)
    movie_duration = 485;
else
    movie_duration = 522;
end

total_time = movie_duration;
user_text(num2str(total_time))
%% Pre-fixation scene - scene1

fix1 = ChangeableSingleTarget(eye_);
fix1.Target = 1;
fix1.Threshold = fix_radius;
wth1 = WaitThenHold(fix1);
wth1.WaitTime = wait_for_fix;
wth1.HoldTime = pre_onset_time;
scene1 = create_scene(wth1, 1);

%% Hold-fixation scene - scene2
fix2 = ChangeableSingleTarget(eye_);
fix2.Target = 1;
fix2.Threshold = hold_radius;
rlh2 = RealTimeLooseHold(fix2);
rlh2.HoldTime = reward_max_interval;
rlh2.BreakTime = max_break_time;
rwd = RewardScheduler(rlh2);
rwd.Schedule =generate_rwd_time(reward_max_interval,reward_min_interval,reward_step,reward_duration);


tc_movie = TimeCounter(rwd);
tc_movie.Duration = total_time*1000; 
pm = PropertyMonitor(fix2);  % display the state of rwd on the screen
pm.Dashboard = 1;
pm2 = PropertyMonitor(rlh2);  % display the state of rwd on the screen
pm2.Dashboard = 2;

% stim = Stimulator(null_);
% stim.Channel = 1;  
% stim.Waveform = {[ones([100*(total_time-1),1])*5;zeros([100,1])]};  % two sets of waveforms
% stim.Frequency = 100;


cc = Concurrent(tc_movie);
cc.add(pm);
cc.add(pm2);
% cc.add(stim);

% in guojiahui dataset, 16.27*9.17d
rescale_object([2], 2);
scene2 = create_scene(cc, [1]);

% restore_light
% scene3 = create_scene(stim);


%% Running scene
error_type = 0;
% stim.WaveformNumber = 1;
% run_scene(scene3)


run_scene(scene1,10);        % Run the first scene (eventmaker 10)
if ~wth1.Success             % If the WithThenHold failed (either fixation is not acquired or broken during hold),
    if wth1.Waiting          %    check whether we were waiting for fixation.
        error_type = 4;      % If so, fixation was never made and therefore this is a "no fixation (4)" error.
    else
        error_type = 3;      % If we were not waiting, it means that fixation was acquired but not held,
    end                      %    so this is a "break fixation (3)" error.
end

if 0==error_type
    tic
    idle(0);
    %stim.WaveformNumber = 2;
    run_scene(scene2,20);    % Run the second scene (eventmarker 20)
    user_text(sprintf('stimuli lasts %f s',toc))
    
    idle(0);
%     stim.WaveformNumber = 1;
%     run_scene(scene3,30);
end