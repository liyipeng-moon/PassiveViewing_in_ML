if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

%% variable specification
editable('reward_time','onset_time','wait_for_fix', 'pre_onset_time', 'fix_radius')
onset_time=500;
wait_for_fix = 20000; % we wait []s at most
pre_onset_time = 700;
fix_radius = 2;
hold_radius = fix_radius;
fix_dot_size=0.5;
total_ITI = 1000;
reward_time = 100;
ID = TrialRecord.User.imageIDs;
idx = TrialRecord.User.wordID;
water_size = TrialRecord.User.word_info.drop;
progress_data = TrialRecord.User.Trial_Idx;

%%
crc = CircleGraphic(null_);
crc.List = { [0 0 0], [0 0 0], fix_dot_size, [0 0] };
crc.Zorder = 0; % put the fixation dot most front
%% Pre-fixation scene - scene1
fix1 = SingleTarget(eye_);
fix1.Target = [0,0];
fix1.Threshold = fix_radius;
wth1 = WaitThenHold(fix1);
wth1.WaitTime = wait_for_fix;
wth1.HoldTime = pre_onset_time;
pm0=PropertyMonitor(fix1);
com_pre = Concurrent(wth1);
com_pre.add(crc)

%% image system
total_time = 100+100+700+100+100;
img = ImageChanger(null_);
img.List = {
    ID(idx), [0,0], onset_time, ID(idx);  [], [],50+total_time-onset_time, []; 
}; 
img.DurationUnit = 'msec';

%% fixation system 

fix2 = SingleTarget(eye_);
fix2.Target = 1;
fix2.Threshold = fix_radius;
wth2 = WaitThenHold(fix2);
wth2.WaitTime = 100;
wth2.HoldTime = total_time;

pm=PropertyMonitor(fix1);

stim = Stimulator(null_);
stim.Channel = 1;  
stim.Waveform = {5*[zeros([10,1]);ones([10,1]);zeros(70,1);ones(10,1);zeros(10,1)]};  % two sets of waveforms
stim.Frequency = 100;

con = Concurrent(wth2);
con.add(pm)
con.add(crc)
con.add(stim)
con.add(img)

%% post scene
tc_end = TimeCounter(crc);
tc_end.Duration = 5;
c2 = Concurrent(tc_end);
c2.add(stim);
end_scene = create_scene(c2);
%% create scene
scene = create_scene(con);
pre_scene = create_scene(com_pre);

%% Running scene
error_type = 0;
run_scene(pre_scene,10);        % Run the first scene (eventmaker 10)
if ~wth1.Success             % If the WithThenHold failed (either fixation is not acquired or broken during hold),
    if wth1.Waiting          %    check whether we were waiting for fixation.
        error_type = 4;      % If so, fixation was never made and therefore this is a "no fixation (4)" error.
    else
        error_type = 3;      % If we were not waiting, it means that fixation was acquired but not held,
    end                      %    so this is a "break fixation (3)" error.
end

if 0==error_type
    run_scene(scene,20);    % Run the second scene (eventmarker 20)
    if(wth2.Success)
        goodmonkey(reward_time, 'juiceline', 1, 'numreward', water_size, 'pausetime', reward_time, 'eventmarker', 90,'NonBlocking',1);
        user_text(sprintf('succeed for %d trials', progress_data));
    else
        error_type=5;
    end
end
run_scene(end_scene)
trialerror(error_type)
switch water_size
    case 1
        ITI = total_ITI-100;
    case 2
        ITI = total_ITI-300;
    case 3
        ITI = total_ITI-500;
end
set_iti(200);
