if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;

% This determines whether WaitThenHold allows fixation to be made before the scene start.
allow_early_fix = false;
editable('allow_early_fix');

% scene 1: wait for fixation and hold
fix1 = SingleTarget(eye_);
fix1.Target = fixation_point;
fix1.Threshold = 3;

% The WaitThenHold adapter is a secondary processor that receives input from SingleTarget
wth1 = WaitThenHold(fix1);
wth1.WaitTime = 10000;
wth1.HoldTime = 1000;
wth1.AllowEarlyFix = allow_early_fix;

% OnOffDisplay is added just to show the state of WaitThenHold
ood1 = OnOffDisplay(wth1);
ood1.Dashboard = 4;
ood1.OnMessage = 'Waiting: true';
ood1.OffMessage = 'Waiting: false';
ood1.OnColor = [1 0 0];
ood1.OffColor = [0 1 0];
ood1.ChildProperty = 'Waiting';

scene1 = create_scene(ood1,fixation_point);

% task
dashboard(1,'WaitThenHold adapter',[1 1 0]);
dashboard(2,'Move the eye tracer into the fixation window and wait for a second');
if wth1.AllowEarlyFix
    str = 'AllowEarlyFix: true (eye can be on the window at the scene start)';
else
    str = 'AllowEarlyFix: false (eye must be off the window at the scene start)';
end
dashboard(3,str);
dashboard(ood1.Dashboard,'');
dashboard(5,'');

run_scene(scene1);
if wth1.Success
    dashboard(5,'Holding: Succeeded!',[0 1 0]);
else
    if wth1.Waiting
        dashboard(5,'Fixaion never attempted!',[1 0 0]);
    else
        dashboard(5,'Holding: Failed',[1 0 0]);
    end
end

idle(1500);
set_iti(500);
