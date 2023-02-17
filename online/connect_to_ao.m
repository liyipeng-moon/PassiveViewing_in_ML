%% connect to AO


DSPMAC = 'A8:1B:6A:21:24:4B';
PCMAC = 'bc:6a:29:e1:49:bf';
AdapterIdx = -1;

rr = 0;
for ii = 1:50
    if(rr==1 || rr==10)
        disp('connected')
        break
    end
    pause(1)
    rr = AO_startConnection(DSPMAC, PCMAC, AdapterIdx);
end
