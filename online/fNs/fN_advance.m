function [BAM_config,BAM_data, app] = fN_advance(BAM_config, BAM_data, app,electrode,channel)


    for electrode = 1:BAM_config.MaxElectrode
        if(BAM_config.ElectrodeUsing(electrode))
            for channel = 1:BAM_config.MaxUnit
                    [BAM_config,BAM_data, app] = fN_enable_electrode(BAM_config, BAM_data, app,electrode,channel);
            end
        end
    end

end