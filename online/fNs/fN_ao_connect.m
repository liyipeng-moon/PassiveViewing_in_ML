function [BAM_config,BAM_data, app] = fN_ao_connect(BAM_config, BAM_data, app)
%% connect to AO

    if(BAM_config.IP.DeviceFreeMode)
        BAM_config.IP.Connected=1;
        return;
    else
        for ii = 1:50
            if(BAM_config.IP.Connected==1 || BAM_config.IP.Connected==10)
                disp('connected')
                break
            end
            pause(1)
            BAM_config.IP.Connected = AO_startConnection(BAM_config.IP.DSPMAC, BAM_config.IP.PCMAC, -1);
        end
    end
end
