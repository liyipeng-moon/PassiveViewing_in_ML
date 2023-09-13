if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;

% This determines whether FreeThenHold allows fixation to be made before the scene start.
allow_early_fix = false;
editable('allow_early_fix');

% scene 1: wait for fixation and hold
fix1 = SingleTarget(eye_);
fix1.Target = fixation_point;
fix1.Threshold = 3;

% FreeThenHold is a secondary processor that receives input from SingleTarget
fth1 = FreeThenHold(fix1);  % The main difference between FreeThenHold and WaitThenHold
fth1.WaitTime = 10000;      % is that FreeThenHold allows fixation breaks, before the hold
fth1.HoldTime = 1000;       % requirement is fulfilled, and WaitThenHold does not.
fth1.AllowEarlyFix = allow_early_fix;

% PropertyMonitor is added just to show the state of FreeThenHold
pm1 = PropertyMonitor(fth1);
pm1.Dashboard = 4;
pm1.Color = [0.7 0.7 0.7];
pm1.ChildProperty = 'BreakCount';

scene1 = create_scene(pm1,fixation_point);

% task
dashboard(1,'FreeThenHold adapter',[1 1 0]);
dashboard(2,'Unlike WaitThenHold, fixation can be broken multiple times before the hold requirement is fulfilled');
if fth1.AllowEarlyFix
    str = 'AllowEarlyFix: true (eye can be on the window at the scene start)';
else
    str = 'AllowEarlyFix: false (eye must be off the window at the scene start)';
end
dashboard(3,str);
dashboard(pm1.Dashboard,'');
dashboard(5,'');

run_scene(scene1);
if fth1.Success
    dashboard(5,'Holding: Succeeded!',[0 1 0]);
else
    if 0==fth1.BreakCount
        dashboard(5,'Fixaion never attempted!',[1 0 0]);
    else
        dashboard(5,'Holding: Failed',[1 0 0]);
    end
end

idle(1500);
set_iti(500);
