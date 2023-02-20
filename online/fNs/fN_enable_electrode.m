function [BAM_config,BAM_data, app] = fN_enable_electrode(BAM_config, BAM_data, app,electrode,channel)
            spinner_filed  = ['Spinners', num2str(electrode), num2str(channel)];
            temp = getfield(app, spinner_filed);
            BAM_config.num_unit_used = BAM_config.num_unit_used +1;
            BAM_config.Electrode(electrode,channel).UID=BAM_config.num_unit_used;
            temp.Value = BAM_config.Electrode(electrode,channel).UID;
            setfield(app,spinner_filed,temp);
end