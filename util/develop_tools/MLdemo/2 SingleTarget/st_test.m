if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;

% scene 1: fixation
fix1 = SingleTarget(eye_);
fix1.Target = fixation_point;
fix1.Threshold = 3;

% OnOffDisplay & TimeCounter are added just to show how SingleTarget works
ood1 = OnOffDisplay(fix1);
ood1.Dashboard = 3;
ood1.OnMessage = 'ON Target';
ood1.OffMessage = 'OFF Target';
ood1.OnColor = [0 1 0];
ood1.OffColor = [1 0 0];
tc1 = TimeCounter(ood1);
tc1.Duration = 10000;

scene1 = create_scene(tc1,fixation_point);

% task
dashboard(1,'SingleTarget adapter',[1 1 0]);
dashboard(2,'Try moving the eye tracer into and out of the fixation window');
dashboard(ood1.Dashboard,'');

run_scene(scene1);

idle(50);
set_iti(500);
