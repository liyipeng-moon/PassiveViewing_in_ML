function [BAM_config,BAM_data, app] = fN_assign_electrode(BAM_config, BAM_data, app)


for ii = 1:BAM_config.MaxElectrode
    for jj = 1:BAM_config.MaxUnit
        if(BAM_config.Electrode(ii,jj).Using)
            % only functioning when disabled in config 
            [BAM_config,BAM_data, app] = fN_enable_electrode(BAM_config, BAM_data, app,ii,jj);
        end
    end
end


end