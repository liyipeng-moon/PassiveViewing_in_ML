%%
close all;clear;clc
root_dir = pwd;
cd 'C:\Program Files (x86)\AlphaOmega\AlphaLab SNR System SDK\MATLAB_SDK'
addpath(genpath(pwd))
cd(root_dir)
connect_to_ao;


channelidarr = [10256,11020,11202,10128];
channel_name = {'spk1','reward','eventcode','seg'};

for ii = 1:length(channel_name)
    interested_channel = channelidarr(ii);
    [rr2] = AO_AddBufferingChannel(interested_channel,10000);
end

AO_ClearChannelData()
figure
set(gcf,'Position',[ 32         178        1814         631])
big_ev_train=[];big_ev_time=[];
big_spike_train=[];big_spike_time=[];
while(1)
    AO_ClearChannelData()
    pause(4)
    tic
    try
    for ii = 1:length(channel_name)
        interested_channel = channelidarr(ii);
        [result,pdata{ii},datacapture{ii}] = AO_GetChannelData(interested_channel);
    end

    [ev_train,ev_time]=fN_sort_digital_port(pdata{3}, datacapture{3});
    [spike_train,spike_time]=fN_sort_seg_port(pdata{4}, datacapture{4});

    big_ev_train = [big_ev_train, ev_train];
    big_ev_time = [big_ev_time, ev_time];
    end
    toc
end


