if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

editable('onset_time', 'offset_time', 'reward_interval', 'reward_duration', 'fixation_window', 'max_break_time')
onset_time = 200;
offset_time = 200;
reward_interval = 1000; % in miliseconds.
reward_duration = 100; % in miliseconds, but you need to verify this by testing your hardware
fixation_window = 1; % in degree, how large your fixation window is.
max_break_time = 300; % how long you can accept for fixation break, in miliseconds.



ID = TrialRecord.User.imageIDs;

bhv_variable('Current_ID', TrialRecord.User.ImageIdx, 'DatasetName', TrialRecord.User.current_set)
%% image system
% can cell be improved?
img = ImageChanger(null_);

    imglist = cell(TrialRecord.User.image_train*2,4);
    for img_trial_idx = 1:TrialRecord.User.image_train
        % set picture
        idx=2*img_trial_idx-1;
        imglist(idx,1)={ID(img_trial_idx)};
        imglist(idx,2)={[0,0]};
        imglist(idx,3)={onset_time};
        imglist(idx,4)={img_trial_idx+10000};
        % set blank
        idx=2*img_trial_idx;
        imglist(idx,1)={[]};
        imglist(idx,2)={[]};
        imglist(idx,3)={offset_time};
        imglist(idx,4)={img_trial_idx+20000};
    end
    img.List=imglist;
    img.DurationUnit='mesc';


%% fixation system 
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

pm = PropertyMonitor(rwd);  % display the state of rwd on the screen
pm.Dashboard = 1;


con = Concurrent(img);
con.add(rwd);
con.add(crc);
con.add(pm);

%% Timing System
dashboard(2, sprintf(['dataset - ' TrialRecord.User.current_set, '(n=' ,num2str(TrialRecord.User.imageset_size), ')']))
dashboard(3, sprintf(['has been played for ' num2str((TrialRecord.CurrentTrialNumber-1)*TrialRecord.User.cycle_per_trial,2), ' cycles before,']))
counter_num = floor((10*TrialRecord.User.image_train)/(TrialRecord.User.imageset_size));
time_cycle = TrialRecord.User.imageset_size * (onset_time+offset_time) /10;
for ii = 1:counter_num
    tc(ii) = TimeCounter(null_);
    tc(ii).Duration = ii*time_cycle;
    ood(ii) = OnOffDisplay(tc(ii));
    ood(ii).Dashboard = 4;
    ood(ii).OnMessage = ['new ', num2str(floor(ii/10)), '.' ,num2str(mod(ii,10)) ,' cycle displayed'];
    ood(ii).OffMessage = ['new cycle waiting'];
    con.add(ood(ii))
end

scene = create_scene(con);
TrialRecord.User.played_images = TrialRecord.User.played_images + TrialRecord.User.image_train;
run_scene(scene);

idle(0);
set_iti(0);
