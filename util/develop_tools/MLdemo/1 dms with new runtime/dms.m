hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
bhv_code(10,'Fix Cue',20,'Sample',30,'Delay',40,'Go',50,'Reward');  % behavioral codes

% detect an available tracker
if exist('eye_','var'), tracker = eye_;
elseif exist('eye2_','var'), tracker = eye2_;
elseif exist('joy_','var'), tracker = joy_; showcursor(true);
elseif exist('joy2_','var'), tracker = joy2_; showcursor2(true);
else, error('This demo requires eye or joystick input. Please set it up or turn on the simulation mode.');
end

% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;
sample = 2;
target = 3;
distractor = 4;

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

% We used toggleobject() to present stimuli and eyejoytrack() to track
% behavior in the original MonkeyLogic.  This method is not very
% advantageous in creating dynamic, behavior-responsive stimuli, because
% stimuli and behavior are processed separately and there is no proper way
% to change stimuli during behavior tracking.  While we can still use the
% old method, NIMH ML provides another way to compose tasks which uses
% "adapters" as building blocks of task scenes and two new functions,
% create_scene() and run_scene(), as replacements of toggleobject() and
% eyejoytrack().
 
% The adapter is a MATLAB class objects and has two member functions,
% analyze() and draw(), that are called by run_scene() every frame.  Each
% time when they are called, analyze() examines samples acquired during the
% previous frame and draw() re-paints the screen for the next frame.
% Through this cycle, the adapter can analyze the subject's
% behavior and determine what to present next.
% Multiple adapters can be concatenated to create complex stimuli and
% detect complex behavioral patterns.

% You can make your own adapters, but there are already dozens of built-in
% adapters that allows you to do everything you could do with
% toggleobject() and eyejoytrack() and more.  By recycling the built-in
% adapters, you can be less concerned about how they internally works
% and more focused on how to build a task.  Typically the adapters have
% initial parameters that you need to set before rendering the scenes.
% Then they perform the behavior analysis or stimulus presentation during
% the scenes.  When the scenes are finished, you can read out the analysis
% results from the properties of the adapters.

% All adapters accept another adapter as an argument at initialization.
% There are 8 pre-defined adapters that you can begin an adapter chain
% with: eye_, eye2_, joy_, joy2_, mouse_, touch_, button_ and null_.
% Their names indicate the input signal that they process.

% scene 1: fixation
fix1 = SingleTarget(tracker);  % We use eye signals (eye_) for tracking. The SingleTarget adapter
fix1.Target = fixation_point;  % checks if the gaze is in the Threshold window around the Target.
fix1.Threshold = fix_radius;   % The Target can be either TaskObject# or [x y] (in degrees).

wth1 = WaitThenHold(fix1);     % The WaitThenHold adapter waits for WaitTime until the fixation
wth1.WaitTime = wait_for_fix;  % is made and then checks whether the fixation is held for HoldTime.
wth1.HoldTime = initial_fix;   % Since WaitThenHold gets the fixation status from SingleTarget,
                               % SingleTarget (fix1) must be the input argument of WaitThenHold (wth1).

scene1 = create_scene(wth1,fixation_point);  % TaskObjects ("fixation_point") should be inserted by create_scene()
                                             % in the scene framework.

% scene 2: sample
fix2 = SingleTarget(tracker);
fix2.Target = sample;
fix2.Threshold = hold_radius;
wth2 = WaitThenHold(fix2);
wth2.WaitTime = 0;             % We already knows the fixation is made, so we don't wait.
wth2.HoldTime = sample_time;
scene2 = create_scene(wth2,[fixation_point sample]);

% scene 3: delay
fix3 = SingleTarget(tracker);
fix3.Target = fixation_point;
fix3.Threshold = hold_radius;
wth3 = WaitThenHold(fix3);
wth3.WaitTime = 0;
wth3.HoldTime = delay;
scene3 = create_scene(wth3,fixation_point);

% scene 4: choice
mul4 = MultiTarget(tracker);        % The MultiTarget adapter checks fixation acquisition for multiple targets.
mul4.Target = [target distractor];  % Target can be coordinates, like [x1 y1; x2 y2; x3 y3; ...], instead of TaskObject #.
mul4.Threshold = fix_radius;
mul4.WaitTime = max_reaction_time;
mul4.HoldTime = hold_target_time;
mul4.TurnOffUnchosen = true;        % Determine whether to turn off the unchosen targets when one of the targets is chosen.
scene4 = create_scene(mul4,[target distractor]);


% TASK:
error_type = 0;

run_scene(scene1,10);        % Run the first scene (eventmaker 10)
if ~wth1.Success             % If the WithThenHold failed (either fixation is not acquired or broken during hold),
    if wth1.Waiting          % check whether we were waiting for fixation.
        error_type = 4;      % If so, fixation was never made and therefore this is a "no fixation (4)" error.
    else
        error_type = 3;      % If we were not waiting, it means that fixation was acquired but not maintained,
    end                      % so this is a "break fixation (3)" error.
end

if 0==error_type
    run_scene(scene2,20);    % Run the second scene (eventmarker 20)
    if ~wth2.Success         % The failure of WithThenHold indicates that the subject didn't maintain fixation on the sample image.
        error_type = 3;      % So it is a "break fixation (3)" error.
    end
end

if 0==error_type
    run_scene(scene3,30);    % Run the third (delay) scene (eventmarker 30)
    if ~wth3.Success
        error_type = 3;      % break fixation (3)
    end
end

if 0==error_type
    t_target = run_scene(scene4,40);    % Run the fourth scene (eventmarker 40)
    if mul4.Success
        rt = mul4.RT;        % Assign rt for the reaction time graph. This is the same as rt = mul4.AcquiredTime - t_target;
        if target~=mul4.ChosenTarget
            error_type = 6;  % One of the images was selected, but it was an incorrect choice.
        end
    else                     % The failure of MultiTarget means that none of the targets was chosen.
        if mul4.Waiting      % If we were waiting for the target selection (in other words, the gaze did not
            error_type = 2;  % land on either the target or distractor), it is a "late response (2)" error.
        else
            error_type = 3;  % Otherwise, the fixation is broken (3) and the choice was not held to the end.
        end
    end
end

% reward
if 0==error_type
    idle(0);                 % Clear screens
    goodmonkey(100, 'juiceline',1, 'numreward',2, 'pausetime',500, 'eventmarker',50); % 100 ms of juice x 2
else
    idle(700);               % Clear screens
end

trialerror(error_type);      % Add the result to the trial history
