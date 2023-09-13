% Exit early when the x key is pressed
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

% Make a scene that spends 3 seconds
tc = TimeCounter(null_);
tc.Duration = 500;
ev_marker = [1,2,4,8,16,32,64,128,255];
% Save the initial condition of the scene
scene = create_scene(tc,1);  % Display TaskObject#1 during the scene

% Run the scene
for ev = ev_marker
    run_scene(scene,ev);  % Eventcode 10 is sent out at the beginning of the scene.
end                      % The scene ends when TimeCounter stops after 3 s.
                      
idle(50,[],20);       % Clear the screens at the end and send Eventcode 20. Without this line,
                      % TaskObject#1 stays on the screen through the inter-trial interval.