function [BAM_config,BAM_data, app] = fN_refresh_electrode(BAM_config, BAM_data, app)

%% electrode changing
for electrode = 1:BAM_config.MaxElectrode
    electrode_using = 1;
    lfp_field = ['ChannelUsingLFP' num2str(electrode)];
    temp = getfield(app,lfp_field);
    BAM_config.ElectrodeUsing(electrode) = temp.Value;
    if(BAM_config.ElectrodeUsing(electrode))
        for channel = 1:BAM_config.MaxUnit
            BAM_config.Electrode(electrode,channel).Using=1;
        end
    else
        for channel = 1:BAM_config.MaxUnit
            BAM_config.Electrode(electrode,channel).Using=0;
            BAM_config.Electrode(electrode,channel).UID = 0;
        end
    end
end
%% unit id changing
    for electrode = 1:BAM_config.MaxElectrode
        for channel = 1:BAM_config.MaxUnit

            spinner_filed  = ['Spinners', num2str(electrode), num2str(channel)];

            
            temp = getfield(app, spinner_filed);
            if(BAM_config.Electrode(electrode,channel).Using)
                % ID +1
                if(temp.Value~=BAM_config.Electrode(electrode,channel).UID || BAM_config.Electrode(electrode,channel).UID==0)
                    [BAM_config,BAM_data, app] = fN_enable_electrode(BAM_config, BAM_data, app,electrode,channel);
                end
            else
                % ID to 0
                    temp.Value = 0;
                    setfield(app,spinner_filed,temp);
            end

        end
    end
end