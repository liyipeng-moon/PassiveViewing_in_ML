% Exit early when the x key is pressed
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

hotkey('r', 'goodmonkey(100, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');
hotkey('t', 'goodmonkey(200, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');
hotkey('y', 'goodmonkey(300, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');
hotkey('u', 'goodmonkey(400, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');
hotkey('i', 'goodmonkey(500, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');
% Make a scene that spends 3 seconds
tc = TimeCounter(null_);
tc.Duration = 5900;
% Save the initial condition of the scene
scene = create_scene(tc,1);  % Display TaskObject#1 during the scene
% Run the scene
run_scene(scene,1);  % Eventcode 10 is sent out at the beginning of the scene.


dashboard(1, 'T for 100ms reward');
dashboard(1, 'Y for 200ms reward');
dashboard(1, 'U for 300ms reward');
dashboard(1, 'I for 400ms reward');
dashboard(1, 'O for 500ms reward');
                      
idle(50,[],20);       % Clear the screens at the end and send Eventcode 20. Without this line,
                      % TaskObject#1 stays on the screen through the inter-trial interval.