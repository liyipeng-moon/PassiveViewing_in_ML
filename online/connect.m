close all;clear;clc
root_dir = pwd;
cd 'C:\Program Files (x86)\AlphaOmega\AlphaLab SNR System SDK\MATLAB_SDK'

addpath(genpath(pwd))
cd(root_dir)

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

channelidarr = [10256,11020,11202,10128];
channel_name = {'spk1','reward','eventcode','seg'};

for ii = 1:length(channel_name)
    interested_channel = channelidarr(ii);
    [rr2] = AO_AddBufferingChannel(interested_channel,10000);
end

AO_ClearChannelData()
figure
set(gcf,'Position',[ 32         178        1814         631])
while(1)
    AO_ClearChannelData()
    pause(0.5)
    try
    for ii = 1:length(channel_name)
        interested_channel = channelidarr(ii);
        [result,pdata{ii},datacapture{ii}] = AO_GetChannelData(interested_channel);
    end

    for ii = 1:4
        subplot(2,5,ii)
        plot(pdata{ii}(8:datacapture{ii}))
        title(datacapture{ii})
    end

    [a,b,dm]=sort_digital_port(pdata{3}, datacapture{3});
    [a,b,dm]=sort_seg_port(pdata{4}, datacapture{4});
    datacapture{4}
    end
end


