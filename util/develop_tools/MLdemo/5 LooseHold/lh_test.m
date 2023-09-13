if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;

% editables
editable('break_time');
break_time = 300;

% scene 1: wait for fixation
fix1 = SingleTarget(eye_);
fix1.Target = fixation_point;
fix1.Threshold = 3;
wth1 = WaitThenHold(fix1);
wth1.WaitTime = 5000;
wth1.HoldTime = 0;
ood1 = OnOffDisplay(wth1);
ood1.Dashboard = 3;
ood1.OnMessage = 'Waiting: true';
ood1.OffMessage = 'Waiting: false';
ood1.OnColor = [1 0 0];
ood1.OffColor = [0 1 0];
ood1.ChildProperty = 'Waiting';
scene1 = create_scene(ood1,fixation_point);

% scene 2: fixation hold
lh2 = LooseHold(fix1);  % The LooseHold adapter allows fixation breaks during the hold period
lh2.HoldTime = 1000;
lh2.BreakTime = break_time;
scene2 = create_scene(lh2,fixation_point);

% task
dashboard(1,'LooseHold adpater',[1 1 0]);
dashboard(2,sprintf('The trial is not aborted, if the eye comes back within %d ms after fixation breaks.',break_time));
dashboard(ood1.Dashboard,'');
dashboard(4,'');

run_scene(scene1);
if ~wth1.Success
    dashboard(4,'Fixaion never attempted!',[1 0 0]);
else
    run_scene(scene2);
    if lh2.Success
        dashboard(4,'Holding: Succeeded!',[0 1 0]);
    else
        dashboard(4,'Holding: Failed',[1 0 0]);
    end
end
rt = wth1.RT;

idle(1500);
set_iti(500);
