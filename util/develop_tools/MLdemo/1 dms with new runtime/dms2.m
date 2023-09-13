hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
bhv_code(10,'Fix Cue',20,'Sample',30,'Delay',40,'Go',50,'Reward');  % behavioral codes

% detect an available tracker
if exist('eye_','var'), tracker = eye_;
elseif exist('eye2_','var'), tracker = eye2_;
elseif exist('joy_','var'), tracker = joy_; showcursor(true);
elseif exist('joy2_','var'), tracker = joy2_; showcursor2(true);
else, error('This demo requires eye or joystick input. Please set it up or turn on the simulation mode.');
end

% define time intervals (in ms):
wait_for_fix = 5000;
initial_fix = 500;
sample_time = 1000;
delay = 1000;
max_reaction_time = 2000;
hold_target_time = 500;

% fixation window (in degrees):
fix_radius = 2;
hold_radius = 2.5;

% This example does not use TaskObjects and creates stimuli with adapters.
cond = TrialRecord.User.cond;
if strcmp(MLConfig.FixationPointShape,'Square')
    fixation_point = BoxGraphic(null_);
    fix_size = MLConfig.FixationPointDeg;
else
    fixation_point = CircleGraphic(null_);
    fix_size = MLConfig.FixationPointDeg * 2;  % radius to diameter
end
fix_color = MLConfig.FixationPointColor;
fixation_point.List = { fix_color, fix_color, fix_size, [0 0] };  % { edge_color, face_color, size, position }
sample = ImageGraphic(null_);
sample.List = { cond{1}, [0 0] };  % { image_file, position }
targets = ImageGraphic(null_);
targets.List = { cond{2}, cond{3};  % The 1st image is the target.
    cond{4}, cond{5} };             % The 2nd one is the distractor.

% scene 1: fixation
fix1 = SingleTarget(tracker);
fix1.Target = fixation_point;  % fixation_point will be turned on and off by SingleTarget
fix1.Threshold = fix_radius;
wth1 = WaitThenHold(fix1);
wth1.WaitTime = wait_for_fix;
wth1.HoldTime = initial_fix;
scene1 = create_scene(wth1);

% scene 2: sample
fix2 = SingleTarget(tracker);
fix2.Target = sample;
fix2.Threshold = hold_radius;
wth2 = WaitThenHold(fix2);
wth2.WaitTime = 0;
wth2.HoldTime = sample_time;
con2 = Concurrent(wth2);
con2.add(fixation_point);
scene2 = create_scene(con2);

% scene 3: delay
fix3 = SingleTarget(tracker);
fix3.Target = fixation_point;
fix3.Threshold = hold_radius;
wth3 = WaitThenHold(fix3);
wth3.WaitTime = 0;
wth3.HoldTime = delay;
scene3 = create_scene(wth3);

% scene 4: choice
mul4 = MultiTarget(tracker);
mul4.Target = targets;
mul4.Threshold = fix_radius;
mul4.WaitTime = max_reaction_time;
mul4.HoldTime = hold_target_time;
scene4 = create_scene(mul4);


% TASK:
error_type = 0;

run_scene(scene1,10);
if ~wth1.Success
    if wth1.Waiting
        error_type = 4;
    else
        error_type = 3;
    end
end

if 0==error_type
    run_scene(scene2,20);
    if ~wth2.Success
        error_type = 3;
    end
end

if 0==error_type
    run_scene(scene3,30);
    if ~wth3.Success
        error_type = 3;
    end
end

if 0==error_type
    t_target = run_scene(scene4,40);
    if mul4.Success
        rt = mul4.RT;
        if 1~=mul4.ChosenTarget  % Image 1 is target; Image 2 is distractor.
            error_type = 6;
        end
    else
        if mul4.Waiting
            error_type = 2;
        else
            error_type = 3;
        end
    end
end

% reward
if 0==error_type
    idle(0);
    goodmonkey(100, 'juiceline',1, 'numreward',2, 'pausetime',500, 'eventmarker',50);
else
    idle(700);
end

trialerror(error_type);
