FOB_category = {'Face','Body','Hand','Tech','Scram','Fruit'};

Local_OE_IP = '222.29.33.102';
WKS_OE_IP = '192.1168.3.41';
OE_IP = Local_OE_IP;
OE_url = ['http://' OE_IP ':37497/api/'];
OE_out = webread([OE_url, 'status']);
if(strcmp(OE_out.mode, 'IDLE'))
    OE_out = webwrite([OE_url, 'status'], struct('mode','ACQUIRE'), weboptions('RequestMethod','put','MediaType','application/json'));
    pause(0.2)
    OE_out = webwrite([OE_url, 'status'], struct('mode','RECORD'), weboptions('RequestMethod','put','MediaType','application/json'));
elseif(strcmp(OE_out.mode, 'ACQUIRE'))
    OE_out = webwrite([OE_url, 'status'], struct('mode','RECORD'), weboptions('RequestMethod','put','MediaType','application/json'));
end

if(~strcmp(OE_out.mode, 'RECORD'))
    warning('Not connected to OE!');
else
    disp('OE Connected');
    processor_list = webread([OE_url, 'processors']).processors;
    OE_out.Online_PSTH_id=0;
    for ii = 1:length(processor_list)
        if(strcmp(processor_list(ii).name,'Online PSTH'))
            OE_out.Online_PSTH_id = processor_list(ii).id;
        end
    end
    if(OE_out.Online_PSTH_id==0)
        disp('No online psth module found!')
    else
        disp('Online Psth Found!')
        OE_out.success = 1;
        OE_out.psth_url = [OE_url, 'processors/' num2str(OE_out.Online_PSTH_id), '/config'];
    end
end

for cc = 1:length(FOB_category)
    condition_name = FOB_category{cc};
    meg_to_send = ['{"condition_index" : ' num2str(cc-1) ',"name" : "' condition_name '","ttl_line" : 9,"trigger_type" : 2}'];
    out = webwrite(OE_out.psth_url, struct('text',meg_to_send), weboptions('RequestMethod','put','MediaType','application/json'));
    if(strcmp(out.info, 'Message received.'))
        continue
    else
        warning('Fail to add category!! Do you have enough condition in your OE GUI?')
    end
end
%% For WKS
cd ..\ %  .mexw64 file should be within the current folder? 
global zeroMQ_handle
Local_OE_IP = '222.29.33.102';
WKS_OE_IP = '192.1168.3.41';
OE_IP = Local_OE_IP;
zeroMQ_url = ['tcp://' OE_IP ':5556']; %
if(isempty(zeroMQ_handle)) % if connected already, reStartConnect would lead to collapse 
    zeroMQ_handle = zeroMQwrapper('StartConnectThread',zeroMQ_url);
end
for ii = 1:100
    pause(0.2)
    zeroMQwrapper('Send',zeroMQ_handle ,FOB_category{randi(6)});
    pause(0.2)
    zeroMQwrapper('Send',zeroMQ_handle ,'off');
end


% check whether averaged or single trial
for ii = 1:10000
    xx = randi(6);
    switch xx
        case 1
            zeroMQwrapper('Send',zeroMQ_handle , 'Body');
            pause(1+rand)
        case 2
            zeroMQwrapper('Send',zeroMQ_handle , 'Body');
            pause(1+rand)
        case 3
            zeroMQwrapper('Send',zeroMQ_handle , 'Hand');
            pause(1+rand)
        otherwise
            zeroMQwrapper('Send',zeroMQ_handle ,'Face');
            pause(1+rand)
    end
end
   