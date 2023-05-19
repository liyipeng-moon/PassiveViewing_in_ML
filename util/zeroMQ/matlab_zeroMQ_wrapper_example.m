url = 'tcp://222.29.33.102:5556'; % or, e.g., //'tcp://10.71.212.19:5556 if GUI runs on another machine...

handle = zeroMQwrapper('StartConnectThread',url);


for k = 1:10000
    % indicate trial type number #2 has started
    zeroMQwrapper('Send',handle ,'face');
    disp('Trial start')
    pause(0.5)

    % indicate trial type number #2 has started
    zeroMQwrapper('Send',handle ,'body');
    disp('Trial start')
    pause(0.5)

    % indicate trial type number #2 has started 
    zeroMQwrapper('Send',handle ,'hand');
    disp('Trial start')
    pause(0.5)
end

zeroMQwrapper('CloseThread',handle);
