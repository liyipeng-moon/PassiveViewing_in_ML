% Exit early when the x key is pressed
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

hotkey('r', 'goodmonkey(100, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');
hotkey('t', 'goodmonkey(200, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');
hotkey('y', 'goodmonkey(300, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');
hotkey('u', 'goodmonkey(400, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');
hotkey('i', 'goodmonkey(500, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');

dashboard(1, 'T for 100ms reward');
dashboard(2, 'Y for 200ms reward');
dashboard(3, 'U for 300ms reward');
dashboard(4, 'I for 400ms reward');
dashboard(5, 'O for 500ms reward');

mov = MovieGraphic(null_);
mov.List = { [num2str(randi(9)), '.mp4'], [0 0], 1, 0.5};   % movie filename
tc = TimeCounter(mov);
tc.Duration = 300*1000;
scene = create_scene(tc);
run_scene(scene);
idle(0);   % clear the screen
