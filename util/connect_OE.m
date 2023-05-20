function OE_out = connect_OE(OE_IP)
global zeroMQ_handle
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

    zeroMQ_url = ['tcp://' OE_IP ':5556']; %
    if(isempty(zeroMQ_handle))
        zeroMQ_handle = zeroMQwrapper('StartConnectThread',zeroMQ_url);
    else
    end
end


