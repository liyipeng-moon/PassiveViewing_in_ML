function Connected = fN_ao_connect(room_number)

    AO_SDK_folder = 'C:\Program Files (x86)\AlphaOmega\AlphaLab SNR System SDK\MATLAB_SDK';
    % it seems that pcmac doesn't matter...
    if(room_number == 302)
        BAM_config.IP.DSPMAC = 'A8:1B:6A:21:24:4B'; % Behind AO SnR
        BAM_config.IP.PCMAC = 'bc:6a:29:e1:49:bf';% IP of online analysis PC
    else
        BAM_config.IP.DSPMAC = 'A8:1B:6A:14:74:2D'; % Behind AO SnR
        BAM_config.IP.PCMAC = 'b3:6a:29:e1:49:bf';% IP of online analysis PC
    end

    disp('adding ao folders')
    addpath(genpath(AO_SDK_folder))

    try
        AO_CloseConnection;
    end
    Connected = 0;
    for ii = 1:50
        if(Connected==1 || Connected==10)
            disp('connected')
            break
        end
        pause(1)
        Connected = AO_startConnection(BAM_config.IP.DSPMAC, BAM_config.IP.PCMAC, -1);
    end
    

end